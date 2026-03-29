import Foundation

enum FileError: Error {
    case fileAlreadyExists
    case fileMoveFailed
    case fileMissing
    case directoryMissing
}

final class FileStorageService {
    static let shared = FileStorageService()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var musicDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("Music", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
    
    func saveFile(from sourceURL: URL) async throws -> String {
        // Start accessing security-scoped resource if it's from UIDocumentPicker
        let shouldStopAccessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let fileName = sourceURL.lastPathComponent
        let destinationURL = musicDirectory.appendingPathComponent(fileName)
        
        // Checklist: No duplicates
        if fileManager.fileExists(atPath: destinationURL.path) {
            // Already there
            return "Music/\(fileName)"
        }
        
        // Copy to sandbox
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        
        return "Music/\(fileName)"
    }
    
    func getURL(from relativePath: String) -> URL {
        return documentsDirectory.appendingPathComponent(relativePath)
    }
    
    func deleteFile(at relativePath: String) throws {
        let url = documentsDirectory.appendingPathComponent(relativePath)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}
