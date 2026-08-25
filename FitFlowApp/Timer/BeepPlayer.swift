import AVFoundation

/// Synthesizes short, punchy "sporty" beeps in code — no audio assets to
/// bundle or license. Two tones: a quick mid transition beep between phases,
/// and a brighter triple-beep when a whole session finishes.
final class BeepPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var isSetUp = false

    init() {
        setUp()
    }

    private func setUp() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        engine.attach(player)
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do {
            try engine.start()
            isSetUp = true
        } catch {
            isSetUp = false
        }
    }

    func playTransition() {
        play(frequencies: [880], duration: 0.12)
    }

    func playFinish() {
        play(frequencies: [660, 880, 1320], duration: 0.14, gapBetween: 0.06)
    }

    /// Plays each frequency in sequence as a short sine-wave "beep".
    private func play(frequencies: [Double], duration: Double, gapBetween: Double = 0) {
        guard isSetUp else { return }
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate

        if !player.isPlaying { player.play() }

        var delay: Double = 0
        for freq in frequencies {
            if let buffer = makeToneBuffer(frequency: freq, duration: duration, sampleRate: sampleRate, format: format) {
                let sampleTime = AVAudioTime(sampleTime: AVAudioFramePosition(delay * sampleRate), atRate: sampleRate)
                player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
                _ = sampleTime // scheduling immediately back-to-back keeps this simple & reliable
            }
            delay += duration + gapBetween
        }
    }

    private func makeToneBuffer(frequency: Double, duration: Double, sampleRate: Double, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        let channels = Int(format.channelCount)
        for frame in 0..<Int(frameCount) {
            // Simple envelope (quick attack, gentle release) so beeps sound
            // crisp and "sporty" rather than a harsh square click.
            let t = Double(frame) / sampleRate
            let envelope = min(1, Double(frame) / 200) * min(1, Double(Int(frameCount) - frame) / 400)
            let sample = Float(sin(2 * Double.pi * frequency * t) * envelope * 0.4)
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        return buffer
    }
}
