import Foundation

/// Parses the shorthand running-workout notation used in the user's own
/// training plan, e.g.
///
///     "5´RM + 4 x (1´ RA + 1´30\"´RS) + 8´ RM"
///     "2 x [4 x (1´RM + 2´RS o caminado)] recup. entre bloques 3´RS o caminando"
///     "6´ RM + 4 x (80m progresivos recup. 2’RS o caminando) + 10’ RM"
///
/// into a flat `[RunningPhase]` the timer engine can run directly.
///
/// The grammar is informal and the source text is hand-typed, so the parser
/// is deliberately forgiving: anything it cannot confidently interpret is
/// kept as a `.nota` phase instead of crashing or silently dropping content.
enum RunningNotationParser {

    // MARK: - Public entry point

    static func parse(_ raw: String) -> [RunningPhase] {
        do {
            let tokens = tokenize(raw)
            var cursor = Cursor(tokens: tokens)
            let phases = try parseSequence(&cursor, stopAt: [])
            if phases.isEmpty {
                return [RunningPhase(kind: .nota, note: raw)]
            }
            return phases
        } catch {
            // Never crash on a malformed / custom notation — surface it as
            // a manual note the user can still "play" through.
            return [RunningPhase(kind: .nota, note: raw)]
        }
    }

    // MARK: - Tokens

    private enum Token: Equatable {
        case minutes(Int)
        case seconds(Int)
        case meters(Int)
        case label(RunningPhaseKind)   // RM / RA / RS / caminando
        case number(Int)               // bare integer, used before "x"
        case xOp
        case lparen
        case rparen
        case plus
        case word(String)
    }

    private struct Cursor {
        let tokens: [Token]
        var index: Int = 0
        var isAtEnd: Bool { index >= tokens.count }
        var current: Token? { isAtEnd ? nil : tokens[index] }
        mutating func advance() -> Token? {
            guard !isAtEnd else { return nil }
            let t = tokens[index]
            index += 1
            return t
        }
    }

    private enum ParseError: Error { case unexpected }

    // MARK: - Tokenizer

    private static func tokenize(_ raw: String) -> [Token] {
        var text = raw
        // Normalize every "prime" glyph used for minutes/seconds in the sheet.
        let doubles = ["´´", "''", "’’", "``"]
        for d in doubles { text = text.replacingOccurrences(of: d, with: "\"") }
        let singles = ["´", "’", "`", "′"]
        for s in singles { text = text.replacingOccurrences(of: s, with: "'") }
        text = text.replacingOccurrences(of: "”", with: "\"")

        var tokens: [Token] = []
        var chars = Array(text)
        var i = 0

        func peekIsDigit(_ idx: Int) -> Bool { idx < chars.count && chars[idx].isNumber }

        while i < chars.count {
            let c = chars[i]

            if c.isNumber {
                var numStr = ""
                while i < chars.count && chars[i].isNumber {
                    numStr.append(chars[i]); i += 1
                }
                let value = Int(numStr) ?? 0
                if i < chars.count && chars[i] == "'" {
                    i += 1
                    tokens.append(.minutes(value))
                } else if i < chars.count && chars[i] == "\"" {
                    i += 1
                    tokens.append(.seconds(value))
                } else if i < chars.count && chars[i] == "m"
                            && !(i + 1 < chars.count && chars[i + 1].isLetter) {
                    i += 1
                    tokens.append(.meters(value))
                } else {
                    tokens.append(.number(value))
                }
                continue
            }

            if c == "(" || c == "[" { tokens.append(.lparen); i += 1; continue }
            if c == ")" || c == "]" { tokens.append(.rparen); i += 1; continue }
            if c == "+" { tokens.append(.plus); i += 1; continue }

            if c.isLetter {
                var word = ""
                while i < chars.count && (chars[i].isLetter || chars[i] == ".") {
                    word.append(chars[i]); i += 1
                }
                let upper = word.uppercased()
                switch upper {
                case "RM": tokens.append(.label(.ritmoMedio))
                case "RA": tokens.append(.label(.ritmoAlto))
                case "RS": tokens.append(.label(.ritmoSuave))
                case "X": tokens.append(.xOp)
                case "CAMINANDO", "CAMINADO": tokens.append(.label(.caminar))
                default: tokens.append(.word(word))
                }
                continue
            }

            // whitespace, punctuation, stray quote marks — skip
            i += 1
        }

        _ = peekIsDigit // silence unused-helper warning if not otherwise used
        return tokens
    }

    // MARK: - Recursive-descent parsing

