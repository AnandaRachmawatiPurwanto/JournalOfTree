import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var store: JournalStore
    @State private var isSidebarVisible = true

    var body: some View {
        HStack(spacing: 0) {
            
            // ── Sidebar ──
            if isSidebarVisible {
                SidebarView(isShowing: $isSidebarVisible)
                    .transition(.move(edge: .leading))
            }
            
            // ── Main Content Area ──
            ZStack(alignment: .topLeading) {
                
                // Latar Belakang & Konten Utama
                ZStack {
                    Group {
                        switch store.activeView {
                        case .tree:
                            TreeView()
                                .transition(.opacity)
                        case .form:
                            JournalFormView()
                                .transition(.opacity)
                        }
                    }

                    if store.activeView == .tree {
                        TambahJournalButton()
                            .padding(.bottom, 24)
                            .padding(.trailing, 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // ── Music Controls (Top Right) ──
                if store.activeView == .tree {
                    MusicControlView()
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // ── Tombol Buka Sidebar (bila ditutup) ──
                if !isSidebarVisible {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isSidebarVisible = true
                        }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 16))
                            .padding(10)
                            .background(.regularMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(16)
                    .transition(.opacity)
                }
            }
            .zIndex(0) // Memastikan transisi aman
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSidebarVisible)
        .animation(.easeInOut(duration: 0.2), value: store.activeView)
        .onChange(of: store.activeView) { newView in
            if newView == .form {
                // Jika ingin form tetap bisa disandingkan, kita bisa disable baris di bawah ini
                // Tapi dibiarkan tertutup otomatis sesuai code awal agak form tampil luas.
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isSidebarVisible = false
                }
            }
        }
    }
}

// MARK: - Music Control View
struct MusicControlView: View {
    @ObservedObject var soundManager = SoundManager.shared
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Label Lagu Saat Ini (Opsional, kecil saja)
            Text("Track \(soundManager.currentTrackIndex + 1)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())

            // Tombol Shuffle
            Button {
                withAnimation(.spring()) {
                    soundManager.toggleShuffle()
                }
            } label: {
                Image(systemName: soundManager.isShuffleActive ? "shuffle.circle.fill" : "shuffle.circle")
                    .font(.system(size: 18))
                    .foregroundColor(soundManager.isShuffleActive ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .help("Shuffle every 3 minutes")

            // Tombol Next
            Button {
                soundManager.nextTrack()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Next Track")
        }
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
        .onHover { h in withAnimation { isHovered = h } }
        .opacity(isHovered ? 1.0 : 0.8)
    }
}
