import GameplayKit
import SpriteKit

class GameScene: SKScene {
    // Constants
    private let minDropSpeed = 0.12 // fastest
    private let maxDropSpeed = 1.0 // slowest

    private var dropCount = 10
    private var dropsCollected = 0
    private var dropsExpected = 10

    // This determines how long to wait before creating the next drop.
    private var dropSpeed = 1.0

    private var gameInProgress = false
    private var isMoving = false
    private var lastPosition: CGPoint?

    private var level = 1 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }

    private var levelLabel = SKLabelNode()
    private let player = Player()
    private let playerSpeed = 1.5
    private var prevDropLocation = 0.0

    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    private var scoreLabel = SKLabelNode()

    private func checkForRemainingDrops() {
        if dropsCollected == dropsExpected {
            nextLevel()
        }
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self

        let bg = SKSpriteNode(imageNamed: "background_1")
        bg.zPosition = Layer.background.rawValue
        bg.anchorPoint = .zero
        // This isn't really needed because 0,0 is the default position.
        bg.position = .zero
        addChild(bg)

        let fg = SKSpriteNode(imageNamed: "foreground_1")
        fg.zPosition = Layer.foreground.rawValue
        fg.anchorPoint = .zero
        fg.position = .zero
        fg.physicsBody = SKPhysicsBody(edgeLoopFrom: fg.frame)
        fg.physicsBody?.affectedByGravity = false
        fg.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        fg.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        fg.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(fg)

        setupLabels()

        player.anchorPoint = .bottom
        player.position = CGPoint(x: size.width / 2, y: fg.frame.maxY)
        player.setupConstraints(floor: fg.frame.maxY)
        addChild(player)

        showMessage("Tap to start game")
    }

    private func gameOver() {
        guard gameInProgress else { return }

        showMessage("Game Over\nTap to try again")

        gameInProgress = false
        player.die()

        // Remove a repeatable action so the drops stop falling.
        removeAction(forKey: "gloops")

        // Remove all the drops.
        // Starting a name with "//" causes it to search
        // the entire node tree starting at the root.
        // Names beginning with "co_" are assigned in Collectible.swift.
        enumerateChildNodes(withName: "//co_*") { node, _ in
            node.removeAction(forKey: "drop")
            node.physicsBody = nil
            node.run(SKAction.removeFromParent())
        }

        resetPlayerPosition()
    }

    private func hideMessage() {
        // Starting a name with "//" causes it to search
        // the entire node tree starting at the root.
        if let messageLabel = childNode(withName: "//message") as? SKLabelNode {
            messageLabel.run(
                SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.25),
                    SKAction.removeFromParent()
                ])
            )
        }
    }

    private func nextLevel() {
        showMessage("Get Ready!")
        let wait = SKAction.wait(forDuration: 2.25)
        run(wait) { [unowned self] in
            level += 1
            spawnGloops()
        }
    }

    private func resetPlayerPosition() {
        let resetPoint = CGPoint(x: frame.midX, y: player.position.y)
        let distance = hypot(resetPoint.x - player.position.x, 0)
        let calculatedSpeed = TimeInterval(distance / (playerSpeed * 2)) / 255

        let direction = player.position.x > frame.midX ? "L" : "R"
        player.moveTo(
            resetPoint,
            direction: direction,
            speed: calculatedSpeed
        )
    }

    private func setupLabels() {
        scoreLabel.name = "score"
        scoreLabel.fontName = "Nosifer"
        scoreLabel.fontColor = .yellow
        scoreLabel.fontSize = 35
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = Layer.ui.rawValue
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: viewTop() - 100)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        levelLabel.name = "level"
        levelLabel.fontName = "Nosifer"
        levelLabel.fontColor = .yellow
        levelLabel.fontSize = 35
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.zPosition = Layer.ui.rawValue
        levelLabel.position = CGPoint(x: frame.minX + 50, y: viewTop() - 100)
        levelLabel.text = "Level: \(level)"
        addChild(levelLabel)
    }

    func showMessage(_ message: String) {
        let messageLabel = SKLabelNode()
        messageLabel.name = "message"
        messageLabel.position = CGPoint(
            x: frame.midX,
            y: player.frame.maxY + 100
        )
        messageLabel.zPosition = Layer.ui.rawValue
        messageLabel.numberOfLines = 2

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: SKColor(
                red: 251.0 / 255.0,
                green: 155.0 / 255.0,
                blue: 24.0 / 255.0,
                alpha: 1.0
            ),
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "Nosifer", size: 45.0)!,
            .paragraphStyle: paragraph
        ]
        messageLabel.attributedText = NSAttributedString(
            string: message,
            attributes: attributes
        )

        // Run a fade action and add the label to the scene.
        messageLabel.run(SKAction.fadeIn(withDuration: 0.25))
        addChild(messageLabel)
    }

    private func spawnGloop() {
        let gloop = Collectible(type: CollectibleType.gloop)

        let margin = gloop.size.width * 2
        let minX = frame.minX + margin
        let maxX = frame.maxX - margin

        gloop.position = CGPoint(
            x: CGFloat.random(in: minX ... maxX),
            y: player.position.y * 2.5
        )

        addChild(gloop)

        gloop.drop(duration: TimeInterval(1.5), level: player.frame.minY)
    }

    private func spawnGloops() {
        hideMessage()
        player.walk()

        if !gameInProgress {
            score = 0
            level = 1
        }

        let dropCount = level * 10
        dropsCollected = 0
        dropsExpected = dropCount

        let proposedSpeed = 1.0 /
            (CGFloat(level) + (CGFloat(level) / CGFloat(dropCount)))
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

        gameInProgress = true
    }

    private func touchDown(atPoint point: CGPoint) {
        // This handles the case where the game has ended
        // and the user tapped to start a new game.
        if !gameInProgress {
            spawnGloops()
            return
        }

        let touchedNode = atPoint(point)
        if touchedNode.name == "player" {
            isMoving = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchDown(atPoint: touch.location(in: self))
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
        guard isMoving else { return }

        for touch in touches {
            let point = touch.location(in: self)

            let newPoint = CGPoint(x: point.x, y: player.position.y)
            player.position = newPoint

            // Update facing direction of player.
            let oldPoint = lastPosition ?? player.position
            player.xScale = (newPoint.x < oldPoint.x ? -1 : 1) * abs(xScale)

            lastPosition = newPoint
        }
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
                dropsCollected += 1
                score += level
                checkForRemainingDrops()
            }
            // If a Collectible collided with the floor ...
            if collision ==
                PhysicsCategory.collectible | PhysicsCategory.foreground {
                sprite.missed()
                gameOver()
            }
        }
    }
}
