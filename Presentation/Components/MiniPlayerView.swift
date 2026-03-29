import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @State private var showFullPlayer = false
    
    var body: some View {
        if let song = viewModel.currentSong {
            HStack(spacing: 12) {
                // Placeholder for artwork (In a real app, use metadata.artwork)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 48, height: 48)
                    .cornerRadius(4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textColor)
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryTextColor)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.playbackState == .playing ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accentColor)
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    viewModel.next()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.textColor)
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 60) // Floating above TabBar
            .onTapGesture {
                showFullPlayer = true
            }
            .sheet(isPresented: $showFullPlayer) {
                NowPlayingView(viewModel: viewModel)
            }
        } else {
            EmptyView()
        }
    }
}
