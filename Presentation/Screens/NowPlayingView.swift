import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [AppTheme.accentColor.opacity(0.3), AppTheme.primaryBackground], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundStyle(AppTheme.textColor)
                    }
                    Spacer()
                    Text("Now Playing")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textColor)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "list.bullet")
                            .font(.title2)
                            .foregroundStyle(AppTheme.textColor)
                    }
                }
                .padding()
                
                Spacer()
                
                // Artwork
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .padding(40)
                    
                    if let song = viewModel.currentSong {
                        Image(systemName: "music.note")
                            .font(.system(size: 80))
                            .foregroundStyle(AppTheme.accentColor)
                    }
                }
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                
                // Info
                VStack(spacing: 8) {
                    Text(viewModel.currentSong?.title ?? "Unknown Title")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.textColor)
                        .multilineTextAlignment(.center)
                    
                    Text(viewModel.currentSong?.artist ?? "Unknown Artist")
                        .font(.title3)
                        .foregroundStyle(AppTheme.secondaryTextColor)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Seek Bar
                VStack {
                    Slider(value: Binding(get: {
                        viewModel.currentTime
                    }, set: { newTime in
                        viewModel.seek(to: newTime)
                    }), in: 0...max(viewModel.duration, 1))
                    .accentColor(AppTheme.accentColor)
                    
                    HStack {
                        Text(formatTime(viewModel.currentTime))
                        Spacer()
                        Text(formatTime(viewModel.duration))
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryTextColor)
                }
                .padding(.horizontal, 30)
                
                // Controls
                HStack(spacing: 40) {
                    Button(action: {
                        viewModel.isShuffleOn.toggle()
                        AudioPlayerService.shared.isShuffleOn = viewModel.isShuffleOn
                    }) {
                        Image(systemName: "shuffle")
                            .font(.title3)
                            .foregroundStyle(viewModel.isShuffleOn ? AppTheme.accentColor : AppTheme.textColor)
                    }
                    
                    Button(action: { viewModel.previous() }) {
                        Image(systemName: "backward.fill")
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.textColor)
                    }
                    
                    Button(action: { viewModel.togglePlayPause() }) {
                        Image(systemName: viewModel.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(AppTheme.accentColor)
                    }
                    
                    Button(action: { viewModel.next() }) {
                        Image(systemName: "forward.fill")
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.textColor)
                    }
                    
                    Button(action: {
                        switch viewModel.repeatMode {
                        case .none: viewModel.repeatMode = .all
                        case .all: viewModel.repeatMode = .one
                        case .one: viewModel.repeatMode = .none
                        }
                        AudioPlayerService.shared.repeatMode = viewModel.repeatMode
                    }) {
                        Image(systemName: viewModel.repeatMode == .one ? "repeat.1" : "repeat")
                            .font(.title3)
                            .foregroundStyle(viewModel.repeatMode == .none ? AppTheme.textColor : AppTheme.accentColor)
                    }
                }
                .padding(.vertical, 40)
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%d:%02d", min, sec)
    }
}
