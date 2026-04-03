import SwiftUI

@main
struct JournalTreeApp: App {
    @StateObject private var store = JournalStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    // Nama file ini harus sama dengan file yang kamu masukkan ke Xcode
                    SoundManager.shared.playBackgroundMusic(filename: "backsound.mp3")
                }
                .onChange(of: store.activeView) { _, newView in
                    if newView == .form {
                        SoundManager.shared.stopMusic()
                    } else {
                        SoundManager.shared.playBackgroundMusic(filename: "backsound.mp3")
                    }
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 980, height: 640)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(after: .newItem) {
                Button("Add New Journal") { store.showForm() }
                    .keyboardShortcut("n", modifiers: .command)
                    .disabled(store.journals.count >= LeafLayout.totalLeaves)
            }
        }
    }
}
