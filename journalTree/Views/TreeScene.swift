import SpriteKit

final class LeafPNGCache {
    static let shared = LeafPNGCache()
    private var textures: [String: SKTexture] = [:]

    // Kembalikan texture PNG untuk bentuk daun
    func texture(mood: Mood) -> SKTexture {
        // Sad pakai bentuk leafBlue, sisanya pakai leafYellow
        let name : String = {
            switch mood {
            case .happy:              return "leafYellow"
            case .sad:                return "leafBlue"
            case .angry:              return "leafRed"
            case .disappointed:       return "leafPurple"
            case .fear:               return "leafGreen"
            }
            
        } ()
        if let cached = textures[name] { return cached }
        let tex = SKTexture(imageNamed: name)
        tex.filteringMode = .nearest
        textures[name] = tex
        return tex
    }

    // Warna tint per mood (diterapkan via colorize di refreshLeaves)
    func tintColor(mood: Mood) -> SKColor? {
        switch mood {
        case .happy, .sad:        return nil           // Warna asli PNG
        case .angry:              return SKColor(red: 0.90, green: 0.20, blue: 0.18, alpha: 1) // merah
        case .disappointed:       return SKColor(red: 0.62, green: 0.40, blue: 0.80, alpha: 1) // ungu
        case .fear:               return SKColor(red: 0.30, green: 0.62, blue: 0.42, alpha: 1) // hijau tua
        }
    }
}

final class TreeScene: SKScene {

    // sceneW dan sceneH sekarang menggunakan self.size.width/height untuk fleksibilitas
    private var sceneW: CGFloat { size.width }
    private var sceneH: CGFloat { size.height }

    // Ukuran daun ikut skala window — 2.4% dari lebar scene
    private var leafW: CGFloat { sceneW * 0.024 }
    private var leafH: CGFloat { sceneW * 0.024 * (28.0 / 24.0) } // jaga aspek ratio

    var journalData: [(color: SKColor, index: Int, mood: Mood)] = [] {
        didSet { refreshLeaves() }
    }
    var selectedIdx: Int?       { didSet { updateSelected() } }
    var onLeafTap: ((Int) -> Void)?

    private var leafGroups: [[SKSpriteNode]] = []
    private var treeNode: SKSpriteNode?

    override func didMove(to view: SKView) {
        scaleMode            = .resizeFill  // scene ikut resize window, bukan di-stretch
        physicsWorld.gravity = .zero
        physicsWorld.speed   = 0
        
        rebuildStaticNodes()
    }

