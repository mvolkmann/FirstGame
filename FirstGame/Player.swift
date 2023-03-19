import SpriteKit

enum PlayerAnimationType: String {
    case walk
}

class Player: SKSpriteNode {
    private var walkTextures: [SKTexture]?

    init() {
        let texture = SKTexture(imageNamed: "blob-walk_0")

        super.init(texture: texture, color: .clear, size: texture.size())

        walkTextures = loadTextures(
            atlas: "blob",
            prefix: "blob-walk_",
            startsAt: 0,
            stopsAt: 2
        )

        name = "player"

        setScale(1.0) // default?

        anchorPoint = .center // defined in CGPointExtension.swift

        zPosition = Layer.player.rawValue

        physicsBody = SKPhysicsBody(
            rectangleOf: size,
            // Offset to align the physics body with the player node (p. 77).
            center: CGPoint(x: 0, y: size.height / 2)
        )
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func moveTo(_ point: CGPoint) {
        let dx = point.x - position.x
        let dy = point.y - position.y
        let distance = hypot(dx, dy)
        let duration = TimeInterval(distance / 1.5) / 255
        xScale = (point.x < position.x ? -1 : 1) * abs(xScale)
        let action = SKAction.move(to: point, duration: duration)
        run(action)
    }

    func setupConstraints(floor: CGFloat) {
        let range = SKRange(lowerLimit: floor, upperLimit: floor)
        let constraint = SKConstraint.positionY(range)
        constraints = [constraint]
    }

    func walk() {
        guard let walkTextures else {
            preconditionFailure("Failed to find player textures.")
        }
        startAnimation(
            textures: walkTextures,
            speed: 0.25,
            name: PlayerAnimationType.walk.rawValue,
            count: 0,
            resize: true,
            restore: true
        )
    }
}
