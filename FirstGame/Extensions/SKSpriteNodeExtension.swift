import SpriteKit

extension SKSpriteNode {
    func endlessScroll(speed: TimeInterval) {
        let moveAction = SKAction.moveBy(x: -size.width, y: 0, duration: speed)
        let resetAction = SKAction.moveBy(x: size.width, y: 0, duration: 0)
        let sequence = SKAction.sequence([moveAction, resetAction])
        let repeatAction = SKAction.repeatForever(sequence)
        run(repeatAction)
    }

    func loadTextures(
        atlas: String,
        prefix: String,
        startsAt: Int,
        stopsAt: Int
    ) -> [SKTexture] {
        var textures: [SKTexture] = []
        let atlas = SKTextureAtlas(named: atlas)
        for i in startsAt ... stopsAt {
            let name = "\(prefix)\(i)"
            textures.append(atlas.textureNamed(name))
        }
        return textures
    }

    func startAnimation(
        textures: [SKTexture],
        speed: Double,
        name: String,
        count: Int, // when zero, runs until stopped
        resize: Bool,
        restore: Bool
    ) {
        guard action(forKey: name) == nil else { return }

        let animation = SKAction.animate(
            with: textures,
            timePerFrame: speed,
            resize: resize,
            restore: restore
        )
        let theAction =
            count == 0 ? SKAction.repeatForever(animation) :
            count == 1 ? animation :
            SKAction.repeat(animation, count: count)
        run(theAction, withKey: name)
    }
}
