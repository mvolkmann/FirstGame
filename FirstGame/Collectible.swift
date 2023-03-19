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

        physicsBody = SKPhysicsBody(
            rectangleOf: size,
            center: CGPoint(x: 0, y: -size.height / 2)
        )
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.collectible
        physicsBody?.contactTestBitMask =
            PhysicsCategory.player | PhysicsCategory.foreground
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collected() {
        run(SKAction.removeFromParent())
    }

    func drop(duration: TimeInterval, level: CGFloat) {
        // This is where the drop will end which is on the floor.
        let endPoint = CGPoint(x: position.x, y: level)

        print("\(#fileID) \(#function) self =", self)

        // This causes the drop to fade into view over a quarter of a second.
        // It seems to have no effect, probably because
        // the drop has no size when this runs.
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.25)

        // The drop begins with a size of 0 x 0.
        // This causes the drop to stretch like a liquid drip".
        let scaleX = SKAction.scaleX(to: 1.0, duration: 1.0)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1.0)
        let scale = SKAction.group([scaleX, scaleY])

        // This causes the drop to move from its current position to the floor.
        let move = SKAction.move(to: endPoint, duration: speed)

        // let sequence = SKAction.sequence([appear]) // not visible!
        // let sequence = SKAction.sequence([scale, move]) // same as next line
        let sequence = SKAction.sequence([appear, scale, move])

        // This causes the drop to shrink horizontally before falling.
        self.scale(to: CGSize(width: 0.25, height: 1))

        // This performs all the actions defined above.
        run(sequence, withKey: "drop")
    }

    func missed() {
        run(SKAction.removeFromParent())
    }
}
