import SwiftUI
import AVKit

#if canImport(KSPlayer)
import KSPlayer
#endif

public struct VideoPlayerView: View {
    public let videoUrl: String
    
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = true
    @State private var isMuted: Bool = false
    
    public init(videoUrl: String) {
        self.videoUrl = videoUrl
    }
    
    private var isWebM: Bool {
        return videoUrl.lowercased().contains(".webm")
    }
    
    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            #if canImport(KSPlayer)
            if isWebM, let url = URL(string: videoUrl) {
                KSVideoPlayerView(url: url)
                    .edgesIgnoringSafeArea(.all)
            } else {
                nativePlayerView
            }
            #else
            nativePlayerView
            #endif
            
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: togglePlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Button(action: toggleMute) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            setupNativePlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private var nativePlayerView: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            } else {
                ProgressView()
                    .tint(.neonOrange)
            }
        }
    }
    
    private func setupNativePlayer() {
        guard let url = URL(string: videoUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }
        
        self.player = newPlayer
        newPlayer.play()
        self.isPlaying = true
    }
    
    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    private func toggleMute() {
        isMuted.toggle()
        player?.isMuted = isMuted
    }
}

#if canImport(KSPlayer)
struct KSVideoPlayerView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> IOSVideoPlayerView {
        let playerView = IOSVideoPlayerView()
        playerView.set(url: url)
        playerView.play()
        return playerView
    }
    
    func updateUIView(_ uiView: IOSVideoPlayerView, context: Context) {}
}
#endif
