import GameplayKit
import SpriteKit

class GameScene: SKScene {
    // Constants
    private let minDropSpeed = 0.12 // fastest
    private let maxDropSpeed = 1.0 // slowest

    private var dropCount = 10
    private var dropSpeed = 1.0
    private var isMoving = false
    private var lastPosition: CGPoint?
    private var level = 1
    private let player = Player()

    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "background_1")
        bg.zPosition = Layer.background.rawValue
        bg.anchorPoint = .zero
        // This isn't really needed because 0,0 is the default position.
        bg.position = .zero
        addChild(bg)

        let fg = SKSpriteNode(imageNamed: "foreground_1")
        fg.zPosition = Layer.foreground.rawValue
        fg.anchorPoint = .lowerLeft
        fg.position = .lowerLeft
        fg.physicsBody = SKPhysicsBody(edgeLoopFrom: fg.frame)
        fg.physicsBody?.affectedByGravity = false
        fg.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        fg.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        fg.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(fg)

        player.anchorPoint = .bottom
        player.position = CGPoint(x: size.width / 2, y: fg.frame.maxY)
        player.setupConstraints(floor: fg.frame.maxY)
        addChild(player)

        physicsWorld.contactDelegate = self

        player.walk()
        spawnGloops()
    }

    private func spawnGloop() {
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

    private func spawnGloops() {
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
            let point = touch.location(in: self)
            let node = atPoint(point)
            if node.name == "player" { isMoving = true }
            player.moveTo(point)
        }
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        for touch in touches {
            touchUp(atPoint: touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchUp(atPoint: touch.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchMoved(toPoint: t.location(in: self))
        }
    }

    private func touchMoved(toPoint point: CGPoint) {
        guard isMoving else { return }

        let newPoint = CGPoint(x: point.x, y: player.position.y)
        player.position = newPoint

        // Update facing direction of player.
        let oldPoint = lastPosition ?? player.position
        player.xScale = (newPoint.x < oldPoint.x ? -1 : 1) * abs(xScale)

        lastPosition = newPoint
    }

    // This is called when a touch ends (finger is removed).
    private func touchUp(atPoint point: CGPoint) {
        isMoving = false
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        let maskA = bodyA.categoryBitMask
        let maskB = bodyB.categoryBitMask
        let collision = maskA | maskB

        // Determine if either PhysicsBody is associated with a Collectible.
        let body = maskA == PhysicsCategory.collectible ?
            bodyA.node : bodyB.node
        if let sprite = body as? Collectible {
            // If a Collectible collided with the player ...
            if collision ==
                PhysicsCategory.collectible | PhysicsCategory.player {
                sprite.collected()
            }
            // If a Collectible collided with the floor ...
            if collision ==
                PhysicsCategory.collectible | PhysicsCategory.foreground {
                sprite.missed()
            }
        }
    }
}
