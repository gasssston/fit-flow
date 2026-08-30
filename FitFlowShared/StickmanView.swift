import SwiftUI

/// Renders a `StickmanAnimation` as a live-animated vector figure using
/// SwiftUI's `Canvas` — no images, no WebView/iframe, no external assets.
struct StickmanView: View {
    let animation: StickmanAnimation
    var strokeColor: Color = .primary
    var jointColor: Color = .accentColor

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let pose = animation.pose(at: elapsed)
                draw(pose: pose, in: &context, size: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(animation.displayName)
    }

    private func draw(pose: StickmanPose, in context: inout GraphicsContext, size: CGSize) {
        // Keep extreme poses and the head inside the canvas instead of clipping at its edges.
        let box = min(size.width, size.height) * 0.84
        let origin = CGPoint(x: (size.width - box) / 2, y: (size.height - box) / 2)
        func p(_ point: CGPoint) -> CGPoint {
            CGPoint(x: origin.x + point.x * box, y: origin.y + point.y * box)
        }

        let limbWidth: CGFloat = box * 0.03
        var skeleton = Path()

        func bone(_ a: CGPoint, _ b: CGPoint) {
            skeleton.move(to: p(a))
            skeleton.addLine(to: p(b))
        }

        // torso
        bone(pose.neck, pose.hip)
        // arms
        bone(pose.leftShoulder, pose.leftElbow); bone(pose.leftElbow, pose.leftHand)
        bone(pose.rightShoulder, pose.rightElbow); bone(pose.rightElbow, pose.rightHand)
        bone(pose.neck, pose.leftShoulder); bone(pose.neck, pose.rightShoulder)
        // legs
        bone(pose.hip, pose.leftKnee); bone(pose.leftKnee, pose.leftFoot)
        bone(pose.hip, pose.rightKnee); bone(pose.rightKnee, pose.rightFoot)

        context.stroke(skeleton, with: .color(strokeColor), style: StrokeStyle(lineWidth: limbWidth, lineCap: .round, lineJoin: .round))

        // head
        let headRadius = box * 0.075
        let headCenter = p(pose.head)
        let headRect = CGRect(x: headCenter.x - headRadius, y: headCenter.y - headRadius, width: headRadius * 2, height: headRadius * 2)
        context.fill(Path(ellipseIn: headRect), with: .color(strokeColor))

        // joints (small dots for a livelier, "sporty" line-art look)
        for joint in [pose.leftElbow, pose.rightElbow, pose.leftHand, pose.rightHand,
                      pose.leftKnee, pose.rightKnee, pose.leftFoot, pose.rightFoot, pose.hip] {
            let c = p(joint)
            let r: CGFloat = box * 0.014
            context.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)), with: .color(jointColor))
        }
    }
}

#Preview {
    ExerciseVisualizerView(animation: StickmanPoseLibrary.commandoPlank)
        .padding()
}
