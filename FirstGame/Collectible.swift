import SpriteKit

enum CollectibleType: String {
    case none
    case gloop
}

class Collectible: SKSpriteNode {
    private var type: CollectibleType = .none

    init(type: CollectibleType) {
        var texture: SKTexture!
        switch type {
        case .gloop:
            texture = SKTexture(imageNamed: "gloop")
        case .none:
            fatalError("Invalid Collectible type \(type)")
        }

        super.init(texture: texture, color: SKColor.clear, size: texture.size())

        self.type = type
        name = "co_\(type)"
        anchorPoint = .top
        zPosition = Layer.collectible.rawValue
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drop(speed: TimeInterval, level: CGFloat) {
        // This is where the drop will end which is on the floor.
        let pos = CGPoint(x: position.x, y: level)

        // This causes the drop to stretch like a "drip".
        let scaleX = SKAction.scaleX(to: 1.0, duration: 1.0)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1.0)
        let scale = SKAction.group([scaleX, scaleY])

        // This causes the drop to fade into view.
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.25)

        // This causes the drop to move from its current position to the floor.
        let move = SKAction.move(to: pos, duration: speed)

        let sequence = SKAction.sequence([appear, scale, move])

        // This causes the drop to shrink horizontally before falling.
        self.scale(to: CGSize(width: 0.25, height: 1))

        // This performs all the actions defined above.
        run(sequence, withKey: "drop")
    }
}
