import GameplayKit
import SpriteKit

class GameScene: SKScene {
    let player = Player()

    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "background_1")
        bg.zPosition = Layer.background.rawValue
        bg.anchorPoint = .zero
        // This isn't really needed because 0,0 is the default position.
        bg.position = .zero
        addChild(bg)

        let fgHeight = 140.0
        let fg = SKSpriteNode(imageNamed: "foreground_1")
        fg.zPosition = Layer.foreground.rawValue
        // fg.anchorPoint = .zero
        fg.anchorPoint = CGPoint(x: 0, y: 1)
        // fg.position = .zero
        fg.position = CGPoint(x: 0, y: fgHeight)
        addChild(fg)

        player.anchorPoint = CGPoint(x: 0.5, y: 0)
        // player.position = CGPoint(x: size.width / 2, y: fg.frame.maxY)
        player.position = CGPoint(x: size.width / 2, y: fgHeight)
        addChild(player)

        player.walk()
    }

    func touchDown(atPoint point: CGPoint) {
        print("\(#fileID) \(#function) point =", point)
        player.moveTo(point, duration: 1.0)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchDown(atPoint: touch.location(in: self))
        }
    }
}
