import Foundation
import SwiftData
import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    
    // ModelContext is passed from the View
    private var modelContext: ModelContext?

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func importSongs(from urls: [URL]) async {
        guard let context = modelContext else { return }
        
        for url in urls {
            do {
                // 1. Save to Sandbox
                let relativePath = try await FileStorageService.shared.saveFile(from: url)
                
                // 2. Extract Metadata
                let fullURL = FileStorageService.shared.getURL(from: relativePath)
                let metadata = await MetadataExtractor.extract(from: fullURL)
                
                // 3. Check if already in DB (Duplicate check)
                let fileName = url.lastPathComponent
                let descriptor = FetchDescriptor<Song>(
                    predicate: #Predicate<Song> { $0.relativeFilePath.contains(fileName) }
                )
                let existing = try? context.fetch(descriptor)
                
                if (existing?.isEmpty ?? true) {
                    // 4. Create and Save Entity
                    let newSong = Song(
                        title: metadata.title,
                        artist: metadata.artist,
                        album: metadata.album,
                        duration: metadata.duration,
                        relativeFilePath: relativePath
                    )
                    context.insert(newSong)
                }
            } catch {
                print("Error importing song: \(error)")
            }
        }
        
        // Save Context
        try? context.save()
    }
    
    func deleteSong(_ song: Song) {
        guard let context = modelContext else { return }
        
        do {
            try FileStorageService.shared.deleteFile(at: song.relativeFilePath)
            context.delete(song)
            try context.save()
        } catch {
            print("Error deleting song: \(error)")
        }
    }
}
