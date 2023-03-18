import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = view as! SKView? {
            // let scene = GameScene(size: view.bounds.size)
            // This matches the background_1 image sizes.
            let scene = GameScene(size: CGSize(width: 1336, height: 1024))

            scene.scaleMode = .aspectFill
            scene.backgroundColor = UIColor(
                red: 105 / 255,
                green: 157 / 255,
                blue: 181 / 255,
                alpha: 1.0
            )
            view.presentScene(scene)
            view.ignoresSiblingOrder = false
            view.showsPhysics = false
            view.showsFPS = true // frames per second
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
