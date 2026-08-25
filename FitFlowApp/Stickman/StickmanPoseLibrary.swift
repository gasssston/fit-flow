import CoreGraphics

/// A small hand-authored library of core/ab exercise animations, in the
/// "isometric plank variations" style (20s work / 10s rest) from the
/// reference video. Extend this with more `StickmanAnimation` entries as
/// you add exercises — that's the one thing this file is designed for.
enum StickmanPoseLibrary {

    static func animation(for id: String) -> StickmanAnimation {
        all.first(where: { $0.id == id }) ?? plank
    }

    static let all: [StickmanAnimation] = [plank, sidePlankLeft, sidePlankRight, commandoPlank, mountainClimbers, legRaise, crunch]

    // MARK: - Plancha prona (forearm plank) — subtle hold sway

    static let plank = StickmanAnimation(
        id: "plank", displayName: "Plancha prona", secondsPerBeat: 1.4,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.30), neck: .init(x: 0.16, y: 0.33),
                         hip: .init(x: 0.55, y: 0.40),
                         leftShoulder: .init(x: 0.18, y: 0.35), rightShoulder: .init(x: 0.18, y: 0.37),
                         leftElbow: .init(x: 0.18, y: 0.55), rightElbow: .init(x: 0.18, y: 0.57),
                         leftHand: .init(x: 0.13, y: 0.62), rightHand: .init(x: 0.13, y: 0.64),
                         leftKnee: .init(x: 0.85, y: 0.42), rightKnee: .init(x: 0.85, y: 0.44),
                         leftFoot: .init(x: 0.96, y: 0.60), rightFoot: .init(x: 0.96, y: 0.62)),
            StickmanPose(head: .init(x: 0.06, y: 0.32), neck: .init(x: 0.16, y: 0.35),
                         hip: .init(x: 0.55, y: 0.46),
                         leftShoulder: .init(x: 0.18, y: 0.37), rightShoulder: .init(x: 0.18, y: 0.39),
                         leftElbow: .init(x: 0.18, y: 0.56), rightElbow: .init(x: 0.18, y: 0.58),
                         leftHand: .init(x: 0.13, y: 0.62), rightHand: .init(x: 0.13, y: 0.64),
                         leftKnee: .init(x: 0.85, y: 0.44), rightKnee: .init(x: 0.85, y: 0.46),
                         leftFoot: .init(x: 0.96, y: 0.60), rightFoot: .init(x: 0.96, y: 0.62)),
        ])

    // MARK: - Plancha lateral (side plank)

    static let sidePlankLeft = StickmanAnimation(
        id: "sidePlankLeft", displayName: "Plancha lateral (izq. apoyo)", secondsPerBeat: 1.4,
        keyframes: [
            StickmanPose(head: .init(x: 0.10, y: 0.24), neck: .init(x: 0.18, y: 0.29),
                         hip: .init(x: 0.55, y: 0.38),
                         leftShoulder: .init(x: 0.20, y: 0.32), rightShoulder: .init(x: 0.20, y: 0.29),
                         leftElbow: .init(x: 0.20, y: 0.52), rightElbow: .init(x: 0.20, y: 0.14),
                         leftHand: .init(x: 0.16, y: 0.60), rightHand: .init(x: 0.20, y: 0.02),
                         leftKnee: .init(x: 0.85, y: 0.40), rightKnee: .init(x: 0.85, y: 0.40),
                         leftFoot: .init(x: 0.96, y: 0.55), rightFoot: .init(x: 0.96, y: 0.55)),
            StickmanPose(head: .init(x: 0.10, y: 0.26), neck: .init(x: 0.18, y: 0.31),
                         hip: .init(x: 0.55, y: 0.42),
                         leftShoulder: .init(x: 0.20, y: 0.34), rightShoulder: .init(x: 0.20, y: 0.31),
                         leftElbow: .init(x: 0.20, y: 0.53), rightElbow: .init(x: 0.22, y: 0.18),
                         leftHand: .init(x: 0.16, y: 0.60), rightHand: .init(x: 0.24, y: 0.06),
                         leftKnee: .init(x: 0.85, y: 0.42), rightKnee: .init(x: 0.85, y: 0.42),
                         leftFoot: .init(x: 0.96, y: 0.56), rightFoot: .init(x: 0.96, y: 0.56)),
        ])

    static let sidePlankRight = StickmanAnimation(
        id: "sidePlankRight", displayName: "Plancha lateral (der. apoyo)", secondsPerBeat: 1.4,
        keyframes: sidePlankLeft.keyframes.map { pose in
            StickmanPose(head: pose.head, neck: pose.neck, hip: pose.hip,
                         leftShoulder: pose.rightShoulder, rightShoulder: pose.leftShoulder,
                         leftElbow: pose.rightElbow, rightElbow: pose.leftElbow,
                         leftHand: pose.rightHand, rightHand: pose.leftHand,
                         leftKnee: pose.leftKnee, rightKnee: pose.rightKnee,
                         leftFoot: pose.leftFoot, rightFoot: pose.rightFoot)
        })

    // MARK: - Commando plank (forearm <-> straight-arm)

    static let commandoPlank = StickmanAnimation(
        id: "commandoPlank", displayName: "Commando plank", secondsPerBeat: 0.8,
        keyframes: [
            plank.keyframes[0],
            StickmanPose(head: .init(x: 0.06, y: 0.18), neck: .init(x: 0.16, y: 0.22),
                         hip: .init(x: 0.55, y: 0.30),
                         leftShoulder: .init(x: 0.18, y: 0.24), rightShoulder: .init(x: 0.18, y: 0.26),
                         leftElbow: .init(x: 0.18, y: 0.40), rightElbow: .init(x: 0.18, y: 0.42),
                         leftHand: .init(x: 0.18, y: 0.58), rightHand: .init(x: 0.18, y: 0.60),
                         leftKnee: .init(x: 0.85, y: 0.32), rightKnee: .init(x: 0.85, y: 0.34),
                         leftFoot: .init(x: 0.96, y: 0.56), rightFoot: .init(x: 0.96, y: 0.58)),
        ])

    // MARK: - Mountain climbers (plank + alternating knee drive)

    static let mountainClimbers = StickmanAnimation(
        id: "mountainClimbers", displayName: "Escaladores", secondsPerBeat: 0.45,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.16), neck: .init(x: 0.16, y: 0.20),
                         hip: .init(x: 0.55, y: 0.28),
                         leftShoulder: .init(x: 0.18, y: 0.22), rightShoulder: .init(x: 0.18, y: 0.24),
                         leftElbow: .init(x: 0.18, y: 0.38), rightElbow: .init(x: 0.18, y: 0.40),
                         leftHand: .init(x: 0.18, y: 0.56), rightHand: .init(x: 0.18, y: 0.58),
                         leftKnee: .init(x: 0.60, y: 0.34), rightKnee: .init(x: 0.88, y: 0.32),
                         leftFoot: .init(x: 0.50, y: 0.56), rightFoot: .init(x: 0.98, y: 0.56)),
            StickmanPose(head: .init(x: 0.06, y: 0.16), neck: .init(x: 0.16, y: 0.20),
                         hip: .init(x: 0.55, y: 0.28),
                         leftShoulder: .init(x: 0.18, y: 0.22), rightShoulder: .init(x: 0.18, y: 0.24),
                         leftElbow: .init(x: 0.18, y: 0.38), rightElbow: .init(x: 0.18, y: 0.40),
                         leftHand: .init(x: 0.18, y: 0.56), rightHand: .init(x: 0.18, y: 0.58),
                         leftKnee: .init(x: 0.88, y: 0.32), rightKnee: .init(x: 0.60, y: 0.34),
                         leftFoot: .init(x: 0.98, y: 0.56), rightFoot: .init(x: 0.50, y: 0.56)),
        ])

    // MARK: - Elevación de piernas (leg raise, lying on back)

    static let legRaise = StickmanAnimation(
        id: "legRaise", displayName: "Elevación de piernas", secondsPerBeat: 1.1,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.70, y: 0.58), rightKnee: .init(x: 0.70, y: 0.60),
                         leftFoot: .init(x: 0.96, y: 0.58), rightFoot: .init(x: 0.96, y: 0.60)),
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.55, y: 0.16), rightKnee: .init(x: 0.55, y: 0.18),
                         leftFoot: .init(x: 0.60, y: 0.02), rightFoot: .init(x: 0.60, y: 0.04)),
        ])

    // MARK: - Crunch (lying on back, curling up)

    static let crunch = StickmanAnimation(
        id: "crunch", displayName: "Crunch", secondsPerBeat: 0.9,
        keyframes: [
            StickmanPose(head: .init(x: 0.14, y: 0.56), neck: .init(x: 0.24, y: 0.58),
                         hip: .init(x: 0.50, y: 0.62),
                         leftShoulder: .init(x: 0.28, y: 0.58), rightShoulder: .init(x: 0.28, y: 0.60),
                         leftElbow: .init(x: 0.18, y: 0.44), rightElbow: .init(x: 0.18, y: 0.46),
                         leftHand: .init(x: 0.14, y: 0.34), rightHand: .init(x: 0.14, y: 0.36),
                         leftKnee: .init(x: 0.70, y: 0.40), rightKnee: .init(x: 0.72, y: 0.40),
                         leftFoot: .init(x: 0.86, y: 0.60), rightFoot: .init(x: 0.88, y: 0.60)),
            StickmanPose(head: .init(x: 0.30, y: 0.36), neck: .init(x: 0.38, y: 0.42),
                         hip: .init(x: 0.50, y: 0.62),
                         leftShoulder: .init(x: 0.42, y: 0.44), rightShoulder: .init(x: 0.42, y: 0.46),
                         leftElbow: .init(x: 0.34, y: 0.30), rightElbow: .init(x: 0.34, y: 0.32),
                         leftHand: .init(x: 0.30, y: 0.20), rightHand: .init(x: 0.30, y: 0.22),
                         leftKnee: .init(x: 0.70, y: 0.40), rightKnee: .init(x: 0.72, y: 0.40),
                         leftFoot: .init(x: 0.86, y: 0.60), rightFoot: .init(x: 0.88, y: 0.60)),
        ])
}
