import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct LibraryView: View {
    @Query(sort: \Song.createdAt, order: .reverse) var songs: [Song]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = LibraryViewModel()
    @State private var isShowingPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                
                VStack {
                    if songs.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 80))
                                .foregroundStyle(AppTheme.accentColor)
                            Text("No music imported yet.")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textColor)
                            Button("Import Music") {
                                isShowingPicker = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.accentColor)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(songs) { song in
                                SongRowView(song: song)
                                    .onTapGesture {
                                        AudioPlayerService.shared.setQueue(songs, startWith: song)
                                    }
                            }
                            .onDelete(perform: deleteSongs)
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Your Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingPicker = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(AppTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $isShowingPicker) {
                DocumentPicker { urls in
                    Task {
                        viewModel.setContext(modelContext)
                        await viewModel.importSongs(from: urls)
                    }
                }
            }
        }
    }
    
    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewModel.setContext(modelContext)
                viewModel.deleteSong(songs[index])
            }
        }
    }
}

private struct SongRowView: View {
    let song: Song
    
    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .frame(width: 40, height: 40)
                .background(AppTheme.secondaryBackground)
                .cornerRadius(4)
                .foregroundStyle(AppTheme.accentColor)
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .foregroundStyle(AppTheme.textColor)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryTextColor)
                    .lineLimit(1)
            }
            Spacer()
            // Optional: Options menu
        }
        .padding(.vertical, 4)
    }
}

// UIDocumentPickerViewController bridge
struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: ([URL]) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onPick(urls)
        }
    }
}
