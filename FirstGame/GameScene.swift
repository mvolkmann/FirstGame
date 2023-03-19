import GameplayKit
import SpriteKit

class GameScene: SKScene {
    var dropCount = 10
    var dropSpeed = 1.0
    var level = 1
    let minDropSpeed = 0.12 // fastest
    let maxDropSpeed = 1.0 // slowest
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
        spawnGloops()
    }

    func spawnGloop() {
        let gloop = Collectible(type: CollectibleType.gloop)

        let margin = gloop.size.width * 2
        let minX = frame.minX + margin
        let maxX = frame.maxX - margin

        gloop.position = CGPoint(
            x: CGFloat.random(in: minX ... maxX),
            y: player.position.y * 5
        )

        addChild(gloop)

        gloop.drop(duration: TimeInterval(1.0), level: player.frame.minY)
    }

    func spawnGloops() {
        let dropCount = level * 10
        let proposedSpeed = 1.0 /
            (Double(level) + (Double(level) / Double(dropCount)))
        dropSpeed = max(min(proposedSpeed, maxDropSpeed), minDropSpeed)

        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        // Use `unowned` instead of `weak` when you are
        // certain that `self` will never become `nil`.
        // Here the `GameScene` object never goes away.
        let spawn = SKAction.run { [unowned self] in self.spawnGloop() }
        let sequence = SKAction.sequence([wait, spawn])
        // `repeat` is a keyword.
        let repeatAction = SKAction.repeat(sequence, count: dropCount)
        run(repeatAction, withKey: "gloops")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            player.moveTo(touch.location(in: self))
        }
    }
}
