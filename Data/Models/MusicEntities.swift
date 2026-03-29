import Foundation
import SwiftData

@Model
final class Song {
    @Attribute(.unique) var id: UUID
    var title: String
    var artist: String
    var album: String?
    var duration: TimeInterval
    var relativeFilePath: String // Relative to Documents folder
    var createdAt: Date
    var lastPlayedAt: Date?
    
    @Relationship(deleteRule: .nullify, inverse: \Playlist.songs)
    var playlists: [Playlist]?

    init(id: UUID = UUID(), 
         title: String, 
         artist: String = "Unknown Artist", 
         album: String? = nil, 
         duration: TimeInterval, 
         relativeFilePath: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.relativeFilePath = relativeFilePath
        self.createdAt = Date()
    }
}

@Model
final class Playlist {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    
    var songs: [Song]? // Order-agnostic in SwiftData relationships

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.songs = []
    }
}
