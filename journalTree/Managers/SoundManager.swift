import Foundation
import AVFoundation
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    var audioPlayer: AVAudioPlayer?
    
    // Daftar lagu yang tersedia
    private let tracks = ["backsound.mp3", "backsound1.mp3", "backsound2.mp3", "backsound3.mp3"]
    
    @Published var currentTrackIndex = 0
    @Published var isShuffleActive = false
    
    private var shuffleTimer: Timer?

    func playBackgroundMusic(filename: String? = nil) {
        let trackToPlay = filename ?? tracks[currentTrackIndex]
        print("🎵 Mencoba memutar musik: \(trackToPlay)...")
        
        guard let url = Bundle.main.url(forResource: (trackToPlay as NSString).deletingPathExtension, 
                                        withExtension: (trackToPlay as NSString).pathExtension) else {
            print("❌ ERROR: File '\(trackToPlay)' TIDAK ditemukan di bundle aplikasi.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 
            audioPlayer?.volume = 1.0      
            audioPlayer?.prepareToPlay()
            
            if audioPlayer?.play() == true {
                print("✅ BERHASIL: Musik '\(trackToPlay)' sedang diputar!")
            }
        } catch {
            print("❌ ERROR: Gagal inisialisasi AVAudioPlayer: \(error.localizedDescription)")
        }
    }

    func nextTrack() {
        if isShuffleActive {
            currentTrackIndex = Int.random(in: 0..<tracks.count)
        } else {
            currentTrackIndex = (currentTrackIndex + 1) % tracks.count
        }
        playBackgroundMusic()
    }

    func toggleShuffle() {
        isShuffleActive.toggle()
        
        if isShuffleActive {
            startShuffleTimer()
        } else {
            stopShuffleTimer()
        }
    }

    private func startShuffleTimer() {
        stopShuffleTimer() // Bersihkan timer lama jika ada
        // Set timer untuk ganti lagu setiap 180 detik (3 menit)
        shuffleTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.nextTrack()
            }
        }
        print("🔀 Shuffle Aktif: Lagu akan berganti setiap 3 menit.")
    }

    private func stopShuffleTimer() {
        shuffleTimer?.invalidate()
        shuffleTimer = nil
        print("⏹️ Shuffle Dimatikan.")
    }

    func stopMusic() {
        audioPlayer?.stop()
    }
}
