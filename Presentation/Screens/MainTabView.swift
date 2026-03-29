import SwiftUI
import SwiftData

struct MainTabView: View {
    @StateObject private var playerViewModel = PlayerViewModel()
    @State private var selectedTab = 0
    
    init() {
        // Customize TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(AppTheme.primaryBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "music.note.list")
                    }
                    .tag(0)
                
                PlaylistView()
                    .tabItem {
                        Label("Playlists", systemImage: "text.badge.plus")
                    }
                    .tag(1)
            }
            .accentColor(AppTheme.accentColor)
            
            // Global Mini Player
            MiniPlayerView(viewModel: playerViewModel)
        }
    }
}

// Dummy PlaylistView for now
struct PlaylistView: View {
    @Query(sort: \Playlist.createdAt) var playlists: [Playlist]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingCreateDialog = false
    @State private var newPlaylistName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBackground.ignoresSafeArea()
                
                List {
                    ForEach(playlists) { playlist in
                        NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                            HStack {
                                Image(systemName: "text.badge.plus")
                                    .frame(width: 40, height: 40)
                                    .background(AppTheme.secondaryBackground)
                                    .cornerRadius(4)
                                    .foregroundStyle(AppTheme.accentColor)
                                
                                VStack(alignment: .leading) {
                                    Text(playlist.name)
                                        .foregroundStyle(AppTheme.textColor)
                                    Text("\(playlist.songs?.count ?? 0) songs")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.secondaryTextColor)
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deletePlaylists)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isShowingCreateDialog = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(AppTheme.accentColor)
                    }
                }
            }
            .alert("New Playlist", isPresented: $isShowingCreateDialog) {
                TextField("Playlist Name", text: $newPlaylistName)
                Button("Cancel", role: .cancel) { newPlaylistName = "" }
                Button("Create") {
                    createPlaylist()
                }
            } message: {
                Text("Enter a name for your new playlist.")
            }
        }
    }
    
    private func createPlaylist() {
        guard !newPlaylistName.isEmpty else { return }
        let newPlaylist = Playlist(name: newPlaylistName)
        modelContext.insert(newPlaylist)
        newPlaylistName = ""
    }
    
    private func deletePlaylists(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(playlists[index])
        }
    }
}

