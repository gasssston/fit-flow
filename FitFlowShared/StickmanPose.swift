import CoreGraphics

/// A single keyframe: normalized (0...1) joint positions inside a square
/// drawing box. `y = 0` is the top of the box, `y = 1` the ground.
struct StickmanPose {
    var head: CGPoint
    var neck: CGPoint
    var hip: CGPoint
    var leftShoulder: CGPoint
    var rightShoulder: CGPoint
    var leftElbow: CGPoint
    var rightElbow: CGPoint
    var leftHand: CGPoint
    var rightHand: CGPoint
    var leftKnee: CGPoint
    var rightKnee: CGPoint
    var leftFoot: CGPoint
    var rightFoot: CGPoint

    /// Linearly interpolates every joint towards `other` by `t` (0...1).
    func lerp(to other: StickmanPose, t: CGFloat) -> StickmanPose {
        func mix(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
            CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
        }
        return StickmanPose(
            head: mix(head, other.head),
            neck: mix(neck, other.neck),
            hip: mix(hip, other.hip),
            leftShoulder: mix(leftShoulder, other.leftShoulder),
            rightShoulder: mix(rightShoulder, other.rightShoulder),
            leftElbow: mix(leftElbow, other.leftElbow),
            rightElbow: mix(rightElbow, other.rightElbow),
            leftHand: mix(leftHand, other.leftHand),
            rightHand: mix(rightHand, other.rightHand),
            leftKnee: mix(leftKnee, other.leftKnee),
            rightKnee: mix(rightKnee, other.rightKnee),
            leftFoot: mix(leftFoot, other.leftFoot),
            rightFoot: mix(rightFoot, other.rightFoot)
        )
    }
}

/// A named animation: a loop of keyframes played forward then backward
/// ("ping-pong"), which is enough to sell most repeating exercise motions
/// without needing dozens of hand-authored frames.
struct StickmanAnimation {
    let id: String
    let displayName: String
    /// Seconds for one keyframe-to-keyframe transition.
    let secondsPerBeat: Double
    let keyframes: [StickmanPose]

    /// Returns the interpolated pose for an elapsed time, ping-ponging
    /// through the keyframe list forever.
    func pose(at elapsed: Double) -> StickmanPose {
        guard keyframes.count > 1 else { return keyframes.first ?? .neutral }
        let segmentCount = keyframes.count - 1
        let cycleLength = Double(segmentCount) * secondsPerBeat * 2 // there and back
        let t = elapsed.truncatingRemainder(dividingBy: cycleLength)

        let forward: Bool
        let localT: Double
        let halfCycle = Double(segmentCount) * secondsPerBeat
        if t < halfCycle {
            forward = true
            localT = t
        } else {
            forward = false
            localT = t - halfCycle
        }

        let segmentIndex = min(Int(localT / secondsPerBeat), segmentCount - 1)
        let segmentProgress = CGFloat((localT - Double(segmentIndex) * secondsPerBeat) / secondsPerBeat)

        let fromIndex = forward ? segmentIndex : (segmentCount - segmentIndex)
        let toIndex = forward ? segmentIndex + 1 : (segmentCount - segmentIndex - 1)

        return keyframes[fromIndex].lerp(to: keyframes[toIndex], t: segmentProgress)
    }
}

extension StickmanPose {
    /// A relaxed standing pose, used as a safe fallback.
    static let neutral = StickmanPose(
        head: CGPoint(x: 0.5, y: 0.10),
        neck: CGPoint(x: 0.5, y: 0.20),
        hip: CGPoint(x: 0.5, y: 0.55),
        leftShoulder: CGPoint(x: 0.40, y: 0.22),
        rightShoulder: CGPoint(x: 0.60, y: 0.22),
        leftElbow: CGPoint(x: 0.34, y: 0.38),
        rightElbow: CGPoint(x: 0.66, y: 0.38),
        leftHand: CGPoint(x: 0.32, y: 0.52),
        rightHand: CGPoint(x: 0.68, y: 0.52),
        leftKnee: CGPoint(x: 0.46, y: 0.78),
        rightKnee: CGPoint(x: 0.54, y: 0.78),
        leftFoot: CGPoint(x: 0.45, y: 0.98),
        rightFoot: CGPoint(x: 0.55, y: 0.98)
    )
}
