import SpriteKit

enum CollectibleType: String {
    case none
    case gloop
}

class Collectible: SKSpriteNode {
    private var collectibleType: CollectibleType = .none

    init(collectibleType: CollectibleType) {
        var texture: SKTexture!
        self.collectibleType = collectibleType
        switch self.collectibleType {
        case .gloop:
            texture = SKTexture(imageNamed: "gloop")
        case .none:
            break
        }

        super.init(texture: texture, color: SKColor.clear, size: texture.size())

        name = "co_\(collectibleType)"
        anchorPoint = .top
        zPosition = Layer.collectible.rawValue
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
