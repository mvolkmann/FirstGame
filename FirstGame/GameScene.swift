import GameplayKit
import SpriteKit

class GameScene: SKScene {
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

        let player = Player()
        player.anchorPoint = CGPoint(x: 0.5, y: 0)
        // player.position = CGPoint(x: size.width / 2, y: fg.frame.maxY)
        player.position = CGPoint(x: size.width / 2, y: fgHeight)
        addChild(player)

        player.walk()
    }
}
