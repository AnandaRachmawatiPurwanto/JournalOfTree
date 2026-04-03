import SwiftUI

// MARK: - SidebarView
struct SidebarView: View {
    @EnvironmentObject var store: JournalStore
    @Binding var isShowing: Bool

    var body: some View {
        VStack(alignment: .leading) {

            // ── Header ──────────────────────────────────────────
            HStack {
                Text("Journal History")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(NSColor.labelColor))
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                } label: {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 13))
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 15)
            //.padding(.bottom, 5)

            Divider().opacity(0.4)

            // ── List ─────────────────────────────────────────────
            if store.journals.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(store.journals.reversed()) { j in
                            SidebarRow(journal: j)
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(width: 250) // Lebar panel overlay
        .background(.regularMaterial) // Native glass effect yang menyatu dan clean
        .shadow(color: .black.opacity(0.15), radius: 15, x: 5, y: 0) // Efek melayang
        //.ignoresSafeArea()
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "leaf")
                .font(.system(size: 28))
                .foregroundColor(Color(NSColor.quaternaryLabelColor))
            Text("Belum ada jurnal.\nMulai tulis!")
                .font(.system(size: 11))
                .foregroundColor(Color(NSColor.tertiaryLabelColor))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.top, 20)
    }
}

// MARK: - Sidebar Row
struct SidebarRow: View {
    let journal: Journal
    @EnvironmentObject var store: JournalStore
    @State private var isHovered = false

    var isSelected: Bool { journal.id == store.selectedJournalID }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.13)) {
                store.toggleSelection(journal.id)
            }
        } label: {
            HStack(spacing: 0) {
                // Indikator seleksi
                Rectangle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 3, height: 46)

                // Teks
                VStack(alignment: .leading, spacing: 2) {
                    Text(journal.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected
                            ? Color.accentColor
                            : Color(NSColor.labelColor))
                        .lineLimit(1)
                    Text(journal.formattedDate)
                        .font(.system(size: 10))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Ikon daun mood
                SidebarLeafIcon(mood: journal.mood)
                    .padding(.trailing, 12)
            }
            .frame(height: 46)
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.07)
                    : (isHovered ? Color.black.opacity(0.035) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.easeInOut(duration: 0.1)) { isHovered = h } }
        .contextMenu {
            Button(role: .destructive) {
                store.deleteJournal(id: journal.id)
            } label: {
                Label("Delete Journal", systemImage: "trash")
            }
        }
    }
}

// MARK: - Sidebar Leaf Icon
struct SidebarLeafIcon: View {
    let mood: Mood

    var body: some View {
        let assetName: String = {
            switch mood {
            case .happy: return "leafYellow"
            case .sad: return "leafBlue"
            case .angry: return "leafRed"
            case .disappointed: return "leafPurple"
            case .fear: return "leafGreen"
            }
        }() // Tanda kurung ini langsung menjalankan logikanya

        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
    }
}



// MARK: - Tambah Journal Floating Button
struct TambahJournalButton: View {
    @EnvironmentObject var store: JournalStore
    @State private var isHovered = false

    var body: some View {
        Button { store.showForm() } label: {
            Text("Add New Journal")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .onHover { h in withAnimation(.easeInOut(duration: 0.12)) { isHovered = h } }
        .disabled(store.journals.count >= LeafLayout.totalLeaves)
    }
}