    // Dipanggil otomatis setiap kali window di-resize
    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        rebuildStaticNodes()
        refreshLeaves()  // reposisi semua daun ke ukuran scene baru
    }

    // Bangun ulang background + pohon (hapus yang lama dulu)
    private func rebuildStaticNodes() {
        childNode(withName: "ground")?.removeFromParent()
        childNode(withName: "tree")?.removeFromParent()
        removeChildren(in: children.compactMap {
            $0 is SKShapeNode ? $0 : nil
        })
        setupBackground()
        setupTreeAsset()
        // Aktifkan baris ini jika ingin melihat debug zones:
        //drawDebugZones()
    }

    private func setupBackground() {
        // Langit lebih terang (hampir putih gading)
        backgroundColor = SKColor(red: 1.0, green: 0.99, blue: 0.96, alpha: 1.0)

        let ground = SKSpriteNode(imageNamed: "ground")
        let groundW = sceneW
        let groundH = sceneH * 0.28 // Gunakan 28% dari tinggi layar
        
        ground.name      = "ground"
        ground.anchorPoint = CGPoint(x: 0.5, y: 0)
        ground.size      = CGSize(width: groundW, height: groundH)
        ground.position  = CGPoint(x: sceneW/2, y: sceneH * 0) // Geser sedikit ke atas
        ground.zPosition = 0
        addChild(ground)
    }

    private func setupTreeAsset() {
        let tree = SKSpriteNode(imageNamed: "pohonTekstur")
        let treeW = sceneW * 0.92
        let treeH = treeW / (1456.0 / 1150.0)
        tree.name      = "tree"
        tree.size      = CGSize(width: treeW, height: treeH)
        // Duduk pas di permukaan rumput
        tree.position  = CGPoint(x: sceneW * 0.50, y: sceneH * 0.32)
        tree.zPosition = 1
        tree.blendMode = .alpha
        addChild(tree)
        self.treeNode = tree
    }
    // MARK: - Debug Zones
    private func drawDebugZones() {
        guard let tree = treeNode else { return }
        let colors: [SKColor] = [.red, .green, .blue, .cyan, .magenta, .yellow, .orange, .purple]
        
        for (i, zone) in LeafLayout.zones.enumerated() {
            let w = CGFloat(zone.rx * 2) * tree.size.width
            let h = CGFloat(zone.ry * 2) * tree.size.height
            
            let shape = SKShapeNode(ellipseOf: CGSize(width: w, height: h))
            shape.position = CGPoint(
                x: tree.position.x + (CGFloat(zone.cx) - 0.5) * tree.size.width,
                y: tree.position.y + (CGFloat(zone.cy) - 0.5) * tree.size.height
            )
            
            shape.strokeColor = colors[i % colors.count]
            shape.lineWidth = 2.0
            shape.fillColor = colors[i % colors.count].withAlphaComponent(0.3)
            shape.zPosition = 10 
            
            addChild(shape)
        }
    }

    // MARK: - Leaves

    func refreshLeaves() {
        guard let tree = treeNode else { return }
        
        // Hapus semua daun lama
        leafGroups.flatMap { $0 }.forEach { $0.removeFromParent() }
        leafGroups.removeAll()

        for item in journalData {
            let i       = item.index
            let lp      = LeafLayout.positions[i]
            
            // Posisi relatif terhadap pohon
            let posX    = tree.position.x + (CGFloat(lp.x) - 0.5) * tree.size.width
            let posY    = tree.position.y + (CGFloat(lp.y) - 0.5) * tree.size.height
            
            let baseRot = CGFloat(lp.rotation * .pi / 180.0)

            let tex  = LeafPNGCache.shared.texture(mood: item.mood)
            let leaf = SKSpriteNode(texture: tex, size: CGSize(width: leafW, height: leafH))
            leaf.position  = CGPoint(x: posX, y: posY)
            leaf.zRotation = baseRot
            leaf.zPosition = 3
            leaf.alpha     = 0
            leaf.name      = "leaf_\(i)"

            // Tint warna untuk mood baru (angry/disappointed/fear)
            if let tint = LeafPNGCache.shared.tintColor(mood: item.mood) {
                leaf.color          = tint
                leaf.colorBlendFactor = 0.85
            }

            addChild(leaf)

            // Animasi muncul
            let delay = SKAction.wait(forDuration: Double(i) * 0.005)
            let appear = SKAction.group([
                .fadeAlpha(to: 1.0, duration: 0.30),
                .sequence([
                    .scale(to: 0.05, duration: 0),
                    .scale(to: 1.14, duration: 0.24),
                    .scale(to: 1.00, duration: 0.10)
                ])
            ])

            leaf.run(.sequence([delay, appear])) {
                self.startSway(leaf: leaf, base: baseRot)
            }

            leafGroups.append([leaf])
        }
    }

    private func startSway(leaf: SKSpriteNode, base: CGFloat) {
        let amp = CGFloat.random(in: 0.04...0.13)
        let dur = Double.random(in: 1.7...3.2)

        let goLeft  = SKAction.rotate(toAngle: base - amp, duration: dur/2, shortestUnitArc: true)
        let goRight = SKAction.rotate(toAngle: base + amp, duration: dur/2, shortestUnitArc: true)
        goLeft.timingMode  = .easeInEaseOut
        goRight.timingMode = .easeInEaseOut

        leaf.run(.repeatForever(.sequence([goLeft, goRight])), withKey: "sway")
    }

    // MARK: - Selection

    private func updateSelected() {
        let hasSelection = (selectedIdx != nil)
        
        for (i, group) in leafGroups.enumerated() {
            guard let main = group.first else { continue }
            let isSelected = (i == selectedIdx)

            if isSelected {
                // Pastikan yang sedang dipilih berhenti bergoyang
                main.removeAction(forKey: "sway")
                
                main.run(.sequence([
                    .scale(to: 1.85, duration: 0.18),
                    .scale(to: 1.60, duration: 0.10)
                ]))
                
                // 1. Ubah warna menjadi menyala putih menetap selama di-klik
                main.run(.colorize(with: .white, colorBlendFactor: 0.75, duration: 0.2))
                
                // 2. Majukan ke paling depan layar & buat jelas
                main.zPosition = 10
                main.run(.fadeAlpha(to: 1.0, duration: 0.2))
                
            } else {
                main.run(.scale(to: 1.0, duration: 0.18))
                
                // 3. Kembalikan ke warna asli (Kuning/Biru)
                main.run(.colorize(withColorBlendFactor: 0.0, duration: 0.2))
                main.zPosition = 3
                
                // 4. EFEK BIOSKOP: Kalau ada satu daun yg diklik, redupkan daun lain!
                let targetAlpha: CGFloat = hasSelection ? 0.35 : 1.0
                main.run(.fadeAlpha(to: targetAlpha, duration: 0.2))

                // Kembalikan sway HANYA jika daun ini sebelumnya mati (baru selesai dipilih)
                if main.action(forKey: "sway") == nil {
                    let baseAngle = CGFloat(LeafLayout.positions[i].rotation * .pi / 180.0)
                    main.run(.rotate(toAngle: baseAngle, duration: 0.2)) {
                        self.startSway(leaf: main, base: baseAngle)
                    }
                }
            }
        }
    }

    // MARK: - Input

    override func mouseDown(with event: NSEvent) {
        for node in nodes(at: event.location(in: self)) {
            guard
                let name = node.name,
                name.hasPrefix("leaf_"),
                let idx = Int(name.dropFirst(5))
            else { continue }

            onLeafTap?(idx)
            return
        }
    }
}
