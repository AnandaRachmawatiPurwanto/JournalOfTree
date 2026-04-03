import SwiftUI
import SpriteKit
import Combine

// MARK: - SceneHolder
@MainActor
final class SceneHolder: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    let scene: TreeScene = {
        // Initial size kecil saja — scene akan otomatis resize via didChangeSize(.resizeFill)
        let s = TreeScene(size: CGSize(width: 300, height: 300))
        s.scaleMode       = .resizeFill
        s.backgroundColor = .clear
        return s
    }()
}

// MARK: - TreeView
struct TreeView: View {
    @EnvironmentObject var store: JournalStore
    @StateObject private var holder = SceneHolder()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // ── SpriteKit Scene ────────────────────────────────
            SpriteView(scene: holder.scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .onAppear { syncScene() }

                // FIX: Gunakan syntax onChange baru macOS 14+ dengan dua parameter
                .onChange(of: store.journals.count) { _, _ in
                    syncScene()
                }
                .onChange(of: store.selectedJournalID) { _, _ in
                    syncSelectedLeaf()
                }

            // ── Leaf Counter Badge ─────────────────────────────
            HStack {
                LeafCountBadge()
                Spacer()
            }
            .padding(.bottom, 20)
            .padding(.leading, 20)
        }
        // Popup jurnal
        .overlay {
            if let j = store.popupJournal {
                JournalPopupView(journal: j)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: store.popupJournal?.id)
    }

    private func syncScene() {
        holder.scene.journalData = store.journals.enumerated().map { idx, j in
            (color: j.mood.leafColor, index: idx, mood: j.mood)
        }
        holder.scene.onLeafTap = { idx in
            guard idx < store.journals.count else { return }
            withAnimation { store.selectLeaf(store.journals[idx]) }
            // Paksa update langsung scene-nya tanpa menunggu SwiftUI
            holder.scene.selectedIdx = idx
        }
    }

    // Update daun yang aktif
    private func syncSelectedLeaf() {
        holder.scene.selectedIdx = store.journals.firstIndex {
            $0.id == store.selectedJournalID
        }
    }
}

// MARK: - Leaf Count Badge
struct LeafCountBadge: View {
    @EnvironmentObject var store: JournalStore

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(red: 1.00, green: 0.76, blue: 0.12))
                .frame(width: 8, height: 8)
            Text("\(store.happyCount) Happy")
                .font(.system(size: 11, weight: .medium))

            Circle()
                .fill(Color(red: 0.56, green: 0.66, blue: 0.88))
                .frame(width: 8, height: 8)
            Text("\(store.sadCount) Sad")
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(.regularMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.black.opacity(0.07), lineWidth: 0.5))
    }
}
