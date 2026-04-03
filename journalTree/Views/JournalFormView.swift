import SwiftUI

struct JournalFormView: View {
    @EnvironmentObject var store: JournalStore
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var mood: Mood? = nil

    private var canSave: Bool { !title.isEmpty && !content.isEmpty && mood != nil }

    var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                MaskotGreetingView()                
                MakeMoodView(selectedMood: $mood)                  // kirim binding
                FormJurnalView(title: $title, content: $content)  // kirim binding
                HStack {
                    Spacer()
                    Button("Cancel") {
                        store.showTree()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.10), lineWidth: 0.5))

                    Button {
                        guard canSave, let m = mood else { return }
                        store.addJournal(title: title, content: content, mood: m)
                    } label: {
                        Label("Save", systemImage: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(canSave ? Color.accentColor : Color.secondary.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(!canSave)
                    .animation(.easeInOut(duration: 0.15), value: canSave)
                }
                
            }
            .padding(.horizontal, 16)  // ← satu padding untuk semua, rata kiri-kanan
            .padding(.top, 20)
            .padding(.bottom, 25)
    }
}

// MARK: - Form Judul & Isi
struct FormJurnalView: View {
    @Binding var title: String    // ← menerima dari parent
    @Binding var content: String  // ← menerima dari parent

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $title)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.top, 12)

            Divider().padding(.horizontal, 12)

            ZStack(alignment: .topLeading) {
                // Kembalikan si TextEditor!
                TextEditor(text: $content)
                    .font(.system(size: 13))
                    .padding(.top, 8)
                    .frame(minHeight: 20)
                    .scrollContentBackground(.hidden)

                // Teks bayangannya:
                if content.isEmpty {
                    Text("Write down your feelings today...")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.08), lineWidth: 0.5))
    }
}

// MARK: - Mascot
struct MaskotGreetingView: View {
    var body: some View {
        HStack(alignment: .top) {
            Image("maskot")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())

            ZStack(alignment: .leading) {
                Text("Hi, thank you for being brave enough to be here. Lay your burdens down here. After that, let's breathe easy.")
                    .font(.system(size: 14))
                    .lineSpacing(3)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                    .foregroundColor(.primary.opacity(0.8))
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.primary.opacity(0.06), lineWidth: 0.5))

                Triangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 20, height: 25)
                    .offset(x: -20, y: 10)
            }
        }
    }
}

// MARK: - Pilihan Mood
struct MakeMoodView: View {
    @Binding var selectedMood: Mood?

    // Menggunakan flexible agar lebih konsisten lebarnya
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What experiences have you shared?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary.opacity(0.8))

            LazyVGrid(columns: columns, spacing: 12) {
                // Tip: Gunakan ForEach jika datanya banyak agar lebih rapi
                MoodButtonView(mood: .happy, label: "Happy", imageName: "happy", selectedMood: $selectedMood)
                MoodButtonView(mood: .sad, label: "Sad", imageName: "sad", selectedMood: $selectedMood)
                MoodButtonView(mood: .angry, label: "Angry", imageName: "angry", selectedMood: $selectedMood)
                MoodButtonView(mood: .disappointed, label: "Disappointed", imageName: "disappointed", selectedMood: $selectedMood)
                MoodButtonView(mood: .fear, label: "Fear", imageName: "fear", selectedMood: $selectedMood)
            }
        }
        .padding(16) // Padding luar lebih besar agar tidak sesak
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        //.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // Tambah shadow tipis biar cantik
    }
}

// MARK: - Tombol Mood (satu item)
struct MoodButtonView: View {
    let mood: Mood
    let label: String
    let imageName: String
    @Binding var selectedMood: Mood?

    var isSelected: Bool { selectedMood == mood }  // cek apakah ini yang dipilih

    var body: some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .frame(width: 100, height: 120)
                .padding()
                    
                .frame(width: 100, height: 80)
                .padding(12)
                .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.blue : Color.primary.opacity(0.1), lineWidth: isSelected ? 2 : 1))

            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .blue : .secondary)
        }
        .onTapGesture {
            selectedMood = mood  // ← simpan mood yang dipilih ke parent
        }
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: .init(x: rect.maxX, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        p.addLine(to: .init(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    JournalFormView()
        .environmentObject(JournalStore())
}
