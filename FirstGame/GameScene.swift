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
        fg.anchorPoint = .upperLeft
        fg.position = CGPoint(x: 0, y: fgHeight)
        addChild(fg)

        player.anchorPoint = .bottom
        player.position = CGPoint(x: size.width / 2, y: fgHeight)
        player.setupConstraints(floor: fg.frame.maxY)
        addChild(player)

        player.walk()
        spawnGloop()
    }

    func spawnGloop() {
        let gloop = Collectible(type: CollectibleType.gloop)
        gloop.position = CGPoint(
            x: player.position.x,
            y: player.position.y * 2.5
        )
        addChild(gloop)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            player.moveTo(touch.location(in: self))
        }
    }
}
