import CoreGraphics

/// A small hand-authored library of core/ab exercise animations, in the
/// "isometric plank variations" style (20s work / 10s rest) from the
/// reference video. Extend this with more `StickmanAnimation` entries as
/// you add exercises — that's the one thing this file is designed for.
enum StickmanPoseLibrary {

    static func animation(for id: String) -> StickmanAnimation {
        all.first(where: { $0.id == id }) ?? plank
    }

    static let all: [StickmanAnimation] = [plank, sidePlankLeft, sidePlankRight, commandoPlank, mountainClimbers, legRaise, jackknife, legCircles, legRaiseAlternating, alternatingKneeTucks, legScissors, windshieldWipers, crunch, bicycleCrunch, heelTouches, vTwist, hollowHold, flatExtendedHold, vUp, supportedKneeTuck, butterflySitUp, plankKnees, highPlank, plankLegRaise, spidermanPlank, supermanPlank, crossToeTouch]

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

    // MARK: - Navaja abdominal / jackknife (hip lift + knee tuck, lying on back)

    static let jackknife = StickmanAnimation(
        id: "jackknife", displayName: "Navaja abdominal (jackknife)", secondsPerBeat: 0.95,
        keyframes: [
            // Keyframe 1 — extended: hip on ground, legs straight out low.
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.70, y: 0.58), rightKnee: .init(x: 0.70, y: 0.60),
                         leftFoot: .init(x: 0.96, y: 0.58), rightFoot: .init(x: 0.96, y: 0.60)),
            // Keyframe 2 — curled: hip lifts up, knees bend and tuck in, feet near head.
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.38, y: 0.34),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.44, y: 0.30), rightKnee: .init(x: 0.44, y: 0.32),
                         leftFoot: .init(x: 0.22, y: 0.42), rightFoot: .init(x: 0.22, y: 0.44)),
        ])

    // MARK: - Círculos de pierna / leg circles (4 keyframes, circular sweep)

    static let legCircles = StickmanAnimation(
        id: "legCircles", displayName: "Círculos de pierna (leg circles)", secondsPerBeat: 1.0,
        keyframes: [
            // KF1 — left leg straight up toward ceiling (~90°)
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.55, y: 0.14), rightKnee: .init(x: 0.62, y: 0.50),
                         leftFoot: .init(x: 0.60, y: 0.02), rightFoot: .init(x: 0.70, y: 0.62)),
            // KF2 — left leg swept out to the side, roughly hip height
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.42, y: 0.44), rightKnee: .init(x: 0.62, y: 0.50),
                         leftFoot: .init(x: 0.20, y: 0.56), rightFoot: .init(x: 0.70, y: 0.62)),
            // KF3 — left leg swept down and inward, close to the ground near the other leg
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.72, y: 0.56), rightKnee: .init(x: 0.62, y: 0.50),
                         leftFoot: .init(x: 0.92, y: 0.60), rightFoot: .init(x: 0.70, y: 0.62)),
            // KF4 — left leg swept back up on the opposite side, completing the circle
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.72, y: 0.28), rightKnee: .init(x: 0.62, y: 0.50),
                         leftFoot: .init(x: 0.88, y: 0.16), rightFoot: .init(x: 0.70, y: 0.62)),
        ])

    // MARK: - Elevación de piernas alternada (alternating leg raise, lying on back)

    static let legRaiseAlternating = StickmanAnimation(
        id: "legRaiseAlternating", displayName: "Elevación de piernas alternada", secondsPerBeat: 0.85,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.55, y: 0.16), rightKnee: .init(x: 0.70, y: 0.60),
                         leftFoot: .init(x: 0.60, y: 0.02), rightFoot: .init(x: 0.96, y: 0.60)),
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.70, y: 0.60), rightKnee: .init(x: 0.55, y: 0.16),
                         leftFoot: .init(x: 0.96, y: 0.60), rightFoot: .init(x: 0.60, y: 0.02)),
        ])

    // MARK: - Tijera de piernas (horizontal scissor, lying on back)

    static let legScissors = StickmanAnimation(
        id: "legScissors", displayName: "Tijera de piernas", secondsPerBeat: 0.55,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.62, y: 0.50), rightKnee: .init(x: 0.78, y: 0.50),
                         leftFoot: .init(x: 0.68, y: 0.50), rightFoot: .init(x: 0.88, y: 0.50)),
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.38, y: 0.50), rightKnee: .init(x: 0.54, y: 0.50),
                         leftFoot: .init(x: 0.28, y: 0.50), rightFoot: .init(x: 0.48, y: 0.50)),
        ])

    // MARK: - Windshield wipers / limpiaparabrisas (legs together, pendulum swing)

    static let windshieldWipers = StickmanAnimation(
        id: "windshieldWipers", displayName: "Windshield wipers (limpiaparabrisas)", secondsPerBeat: 1.0,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.52, y: 0.22), rightKnee: .init(x: 0.52, y: 0.22),
                         leftFoot: .init(x: 0.58, y: 0.08), rightFoot: .init(x: 0.58, y: 0.08)),
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.32, y: 0.22), rightKnee: .init(x: 0.32, y: 0.22),
                         leftFoot: .init(x: 0.26, y: 0.08), rightFoot: .init(x: 0.26, y: 0.08)),
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

    // MARK: - Bicycle crunch (alternating elbow-to-knee)

    static let bicycleCrunch = StickmanAnimation(
        id: "bicycleCrunch", displayName: "Bicycle crunch", secondsPerBeat: 0.55,
        keyframes: [
            StickmanPose(head: .init(x: 0.14, y: 0.50), neck: .init(x: 0.24, y: 0.52),
                         hip: .init(x: 0.50, y: 0.58),
                         leftShoulder: .init(x: 0.28, y: 0.52), rightShoulder: .init(x: 0.28, y: 0.54),
                         leftElbow: .init(x: 0.18, y: 0.38), rightElbow: .init(x: 0.38, y: 0.42),
                         leftHand: .init(x: 0.14, y: 0.28), rightHand: .init(x: 0.42, y: 0.34),
                         leftKnee: .init(x: 0.72, y: 0.36), rightKnee: .init(x: 0.68, y: 0.56),
                         leftFoot: .init(x: 0.82, y: 0.50), rightFoot: .init(x: 0.80, y: 0.60)),
            StickmanPose(head: .init(x: 0.14, y: 0.50), neck: .init(x: 0.24, y: 0.52),
                         hip: .init(x: 0.50, y: 0.58),
                         leftShoulder: .init(x: 0.28, y: 0.52), rightShoulder: .init(x: 0.28, y: 0.54),
                         leftElbow: .init(x: 0.38, y: 0.42), rightElbow: .init(x: 0.18, y: 0.38),
                         leftHand: .init(x: 0.42, y: 0.34), rightHand: .init(x: 0.14, y: 0.28),
                         leftKnee: .init(x: 0.68, y: 0.56), rightKnee: .init(x: 0.72, y: 0.36),
                         leftFoot: .init(x: 0.80, y: 0.60), rightFoot: .init(x: 0.82, y: 0.50)),
        ])

    // MARK: - Heel touches (lying on back, alternating side bends)

    static let heelTouches = StickmanAnimation(
        id: "heelTouches", displayName: "Toques de talón", secondsPerBeat: 0.65,
        keyframes: [
            StickmanPose(head: .init(x: 0.30, y: 0.50), neck: .init(x: 0.38, y: 0.52),
                         hip: .init(x: 0.50, y: 0.58),
                         leftShoulder: .init(x: 0.42, y: 0.52), rightShoulder: .init(x: 0.42, y: 0.54),
                         leftElbow: .init(x: 0.34, y: 0.40), rightElbow: .init(x: 0.50, y: 0.42),
                         leftHand: .init(x: 0.56, y: 0.62), rightHand: .init(x: 0.56, y: 0.62),
                         leftKnee: .init(x: 0.70, y: 0.38), rightKnee: .init(x: 0.72, y: 0.38),
                         leftFoot: .init(x: 0.82, y: 0.58), rightFoot: .init(x: 0.84, y: 0.58)),
            StickmanPose(head: .init(x: 0.30, y: 0.50), neck: .init(x: 0.38, y: 0.52),
                         hip: .init(x: 0.50, y: 0.58),
                         leftShoulder: .init(x: 0.42, y: 0.52), rightShoulder: .init(x: 0.42, y: 0.54),
                         leftElbow: .init(x: 0.50, y: 0.42), rightElbow: .init(x: 0.34, y: 0.40),
                         leftHand: .init(x: 0.44, y: 0.62), rightHand: .init(x: 0.44, y: 0.62),
                         leftKnee: .init(x: 0.70, y: 0.38), rightKnee: .init(x: 0.72, y: 0.38),
                         leftFoot: .init(x: 0.82, y: 0.58), rightFoot: .init(x: 0.84, y: 0.58)),
        ])

    // MARK: - V-twist / Russian twist (seated torso rotation)

    static let vTwist = StickmanAnimation(
        id: "vTwist", displayName: "V-twist (Russian twist)", secondsPerBeat: 0.6,
        keyframes: [
            StickmanPose(head: .init(x: 0.42, y: 0.18), neck: .init(x: 0.40, y: 0.26),
                         hip: .init(x: 0.46, y: 0.52),
                         leftShoulder: .init(x: 0.44, y: 0.28), rightShoulder: .init(x: 0.38, y: 0.28),
                         leftElbow: .init(x: 0.50, y: 0.34), rightElbow: .init(x: 0.34, y: 0.34),
                         leftHand: .init(x: 0.52, y: 0.40), rightHand: .init(x: 0.36, y: 0.40),
                         leftKnee: .init(x: 0.72, y: 0.30), rightKnee: .init(x: 0.72, y: 0.32),
                         leftFoot: .init(x: 0.88, y: 0.22), rightFoot: .init(x: 0.88, y: 0.24)),
            StickmanPose(head: .init(x: 0.36, y: 0.18), neck: .init(x: 0.38, y: 0.26),
                         hip: .init(x: 0.46, y: 0.52),
                         leftShoulder: .init(x: 0.42, y: 0.28), rightShoulder: .init(x: 0.36, y: 0.28),
                         leftElbow: .init(x: 0.48, y: 0.34), rightElbow: .init(x: 0.32, y: 0.34),
                         leftHand: .init(x: 0.50, y: 0.40), rightHand: .init(x: 0.34, y: 0.40),
                         leftKnee: .init(x: 0.72, y: 0.30), rightKnee: .init(x: 0.72, y: 0.32),
                         leftFoot: .init(x: 0.88, y: 0.22), rightFoot: .init(x: 0.88, y: 0.24)),
        ])

    // MARK: - Plancha con rodillas (beginner plank on knees)

    static let plankKnees = StickmanAnimation(
        id: "plankKnees", displayName: "Plancha con rodillas", secondsPerBeat: 1.4,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.34), neck: .init(x: 0.16, y: 0.37),
                         hip: .init(x: 0.52, y: 0.44),
                         leftShoulder: .init(x: 0.18, y: 0.39), rightShoulder: .init(x: 0.18, y: 0.41),
                         leftElbow: .init(x: 0.18, y: 0.57), rightElbow: .init(x: 0.18, y: 0.59),
                         leftHand: .init(x: 0.13, y: 0.64), rightHand: .init(x: 0.13, y: 0.66),
                         leftKnee: .init(x: 0.70, y: 0.58), rightKnee: .init(x: 0.70, y: 0.60),
                         leftFoot: .init(x: 0.90, y: 0.66), rightFoot: .init(x: 0.90, y: 0.68)),
            StickmanPose(head: .init(x: 0.06, y: 0.36), neck: .init(x: 0.16, y: 0.39),
                         hip: .init(x: 0.52, y: 0.48),
                         leftShoulder: .init(x: 0.18, y: 0.41), rightShoulder: .init(x: 0.18, y: 0.43),
                         leftElbow: .init(x: 0.18, y: 0.58), rightElbow: .init(x: 0.18, y: 0.60),
                         leftHand: .init(x: 0.13, y: 0.64), rightHand: .init(x: 0.13, y: 0.66),
                         leftKnee: .init(x: 0.70, y: 0.60), rightKnee: .init(x: 0.70, y: 0.62),
                         leftFoot: .init(x: 0.90, y: 0.66), rightFoot: .init(x: 0.90, y: 0.68)),
        ])

    // MARK: - Plancha alta (high plank / push-up position)

    static let highPlank = StickmanAnimation(
        id: "highPlank", displayName: "Plancha alta", secondsPerBeat: 1.4,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.16), neck: .init(x: 0.16, y: 0.20),
                         hip: .init(x: 0.55, y: 0.28),
                         leftShoulder: .init(x: 0.18, y: 0.22), rightShoulder: .init(x: 0.18, y: 0.24),
                         leftElbow: .init(x: 0.18, y: 0.38), rightElbow: .init(x: 0.18, y: 0.40),
                         leftHand: .init(x: 0.18, y: 0.56), rightHand: .init(x: 0.18, y: 0.58),
                         leftKnee: .init(x: 0.85, y: 0.30), rightKnee: .init(x: 0.85, y: 0.32),
                         leftFoot: .init(x: 0.96, y: 0.56), rightFoot: .init(x: 0.96, y: 0.58)),
            StickmanPose(head: .init(x: 0.06, y: 0.18), neck: .init(x: 0.16, y: 0.22),
                         hip: .init(x: 0.55, y: 0.32),
                         leftShoulder: .init(x: 0.18, y: 0.24), rightShoulder: .init(x: 0.18, y: 0.26),
                         leftElbow: .init(x: 0.18, y: 0.40), rightElbow: .init(x: 0.18, y: 0.42),
                         leftHand: .init(x: 0.18, y: 0.56), rightHand: .init(x: 0.18, y: 0.58),
                         leftKnee: .init(x: 0.85, y: 0.32), rightKnee: .init(x: 0.85, y: 0.34),
                         leftFoot: .init(x: 0.96, y: 0.56), rightFoot: .init(x: 0.96, y: 0.58)),
        ])

    // MARK: - Plancha con elevación de piernas (alternating leg raise from plank)

    static let plankLegRaise = StickmanAnimation(
        id: "plankLegRaise", displayName: "Plancha con elevación de piernas", secondsPerBeat: 0.9,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.30), neck: .init(x: 0.16, y: 0.33),
                         hip: .init(x: 0.55, y: 0.40),
                         leftShoulder: .init(x: 0.18, y: 0.35), rightShoulder: .init(x: 0.18, y: 0.37),
                         leftElbow: .init(x: 0.18, y: 0.55), rightElbow: .init(x: 0.18, y: 0.57),
                         leftHand: .init(x: 0.13, y: 0.62), rightHand: .init(x: 0.13, y: 0.64),
                         leftKnee: .init(x: 0.85, y: 0.42), rightKnee: .init(x: 0.85, y: 0.44),
                         leftFoot: .init(x: 0.96, y: 0.60), rightFoot: .init(x: 0.96, y: 0.62)),
            StickmanPose(head: .init(x: 0.06, y: 0.28), neck: .init(x: 0.16, y: 0.31),
                         hip: .init(x: 0.55, y: 0.38),
                         leftShoulder: .init(x: 0.18, y: 0.33), rightShoulder: .init(x: 0.18, y: 0.35),
                         leftElbow: .init(x: 0.18, y: 0.53), rightElbow: .init(x: 0.18, y: 0.55),
                         leftHand: .init(x: 0.13, y: 0.62), rightHand: .init(x: 0.13, y: 0.64),
                         leftKnee: .init(x: 0.85, y: 0.40), rightKnee: .init(x: 0.85, y: 0.42),
                         leftFoot: .init(x: 0.96, y: 0.38), rightFoot: .init(x: 0.96, y: 0.62)),
        ])

    // MARK: - Plancha spiderman (knee to same-side elbow, lateral)

    static let spidermanPlank = StickmanAnimation(
        id: "spidermanPlank", displayName: "Plancha spiderman", secondsPerBeat: 0.7,
        keyframes: [
            StickmanPose(head: .init(x: 0.06, y: 0.16), neck: .init(x: 0.16, y: 0.20),
                         hip: .init(x: 0.55, y: 0.28),
                         leftShoulder: .init(x: 0.18, y: 0.22), rightShoulder: .init(x: 0.18, y: 0.24),
                         leftElbow: .init(x: 0.18, y: 0.38), rightElbow: .init(x: 0.18, y: 0.40),
                         leftHand: .init(x: 0.18, y: 0.56), rightHand: .init(x: 0.18, y: 0.58),
                         leftKnee: .init(x: 0.55, y: 0.48), rightKnee: .init(x: 0.88, y: 0.32),
                         leftFoot: .init(x: 0.65, y: 0.62), rightFoot: .init(x: 0.98, y: 0.56)),
            StickmanPose(head: .init(x: 0.06, y: 0.16), neck: .init(x: 0.16, y: 0.20),
                         hip: .init(x: 0.55, y: 0.28),
                         leftShoulder: .init(x: 0.18, y: 0.22), rightShoulder: .init(x: 0.18, y: 0.24),
                         leftElbow: .init(x: 0.18, y: 0.38), rightElbow: .init(x: 0.18, y: 0.40),
                         leftHand: .init(x: 0.18, y: 0.56), rightHand: .init(x: 0.18, y: 0.58),
                         leftKnee: .init(x: 0.88, y: 0.32), rightKnee: .init(x: 0.55, y: 0.12),
                         leftFoot: .init(x: 0.98, y: 0.56), rightFoot: .init(x: 0.65, y: 0.00)),
        ])

    // MARK: - Plancha superman (arms extended forward toward ground)

    static let supermanPlank = StickmanAnimation(
        id: "supermanPlank", displayName: "Plancha superman", secondsPerBeat: 1.2,
        keyframes: [
            StickmanPose(head: .init(x: 0.04, y: 0.22), neck: .init(x: 0.12, y: 0.25),
                         hip: .init(x: 0.55, y: 0.34),
                         leftShoulder: .init(x: 0.14, y: 0.27), rightShoulder: .init(x: 0.14, y: 0.29),
                         leftElbow: .init(x: 0.06, y: 0.34), rightElbow: .init(x: 0.06, y: 0.36),
                         leftHand: .init(x: 0.02, y: 0.44), rightHand: .init(x: 0.02, y: 0.46),
                         leftKnee: .init(x: 0.85, y: 0.36), rightKnee: .init(x: 0.85, y: 0.38),
                         leftFoot: .init(x: 0.96, y: 0.54), rightFoot: .init(x: 0.96, y: 0.56)),
            StickmanPose(head: .init(x: 0.04, y: 0.24), neck: .init(x: 0.12, y: 0.27),
                         hip: .init(x: 0.55, y: 0.38),
                         leftShoulder: .init(x: 0.14, y: 0.29), rightShoulder: .init(x: 0.14, y: 0.31),
                         leftElbow: .init(x: 0.06, y: 0.36), rightElbow: .init(x: 0.06, y: 0.38),
                         leftHand: .init(x: 0.02, y: 0.46), rightHand: .init(x: 0.02, y: 0.48),
                         leftKnee: .init(x: 0.85, y: 0.38), rightKnee: .init(x: 0.85, y: 0.40),
                         leftFoot: .init(x: 0.96, y: 0.54), rightFoot: .init(x: 0.96, y: 0.56)),
        ])

    // MARK: - Toe touch cruzado (cross toe touch — lying on back, diagonal reach)

    static let crossToeTouch = StickmanAnimation(
        id: "crossToeTouch", displayName: "Toe touch cruzado", secondsPerBeat: 0.85,
        keyframes: [
            // Keyframe 1: LEFT leg raised, RIGHT arm reaches across toward left foot.
            StickmanPose(head: .init(x: 0.26, y: 0.32), neck: .init(x: 0.34, y: 0.38),
                         hip: .init(x: 0.50, y: 0.62),
                         leftShoulder: .init(x: 0.38, y: 0.48), rightShoulder: .init(x: 0.38, y: 0.44),
                         leftElbow: .init(x: 0.28, y: 0.58), rightElbow: .init(x: 0.30, y: 0.34),
                         leftHand: .init(x: 0.22, y: 0.64), rightHand: .init(x: 0.26, y: 0.22),
                         leftKnee: .init(x: 0.52, y: 0.18), rightKnee: .init(x: 0.72, y: 0.62),
                         leftFoot: .init(x: 0.56, y: 0.04), rightFoot: .init(x: 0.88, y: 0.64)),
            // Keyframe 2: RIGHT leg raised, LEFT arm reaches across toward right foot.
            StickmanPose(head: .init(x: 0.26, y: 0.32), neck: .init(x: 0.34, y: 0.38),
                         hip: .init(x: 0.50, y: 0.62),
                         leftShoulder: .init(x: 0.38, y: 0.44), rightShoulder: .init(x: 0.38, y: 0.48),
                         leftElbow: .init(x: 0.30, y: 0.34), rightElbow: .init(x: 0.28, y: 0.58),
                         leftHand: .init(x: 0.26, y: 0.22), rightHand: .init(x: 0.22, y: 0.64),
                          leftKnee: .init(x: 0.72, y: 0.62), rightKnee: .init(x: 0.52, y: 0.18),
                         leftFoot: .init(x: 0.88, y: 0.64), rightFoot: .init(x: 0.56, y: 0.04)),
        ])

    // MARK: - Tuck crunch apoyado (supported knee tuck — seated, hands behind)

    static let supportedKneeTuck = StickmanAnimation(
        id: "supportedKneeTuck", displayName: "Tuck crunch apoyado", secondsPerBeat: 0.9,
        keyframes: [
            // KF1 — extended: legs straight together, extended forward and slightly up.
            StickmanPose(head: .init(x: 0.16, y: 0.32), neck: .init(x: 0.26, y: 0.36),
                         hip: .init(x: 0.48, y: 0.58),
                         leftShoulder: .init(x: 0.30, y: 0.40), rightShoulder: .init(x: 0.30, y: 0.42),
                         leftElbow: .init(x: 0.22, y: 0.50), rightElbow: .init(x: 0.22, y: 0.52),
                         leftHand: .init(x: 0.36, y: 0.62), rightHand: .init(x: 0.36, y: 0.64),
                         leftKnee: .init(x: 0.68, y: 0.46), rightKnee: .init(x: 0.68, y: 0.48),
                         leftFoot: .init(x: 0.88, y: 0.42), rightFoot: .init(x: 0.88, y: 0.44)),
            // KF2 — tucked: knees bend and draw in close to chest, feet toward hips.
            StickmanPose(head: .init(x: 0.16, y: 0.32), neck: .init(x: 0.26, y: 0.36),
                         hip: .init(x: 0.48, y: 0.58),
                         leftShoulder: .init(x: 0.30, y: 0.40), rightShoulder: .init(x: 0.30, y: 0.42),
                         leftElbow: .init(x: 0.22, y: 0.50), rightElbow: .init(x: 0.22, y: 0.52),
                         leftHand: .init(x: 0.36, y: 0.62), rightHand: .init(x: 0.36, y: 0.64),
                         leftKnee: .init(x: 0.56, y: 0.36), rightKnee: .init(x: 0.56, y: 0.38),
                         leftFoot: .init(x: 0.50, y: 0.50), rightFoot: .init(x: 0.50, y: 0.52)),
        ])

    // MARK: - Sit-up en diamante / butterfly sit-up (legs fixed in diamond)

    static let butterflySitUp = StickmanAnimation(
        id: "butterflySitUp", displayName: "Sit-up en diamante (butterfly)", secondsPerBeat: 1.0,
        keyframes: [
            // KF1 — down: torso flat on ground, arms extended straight overhead past head.
            StickmanPose(head: .init(x: 0.06, y: 0.62), neck: .init(x: 0.14, y: 0.62),
                         hip: .init(x: 0.50, y: 0.62),
                         leftShoulder: .init(x: 0.18, y: 0.61), rightShoulder: .init(x: 0.18, y: 0.63),
                         leftElbow: .init(x: 0.10, y: 0.54), rightElbow: .init(x: 0.10, y: 0.56),
                         leftHand: .init(x: 0.04, y: 0.46), rightHand: .init(x: 0.04, y: 0.48),
                         leftKnee: .init(x: 0.36, y: 0.60), rightKnee: .init(x: 0.64, y: 0.60),
                         leftFoot: .init(x: 0.52, y: 0.66), rightFoot: .init(x: 0.52, y: 0.68)),
            // KF2 — up: full sit-up, torso vertical/forward, arms reach forward past knees toward feet.
            StickmanPose(head: .init(x: 0.46, y: 0.28), neck: .init(x: 0.44, y: 0.34),
                         hip: .init(x: 0.50, y: 0.62),
                         leftShoulder: .init(x: 0.46, y: 0.36), rightShoulder: .init(x: 0.46, y: 0.38),
                         leftElbow: .init(x: 0.52, y: 0.44), rightElbow: .init(x: 0.52, y: 0.46),
                         leftHand: .init(x: 0.56, y: 0.54), rightHand: .init(x: 0.56, y: 0.56),
                         leftKnee: .init(x: 0.36, y: 0.60), rightKnee: .init(x: 0.64, y: 0.60),
                         leftFoot: .init(x: 0.52, y: 0.66), rightFoot: .init(x: 0.52, y: 0.68)),
        ])

    // MARK: - Rodilla al pecho alternada (alternating knee tucks, lying on back)

    static let alternatingKneeTucks = StickmanAnimation(
        id: "alternatingKneeTucks", displayName: "Rodilla al pecho alternada", secondsPerBeat: 0.85,
        keyframes: [
            // KF1 — LEFT knee draws toward chest, RIGHT leg straight and low.
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.52, y: 0.34), rightKnee: .init(x: 0.70, y: 0.58),
                         leftFoot: .init(x: 0.46, y: 0.50), rightFoot: .init(x: 0.96, y: 0.58)),
            // KF2 — RIGHT knee draws toward chest, LEFT leg straight and low.
            StickmanPose(head: .init(x: 0.06, y: 0.56), neck: .init(x: 0.16, y: 0.56),
                         hip: .init(x: 0.42, y: 0.58),
                         leftShoulder: .init(x: 0.18, y: 0.55), rightShoulder: .init(x: 0.18, y: 0.57),
                         leftElbow: .init(x: 0.10, y: 0.48), rightElbow: .init(x: 0.10, y: 0.50),
                         leftHand: .init(x: 0.06, y: 0.40), rightHand: .init(x: 0.06, y: 0.42),
                         leftKnee: .init(x: 0.70, y: 0.58), rightKnee: .init(x: 0.52, y: 0.34),
                         leftFoot: .init(x: 0.96, y: 0.58), rightFoot: .init(x: 0.46, y: 0.50)),
        ])

    // MARK: - Hollow body hold / V-sit isométrico (isometric, subtle sway)

    static let hollowHold = StickmanAnimation(
        id: "hollowHold", displayName: "Hollow body hold (V-sit isométrico)", secondsPerBeat: 1.4,
        keyframes: [
            // KF1 — V-sit hold, arms forward, legs up. Tiny wobble.
            StickmanPose(head: .init(x: 0.40, y: 0.22), neck: .init(x: 0.38, y: 0.28),
                         hip: .init(x: 0.46, y: 0.52),
                         leftShoulder: .init(x: 0.40, y: 0.30), rightShoulder: .init(x: 0.40, y: 0.32),
                         leftElbow: .init(x: 0.48, y: 0.36), rightElbow: .init(x: 0.48, y: 0.38),
                         leftHand: .init(x: 0.56, y: 0.40), rightHand: .init(x: 0.56, y: 0.42),
                         leftKnee: .init(x: 0.72, y: 0.30), rightKnee: .init(x: 0.72, y: 0.32),
                         leftFoot: .init(x: 0.88, y: 0.22), rightFoot: .init(x: 0.88, y: 0.24)),
            // KF2 — Same pose, micro-shift down (breathing wobble).
            StickmanPose(head: .init(x: 0.40, y: 0.24), neck: .init(x: 0.38, y: 0.30),
                         hip: .init(x: 0.46, y: 0.52),
                         leftShoulder: .init(x: 0.40, y: 0.32), rightShoulder: .init(x: 0.40, y: 0.34),
                         leftElbow: .init(x: 0.48, y: 0.38), rightElbow: .init(x: 0.48, y: 0.40),
                         leftHand: .init(x: 0.56, y: 0.42), rightHand: .init(x: 0.56, y: 0.44),
                         leftKnee: .init(x: 0.72, y: 0.32), rightKnee: .init(x: 0.72, y: 0.34),
                         leftFoot: .init(x: 0.88, y: 0.24), rightFoot: .init(x: 0.88, y: 0.26)),
        ])

    // MARK: - Extensión total isométrica (flat supine hold, subtle breathing sway)

    static let flatExtendedHold = StickmanAnimation(
        id: "flatExtendedHold", displayName: "Extensión total isométrica", secondsPerBeat: 1.4,
        keyframes: [
            StickmanPose(head: .init(x: 0.14, y: 0.62), neck: .init(x: 0.22, y: 0.62),
                         hip: .init(x: 0.52, y: 0.62),
                         leftShoulder: .init(x: 0.24, y: 0.61), rightShoulder: .init(x: 0.24, y: 0.63),
                         leftElbow: .init(x: 0.10, y: 0.61), rightElbow: .init(x: 0.10, y: 0.63),
                         leftHand: .init(x: 0.02, y: 0.61), rightHand: .init(x: 0.02, y: 0.63),
                         leftKnee: .init(x: 0.74, y: 0.61), rightKnee: .init(x: 0.74, y: 0.63),
                         leftFoot: .init(x: 0.96, y: 0.61), rightFoot: .init(x: 0.96, y: 0.63)),
            StickmanPose(head: .init(x: 0.14, y: 0.63), neck: .init(x: 0.22, y: 0.63),
                         hip: .init(x: 0.52, y: 0.63),
                         leftShoulder: .init(x: 0.24, y: 0.62), rightShoulder: .init(x: 0.24, y: 0.64),
                         leftElbow: .init(x: 0.10, y: 0.62), rightElbow: .init(x: 0.10, y: 0.64),
                         leftHand: .init(x: 0.02, y: 0.62), rightHand: .init(x: 0.02, y: 0.64),
                         leftKnee: .init(x: 0.74, y: 0.62), rightKnee: .init(x: 0.74, y: 0.64),
                         leftFoot: .init(x: 0.96, y: 0.62), rightFoot: .init(x: 0.96, y: 0.64)),
        ])

    // MARK: - V-up completo (flat to V, both legs + torso rise together)

    static let vUp = StickmanAnimation(
        id: "vUp", displayName: "V-up completo", secondsPerBeat: 1.0,
        keyframes: [
            // KF1 — down: flat on back, arms overhead, legs straight and low.
            StickmanPose(head: .init(x: 0.06, y: 0.62), neck: .init(x: 0.14, y: 0.62),
                         hip: .init(x: 0.46, y: 0.62),
                         leftShoulder: .init(x: 0.18, y: 0.61), rightShoulder: .init(x: 0.18, y: 0.63),
                         leftElbow: .init(x: 0.10, y: 0.54), rightElbow: .init(x: 0.10, y: 0.56),
                         leftHand: .init(x: 0.04, y: 0.46), rightHand: .init(x: 0.04, y: 0.48),
                         leftKnee: .init(x: 0.70, y: 0.60), rightKnee: .init(x: 0.70, y: 0.62),
                         leftFoot: .init(x: 0.96, y: 0.60), rightFoot: .init(x: 0.96, y: 0.62)),
            // KF2 — up: torso + straight legs rise into V, arms reach toward feet, hip lifts slightly.
            StickmanPose(head: .init(x: 0.38, y: 0.24), neck: .init(x: 0.36, y: 0.30),
                         hip: .init(x: 0.46, y: 0.50),
                         leftShoulder: .init(x: 0.38, y: 0.32), rightShoulder: .init(x: 0.38, y: 0.34),
                         leftElbow: .init(x: 0.46, y: 0.38), rightElbow: .init(x: 0.46, y: 0.40),
                         leftHand: .init(x: 0.54, y: 0.42), rightHand: .init(x: 0.54, y: 0.44),
                         leftKnee: .init(x: 0.72, y: 0.30), rightKnee: .init(x: 0.72, y: 0.32),
                         leftFoot: .init(x: 0.88, y: 0.22), rightFoot: .init(x: 0.88, y: 0.24)),
        ])
}
