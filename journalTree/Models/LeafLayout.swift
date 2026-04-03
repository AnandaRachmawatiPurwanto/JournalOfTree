import SwiftUI

// MARK: - LeafPosition
struct LeafPosition {
    let index:    Int
    let x:        CGFloat   // normalised 0–1 dalam canvas
    let y:        CGFloat   // normalised 0–1 dalam canvas
    let rotation: Double    // derajat
}

// MARK: - LeafLayout
/// Menghasilkan 365 posisi daun yang tersebar di kanopi pohon asset.
///
/// Karena asset pohon punya kanopi yang tidak simetris
/// (lebih lebar kiri, ada ranting-ranting acak), kita gunakan
/// beberapa ellips kanopi yang overlapping untuk mengisi
/// area kanopi secara natural.
enum LeafLayout {

    static let totalLeaves = 365

    // Seeded PRNG — deterministik, selalu sama
    static func rng(_ n: Int) -> Double {
        let x = sin(Double(n) * 9301.0 + 49297.0) * 233280.0
        return x - floor(x)
    }

    // ── Zona kanopi: dua ellips overlapping ──────────────────
    // Sesuai dengan bentuk pohon di asset:
    //   • Pohon ada di tengah gambar 1456×816
    //   • Kanopi kiri lebih lebar dari kanan
    //   • Ranting ujung sampai ~x=30% dari kiri, x=78% dari kanan
    //   • Bagian atas kanopi ~y=5%, bawah ~y=68%
    //
    // Kita gunakan koordinat normalised (0–1) dalam SpriteKit canvas.
    // SpriteKit Y=0 di bawah, jadi Y dinormalised dari bawah.

    struct CanopyZone {
        let cx: Double  // pusat X (0–1)
        let cy: Double  // pusat Y dari bawah (0–1)
        let rx: Double  // radius X
        let ry: Double  // radius Y
        let weight: Double // probabilitas zona ini dipilih
    }

    // Zona-zona kanopi berdasarkan analisis asset pohon
    // ── Zona kanopi dikalibrasi ulang sesuai asset 1.35× ─────────
    // Setelah pohon diperbesar 1.35×, kanopi aslinya ada di:
    //   X: 0.38 – 0.62 (dari tepi scene)   ← konservatif, hindari melayang
    //   Y: 0.58 – 0.82 (dari bawah scene)
    // Zona dibagi per area ranting nyata yang terlihat di asset.

    static let zones: [CanopyZone] = [
        // Zona utama — tubuh kanopi tengah
        CanopyZone(cx: 0.500, cy: 0.608, rx: 0.440, ry: 0.145, weight: 0.28),
        // Zona mahkota atas — puncak tajuk (diturunkan, tidak terlalu tinggi)
        CanopyZone(cx: 0.470, cy: 0.810, rx: 0.260, ry: 0.093, weight: 0.10),
        // Zona ranting kiri atas
        //CanopyZone(cx: 0.330, cy: 0.620, rx: 0.100, ry: 0.075, weight: 0.13),
        // Zona ranting kanan atas
        //CanopyZone(cx: 0.670, cy: 0.620, rx: 0.100, ry: 0.075, weight: 0.13),
        // Zona ranting kiri bawah
        CanopyZone(cx: 0.270, cy: 0.405, rx: 0.215, ry: 0.100, weight: 0.10),
        // Zona ranting kanan bawah
        CanopyZone(cx: 0.700, cy: 0.405, rx: 0.215, ry: 0.100, weight: 0.10),
        // Zona tengah bawah (ranting dekat batang)
        //CanopyZone(cx: 0.500, cy: 0.510, rx: 0.050, ry: 0.040, weight: 0.06),
        // Zona kanan jauh
        CanopyZone(cx: 0.850, cy: 0.495, rx: 0.075, ry: 0.040, weight: 0.02),
        // Zona kiri jauh
        CanopyZone(cx: 0.155, cy: 0.495, rx: 0.085, ry: 0.040, weight: 0.02),
    ]

    // Jarak minimum antar daun (normalised 0–1)
    static let minDistance: Double = 0.045
    static let maxAttempts: Int = 40

    // Semua 365 posisi, dihitung sekali
    static let positions: [LeafPosition] = {
        // Hitung cumulative weight untuk random zone selection
        let totalW = zones.reduce(0) { $0 + $1.weight }
        var cumW: [Double] = []
        var acc = 0.0
        for z in zones { acc += z.weight / totalW; cumW.append(acc) }

        var points: [CGPoint] = []
        var results: [LeafPosition] = []
        points.reserveCapacity(totalLeaves)
        results.reserveCapacity(totalLeaves)

        for i in 0 ..< totalLeaves {
            var nx = 0.0
            var ny = 0.0
            var accepted = false

            for attempt in 0 ..< maxAttempts {
                // Pilih zona berdasarkan weight
                let zoneRng = rng(i * 97 + attempt * 7 + 99)
                var zoneIdx = zones.count - 1
                for (j, cw) in cumW.enumerated() {
                    if zoneRng < cw { zoneIdx = j; break }
                }
                let zone = zones[zoneIdx]

                // Posisi dalam ellips zona
                let angle = rng(i * 31 + attempt * 3) * Double.pi * 2
                let r     = sqrt(rng(i * 31 + attempt * 3 + 1)) * 0.98

                nx = zone.cx + zone.rx * r * cos(angle)
                ny = zone.cy + zone.ry * r * sin(angle)

                let p = CGPoint(x: nx, y: ny)
                let minDistSq = minDistance * minDistance
                var tooClose = false
                for existing in points {
                    let dx = Double(existing.x) - nx
                    let dy = Double(existing.y) - ny
                    if dx * dx + dy * dy < minDistSq {
                        tooClose = true
                        break
                    }
                }

                if !tooClose {
                    accepted = true
                    break
                }
            }

            let rotation = rng(i * 3 + 2) * 70.0 - 35.0   // –35° … +35°
            let leaf = LeafPosition(index: i, x: CGFloat(nx), y: CGFloat(ny), rotation: rotation)
            results.append(leaf)
            points.append(CGPoint(x: nx, y: ny))

            if !accepted {
                // Jika gagal mencari posisi ideal, tetap pakai posisi terakhir
                // agar semua daun terisi deterministik.
                continue
            }
        }

        return results
    }()
}
