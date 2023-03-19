import SpriteKit

extension SKScene {
    func viewTop() -> CGFloat {
        convertPoint(fromView: .lowerLeft).y
    }

    func viewBottom() -> CGFloat {
        guard let view else { return 0 }
        return convertPoint(
            fromView: CGPoint(x: 0.0, y: view.bounds.size.height)
        ).y
    }
}
