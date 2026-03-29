import Foundation
import AVFoundation

struct SongMetadata {
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let artwork: Data?
}

final class MetadataExtractor {
    
    static func extract(from url: URL) async -> SongMetadata {
        let asset = AVAsset(url: url)
        
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var album: String? = nil
        var artwork: Data? = nil
        
        let metadata = try? await asset.load(.metadata)
        let duration = try? await asset.load(.duration).seconds
        
        if let metadata = metadata {
            for item in metadata {
                guard let commonKey = item.commonKey else { continue }
                
                switch commonKey {
                case .commonKeyTitle:
                    title = (try? await item.load(.stringValue)) ?? title
                case .commonKeyArtist:
                    artist = (try? await item.load(.stringValue)) ?? artist
                case .commonKeyAlbumName:
                    album = try? await item.load(.stringValue)
                case .commonKeyArtwork:
                    artwork = try? await item.load(.dataValue)
                default:
                    break
                }
            }
        }
        
        return SongMetadata(
            title: title, 
            artist: artist, 
            album: album, 
            duration: duration ?? 0, 
            artwork: artwork
        )
    }
}