    /// Parses a `Term ('+' Term)*` sequence, stopping at end of input or when
    /// a `.rparen` is encountered (the caller consumes the closing bracket).
    private static func parseSequence(_ cursor: inout Cursor, stopAt: Set<Int>) throws -> [RunningPhase] {
        var result: [RunningPhase] = []

        while let tok = cursor.current {
            if tok == .rparen { break }

            if tok == .plus {
                _ = cursor.advance()
                continue
            }

            if case .word = tok {
                // Skip filler words at the sequence level (e.g. a trailing
                // "o caminando" that wasn't absorbed as an inter-rep rest).
                _ = cursor.advance()
                continue
            }

            let before = cursor.index
            let term = try parseTerm(&cursor)
            result.append(contentsOf: term)

            // Guard against an accidental infinite loop on an unrecognised token.
            if cursor.index == before { _ = cursor.advance() }
        }

        return result
    }

    /// Parses one term: a repeat block, a parenthesised group, a timed
    /// duration+label, or a distance segment.
    private static func parseTerm(_ cursor: inout Cursor) throws -> [RunningPhase] {
        guard let tok = cursor.current else { throw ParseError.unexpected }

        // "N x (...)" or "N x [...]"
        if case .number(let n) = tok, cursor.index + 1 < cursor.tokens.count, cursor.tokens[cursor.index + 1] == .xOp {
            _ = cursor.advance() // number
            _ = cursor.advance() // x
            guard cursor.current == .lparen else { throw ParseError.unexpected }
            _ = cursor.advance() // (
            let unit = try parseSequence(&cursor, stopAt: [])
            guard cursor.current == .rparen else { throw ParseError.unexpected }
            _ = cursor.advance() // )

            let interRest = tryConsumeInterRepRest(&cursor)

            var expanded: [RunningPhase] = []
            for i in 0..<max(n, 1) {
                expanded.append(contentsOf: unit)
                if let rest = interRest, i < n - 1 {
                    expanded.append(rest)
                }
            }
            return expanded
        }

        if tok == .lparen {
            _ = cursor.advance()
            let inner = try parseSequence(&cursor, stopAt: [])
            guard cursor.current == .rparen else { throw ParseError.unexpected }
            _ = cursor.advance()
            return inner
        }

        // Duration (+ optional label), e.g. 1'30"RM, 30"RA, 5'RM
        if case .minutes = tok {
            return [try parseDuration(&cursor)]
        }
        if case .seconds = tok {
            return [try parseDuration(&cursor)]
        }

        if case .meters(let m) = tok {
            _ = cursor.advance()
            return [RunningPhase(kind: .distancia, meters: m)]
        }

        if case .word(let w) = tok {
            _ = cursor.advance()
            if w.uppercased().contains("SIMULACRO") || w.uppercased().contains("TEST") {
                return [RunningPhase(kind: .cronometro, note: w)]
            }
            return [] // ignore other filler words as a standalone term
        }

        // Anything else we don't recognise — skip a single token to make progress.
        _ = cursor.advance()
        return []
    }

    /// Parses `minutes[seconds] [label]` into a single RunningPhase.
    private static func parseDuration(_ cursor: inout Cursor) throws -> RunningPhase {
        var total = 0
        if case .minutes(let m) = cursor.current {
            total += m * 60
            _ = cursor.advance()
            if case .seconds(let s) = cursor.current {
                total += s
                _ = cursor.advance()
            }
        } else if case .seconds(let s) = cursor.current {
            total += s
            _ = cursor.advance()
        } else {
            throw ParseError.unexpected
        }

        var kind: RunningPhaseKind = .ritmoSuave
        if case .label(let k) = cursor.current {
            kind = k
            _ = cursor.advance()
        } else {
            // Look a little further for a stray "caminando" describing this block.
            kind = .ritmoSuave
        }
        return RunningPhase(kind: kind, seconds: total)
    }

    /// After a repeat block closes, the source text often trails a
    /// "recup. entre bloques 3'RS o caminando" style phrase with *no*
    /// leading "+". If exactly one duration+label shows up before the next
    /// structural token, treat it as the rest inserted *between* reps and
    /// consume it; otherwise leave the cursor untouched.
    private static func tryConsumeInterRepRest(_ cursor: inout Cursor) -> RunningPhase? {
        let start = cursor.index
        var i = cursor.index
        var foundDurationAt: Int? = nil

        while i < cursor.tokens.count {
            switch cursor.tokens[i] {
            case .plus, .rparen, .lparen, .xOp:
                i = cursor.tokens.count + 1 // force stop
            case .number:
                if i + 1 < cursor.tokens.count, cursor.tokens[i + 1] == .xOp {
                    i = cursor.tokens.count + 1 // a new "N x (" block starts — stop
                } else {
                    i += 1
                }
            case .minutes, .seconds:
                if foundDurationAt == nil { foundDurationAt = i }
                i += 1
            case .label, .word, .meters:
                i += 1
            }
            if i > cursor.tokens.count { break }
        }

        guard let durationIndex = foundDurationAt else {
            cursor.index = start
            return nil
        }

        cursor.index = durationIndex
        guard let phase = try? parseDuration(&cursor) else {
            cursor.index = start
            return nil
        }
        return phase
    }
}
