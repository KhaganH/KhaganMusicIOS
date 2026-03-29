import SwiftUI
import SwiftData

@main
struct KhaganMusicApp: App {
    
    // SwiftData container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Song.self,
            Playlist.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark) // modern dark theme
        }
        .modelContainer(sharedModelContainer)
    }
}
