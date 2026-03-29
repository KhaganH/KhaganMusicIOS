import SwiftUI
import SwiftData

struct PlaylistDetailView: View {
    @Bindable var playlist: Playlist
    @Query(sort: \Song.title) var allSongs: [Song]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSongs = false
    
    var body: some View {
        ZStack {
            AppTheme.primaryBackground.ignoresSafeArea()
            
            VStack {
                if let songs = playlist.songs, !songs.isEmpty {
                    List {
                        ForEach(songs) { song in
                            HStack {
                                Image(systemName: "music.note")
                                    .frame(width: 40, height: 40)
                                    .background(AppTheme.secondaryBackground)
                                    .cornerRadius(4)
                                    .foregroundStyle(AppTheme.accentColor)
                                
                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .foregroundStyle(AppTheme.textColor)
                                    Text(song.artist)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.secondaryTextColor)
                                }
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(AppTheme.secondaryTextColor)
                            }
                            .onTapGesture {
                                AudioPlayerService.shared.setQueue(songs, startWith: song)
                            }
                        }
                        .onMove(perform: moveSongs)
                        .onDelete(perform: removeSongs)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                } else {
                    ContentUnavailableView {
                        Label("No Songs", systemImage: "music.note")
                    } description: {
                        Text("Add songs to this playlist from your library.")
                    } actions: {
                        Button("Add Songs") { showingAddSongs = true }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.accentColor)
                    }
                }
            }
        }
        .navigationTitle(playlist.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddSongs = true }) {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(AppTheme.accentColor)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
                    .foregroundStyle(AppTheme.accentColor)
            }
        }
        .sheet(isPresented: $showingAddSongs) {
            AddSongsToPlaylistView(playlist: playlist)
        }
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        var songs = playlist.songs ?? []
        songs.move(fromOffsets: source, toOffset: destination)
        playlist.songs = songs
    }
    
    private func removeSongs(at offsets: IndexSet) {
        var songs = playlist.songs ?? []
        songs.remove(atOffsets: offsets)
        playlist.songs = songs
    }
}

// Subview for adding songs
struct AddSongsToPlaylistView: View {
    let playlist: Playlist
    @Query(sort: \Song.title) var allSongs: [Song]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBackground.ignoresSafeArea()
                List(allSongs) { song in
                    Button(action: {
                        toggleSongInPlaylist(song)
                    }) {
                        HStack {
                            Text(song.title)
                                .foregroundStyle(AppTheme.textColor)
                            Spacer()
                            if (playlist.songs?.contains(where: { $0.id == song.id }) == true) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accentColor)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .navigationTitle("Add to Playlist")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }
    
    private func toggleSongInPlaylist(_ song: Song) {
        if var songs = playlist.songs {
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                songs.remove(at: index)
            } else {
                songs.append(song)
            }
            playlist.songs = songs
        }
    }
}
