import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Premium Gradient Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("NOW PLAYING")
                            .font(.caption2)
                            .fontWeight(.black)
                            .tracking(2)
                            .foregroundStyle(AppTheme.accentColor)
                        Text("KhaganMusic")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryTextColor)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Artwork (Modern Glassmorphic look)
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(AppTheme.secondaryBackground)
                        .aspectRatio(1, contentMode: .fit)
                        .shadow(color: AppTheme.accentColor.opacity(0.3), radius: 30, x: 0, y: 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 40)
                    
                    if viewModel.currentSong != nil {
                        Image(systemName: "music.note")
                            .font(.system(size: 100, weight: .thin))
                            .foregroundStyle(AppTheme.accentColor)
                    }
                }
                
                // Info
                VStack(spacing: 10) {
                    Text(viewModel.currentSong?.title ?? "Unknown Title")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(viewModel.currentSong?.artist ?? "Unknown Artist")
                        .font(.title3)
                        .foregroundStyle(AppTheme.secondaryTextColor)
                        .lineLimit(1)
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Seek Bar
                VStack(spacing: 8) {
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
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.secondaryTextColor)
                }
                .padding(.horizontal, 24)
                
                // Controls
                HStack(spacing: 35) {
                    Button(action: {
                        viewModel.isShuffleOn.toggle()
                        AudioPlayerService.shared.isShuffleOn = viewModel.isShuffleOn
                    }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(viewModel.isShuffleOn ? AppTheme.accentColor : AppTheme.secondaryTextColor)
                    }
                    
                    Button(action: { viewModel.previous() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppTheme.textColor)
                    }
                    
                    Button(action: { viewModel.togglePlayPause() }) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accentColor)
                                .frame(width: 80, height: 80)
                                .shadow(color: AppTheme.accentColor.opacity(0.5), radius: 15, x: 0, y: 10)
                            
                            Image(systemName: viewModel.playbackState == .playing ? "pause.fill" : "play.fill")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(Color.white)
                                .offset(x: viewModel.playbackState == .playing ? 0 : 4) // visual balance for play icon
                        }
                    }
                    
                    Button(action: { viewModel.next() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 32))
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
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(viewModel.repeatMode == .none ? AppTheme.secondaryTextColor : AppTheme.accentColor)
                    }
                }
                .padding(.vertical, 30)
                
                // Signature
                Text("Coded by Khagan")
                    .font(.system(size: 10, weight: .light, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.3))
                    .padding(.bottom, 20)
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%d:%02d", min, sec)
    }
}
