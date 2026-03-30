import Foundation

enum DownloadError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(String)
    case invalidResponse
}

class YouTubeDownloadService {
    static let shared = YouTubeDownloadService()
    
    // Using a public cobalt-based API for extracting direct media streams.
    // Note: Free public APIs might change endpoints over time.
    private let apiUrl = "https://api.cobalt.tools/api/json"
    
    private init() {}
    
    /// Extracts the direct MP3 download URL from a YouTube link
    func extractAudio(from youtubeURL: String) async throws -> (downloadURL: URL, title: String) {
        guard let url = URL(string: apiUrl) else {
            throw DownloadError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Required headers for Cobalt API
        request.addValue("cobalt.tools", forHTTPHeaderField: "Origin")
        request.addValue("cobalt.tools", forHTTPHeaderField: "Referer")
        
        let payload: [String: Any] = [
            "url": youtubeURL,
            "vQuality": "audiokb",
            "audioFormat": "mp3",
            "isAudioOnly": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.serverError("API returned invalid status code.")
        }
        
        // Parse Cobalt JSON
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let status = json?["status"] as? String, status == "error", let text = json?["text"] as? String {
            throw DownloadError.serverError(text)
        }
        
        guard let downloadUrlString = json?["url"] as? String,
              let downloadURL = URL(string: downloadUrlString) else {
            throw DownloadError.invalidResponse
        }
        
        // Usually, YouTube APIs return the title in metadata or we default to a generic name
        let title = "Downloaded Audio" // Fallback title
        return (downloadURL, title)
    }
    
    /// Downloads the file from the direct URL to a temporary local path
    func downloadFile(from url: URL, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.serverError("Failed to download file payload.")
        }
        
        // Progress isn't easily trackable via the async/await download(from:) without a custom delegate.
        // For simplicity, we just trigger 100% when done.
        progressHandler(1.0)
        
        // Move to a more stable temp file with .mp3 extension so it reads correctly
        let uniqueFileName = UUID().uuidString + ".mp3"
        let stableTempURL = FileManager.default.temporaryDirectory.appendingPathComponent(uniqueFileName)
        
        if FileManager.default.fileExists(atPath: stableTempURL.path) {
            try FileManager.default.removeItem(at: stableTempURL)
        }
        try FileManager.default.moveItem(at: tempURL, to: stableTempURL)
        
        return stableTempURL
    }
}
