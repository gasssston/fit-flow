#if os(iOS)
import SceneKit
import SwiftUI
import UIKit

struct Model3DView: UIViewRepresentable {
    let animation: StickmanAnimation

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        view.backgroundColor = .clear
        context.coordinator.installCharacter(in: view)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.playAnimation(for: animation.id)
    }

    final class Coordinator {
        private var characterNode: SCNNode?
        private var currentExerciseID: String?

        func installCharacter(in view: SCNView) {
            let scene = SCNScene()
            let character = SCNNode()
            character.name = "FitFlowCharacter"

            // TODO: Export a rigged Character.dae and per-exercise clips from
            // Mixamo (mixamo.com), drop them in Models3D, and add clip filenames
            // to Model3DAnimationCatalog.
            if let characterScene = loadScene(named: "Character") {
                for node in characterScene.rootNode.childNodes {
                    character.addChildNode(node.clone())
                }
            } else {
                let box = SCNBox(width: 1.2, height: 2, length: 0.8, chamferRadius: 0.12)
                box.firstMaterial?.diffuse.contents = UIColor.systemOrange
                character.addChildNode(SCNNode(geometry: box))
            }

            scene.rootNode.addChildNode(character)
            view.scene = scene
            view.pointOfView = addCamera(to: scene)
            characterNode = character
        }

        func playAnimation(for exerciseID: String) {
            guard currentExerciseID != exerciseID else { return }
            currentExerciseID = exerciseID
            stopAnimations()

            guard let characterNode,
                  let filename = Model3DAnimationCatalog.filenamesByExerciseID[exerciseID] else { return }

            // USDZ clips are self-contained so materials, skin, rig, and motion
            // always stay compatible. DAE remains supported for separate clips.
            if let exerciseScene = loadScene(named: filename, extensions: ["usdz"]) {
                characterNode.childNodes.forEach { $0.removeFromParentNode() }
                for node in exerciseScene.rootNode.childNodes {
                    characterNode.addChildNode(node.clone())
                }
                playEmbeddedAnimations(in: characterNode)
                return
            }

            guard let animationScene = loadScene(named: filename, extensions: ["dae"]) else { return }

            applyAnimations(from: animationScene.rootNode, to: characterNode)
        }

        private func loadScene(
            named name: String,
            extensions: [String] = ["usdz", "dae"]
        ) -> SCNScene? {
            for fileExtension in extensions {
                guard let url = Bundle.main.url(
                    forResource: name,
                    withExtension: fileExtension,
                    subdirectory: "Models3D"
                ) else { continue }
                if let scene = try? SCNScene(url: url) {
                    return scene
                }
            }
            return nil
        }

        private func playEmbeddedAnimations(in node: SCNNode) {
            for key in node.animationKeys {
                guard let player = node.animationPlayer(forKey: key) else { continue }
                player.animation.repeatCount = .greatestFiniteMagnitude
                player.play()
            }
            node.childNodes.forEach(playEmbeddedAnimations)
        }

        private func applyAnimations(from sourceNode: SCNNode, to characterNode: SCNNode) {
            let destination = sourceNode.name.flatMap {
                characterNode.childNode(withName: $0, recursively: true)
            } ?? characterNode

            for key in sourceNode.animationKeys {
                guard let sourcePlayer = sourceNode.animationPlayer(forKey: key) else { continue }
                let player = SCNAnimationPlayer(animation: sourcePlayer.animation)
                player.animation.repeatCount = .greatestFiniteMagnitude
                destination.addAnimationPlayer(player, forKey: "fitflow.\(key)")
                player.play()
            }

            for child in sourceNode.childNodes {
                applyAnimations(from: child, to: characterNode)
            }
        }

        private func stopAnimations() {
            guard let characterNode else { return }
            characterNode.enumerateChildNodes { node, _ in
                node.removeAllAnimations()
            }
            characterNode.removeAllAnimations()
        }

        private func addCamera(to scene: SCNScene) -> SCNNode {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(-2.2, 0.15, 0.8)
            cameraNode.look(
                at: SCNVector3(0, 0.15, 0.8),
                up: SCNVector3(0, 1, 0),
                localFront: SCNVector3(0, 0, -1)
            )
            cameraNode.simdLocalRotate(
                by: simd_quatf(angle: -.pi / 2, axis: SIMD3(0, 0, 1))
            )
            scene.rootNode.addChildNode(cameraNode)
            return cameraNode
        }
    }
}
#endif
