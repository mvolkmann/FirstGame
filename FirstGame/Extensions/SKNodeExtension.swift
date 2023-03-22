import SpriteKit

extension SKNode {
    func setupScrollingView(
        imageNamed name: String,
        layer: Layer,
        blocks: Int,
        speed: TimeInterval
    ) {
        for i in 0 ..< blocks {
            let node = SKSpriteNode(imageNamed: name)
            node.name = name
            node.anchorPoint = CGPoint.zero
            node.position = CGPoint(x: CGFloat(i) * node.size.width, y: 0)
            node.zPosition = layer.rawValue
            node.endlessScroll(speed: speed)
            addChild(node)
        }
    }
}
