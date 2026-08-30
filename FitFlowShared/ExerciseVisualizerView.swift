import SwiftUI

struct ExerciseVisualizerView: View {
    let animation: StickmanAnimation
    var strokeColor: Color = .primary
    var jointColor: Color = .accentColor

    var body: some View {
        StickmanView(
            animation: animation,
            strokeColor: strokeColor,
            jointColor: jointColor
        )
    }
}

#Preview {
    ExerciseVisualizerView(animation: StickmanPoseLibrary.commandoPlank)
        .padding()
}
