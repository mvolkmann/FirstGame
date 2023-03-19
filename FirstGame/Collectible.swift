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
}
