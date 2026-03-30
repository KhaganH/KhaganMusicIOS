import SwiftUI
import SwiftData

struct DownloadView: View {
    @State private var youtubeLink: String = ""
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    @State private var statusMessage: String = "Sadece .mp3 indirici"
    @Environment(\.modelContext) private var modelContext
    @StateObject private var libraryViewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header Icon
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.accentColor)
                        .padding(.top, 40)
                    
                    Text("YouTube to MP3")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.textColor)
                    
                    // Input TextField
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Paste YouTube Link")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryTextColor)
                            .padding(.leading, 10)
                        
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(AppTheme.secondaryTextColor)
                            TextField("https://youtube.com/watch?v=...", text: $youtubeLink)
                                .foregroundColor(AppTheme.textColor)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            if !youtubeLink.isEmpty {
                                Button(action: { youtubeLink = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.accentColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Download Button
                    Button(action: startDownload) {
                        HStack {
                            if isDownloading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                                Text("Downloading...")
                            } else {
                                Image(systemName: "icloud.and.arrow.down")
                                Text("Download Audio")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            youtubeLink.isEmpty || isDownloading ? 
                                AppTheme.accentColor.opacity(0.5) : AppTheme.accentColor
                        )
                        .cornerRadius(16)
                        .shadow(color: AppTheme.accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .disabled(youtubeLink.isEmpty || isDownloading)
                    .padding(.horizontal, 24)
                    
                    // Status Output
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func startDownload() {
        guard let url = URL(string: youtubeLink), url.host != nil else {
            statusMessage = "Geçersiz bir link girdiniz."
            return
        }
        
        isDownloading = true
        statusMessage = "Bağlanıyor..."
        
        Task {
            do {
                // 1. Extract audio URL from Youtube link
                statusMessage = "Ses Dosyası Ayrıştırılıyor..."
                let (downloadURL, title) = try await YouTubeDownloadService.shared.extractAudio(from: youtubeLink)
                
                // 2. Download the MP3
                statusMessage = "İndiriliyor..."
                let localURL = try await YouTubeDownloadService.shared.downloadFile(from: downloadURL) { progress in
                    self.downloadProgress = progress
                }
                
                // 3. Save to CoreData Library
                statusMessage = "Kütüphaneye Kaydediliyor..."
                libraryViewModel.setContext(modelContext)
                await libraryViewModel.importSongs(from: [localURL])
                
                // Done
                statusMessage = "Başarıyla kütüphanene ('\(title)') eklendi! 🎉"
                youtubeLink = ""
                isDownloading = false
            } catch {
                isDownloading = false
                statusMessage = "Hata oluştu: \(error.localizedDescription)"
            }
        }
    }
}
