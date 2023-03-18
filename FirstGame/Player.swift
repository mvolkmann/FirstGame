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
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func moveTo(_ point: CGPoint, duration: TimeInterval) {
        let action = SKAction.move(to: point, duration: duration)
        run(action)
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
