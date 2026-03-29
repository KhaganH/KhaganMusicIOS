import Foundation
import AVFoundation
import MediaPlayer
import Combine

enum PlaybackState {
    case playing
    case paused
    case stopped
}

enum RepeatMode {
    case none
    case one
    case all
}

final class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()
    
    @Published var currentSong: Song?
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isShuffleOn: Bool = false
    @Published var repeatMode: RepeatMode = .none
    
    private var player: AVPlayer?
    private var queue: [Song] = []
    private var currentIndex: Int = -1
    private var timeObserver: Any?
    
    private init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    func setQueue(_ songs: [Song], startWith song: Song) {
        self.queue = songs
        self.currentIndex = songs.firstIndex(where: { $0.id == song.id }) ?? 0
        play(song: song)
    }
    
    func play(song: Song) {
        let url = FileStorageService.shared.getURL(from: song.relativeFilePath)
        let playerItem = AVPlayerItem(url: url)
        
        // Remove old observer
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        
        player = AVPlayer(playerItem: playerItem)
        currentSong = song
        playbackState = .playing
        duration = song.duration
        
        player?.play()
        updateNowPlayingInfo(song: song)
        
        // Observe time
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.handleFinishedPlaying()
        }
    }
    
    func togglePlayPause() {
        if playbackState == .playing {
            player?.pause()
            playbackState = .paused
        } else if playbackState == .paused {
            player?.play()
            playbackState = .playing
        }
    }
    
    func nextTracking() {
        guard !queue.isEmpty else { return }
        
        if isShuffleOn {
            currentIndex = Int.random(in: 0..<queue.count)
        } else {
            currentIndex = (currentIndex + 1) % queue.count
        }
        
        play(song: queue[currentIndex])
    }
    
    func previousTrack() {
        guard !queue.isEmpty else { return }
        
        if currentTime > 3.0 {
            seek(to: 0)
        } else {
            currentIndex = (currentIndex - 1 + queue.count) % queue.count
            play(song: queue[currentIndex])
        }
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    // MARK: - Private Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTracking()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrack()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: positionEvent.positionTime)
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlayingInfo(song: Song) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = song.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func handleFinishedPlaying() {
        switch repeatMode {
        case .one:
            seek(to: 0)
            player?.play()
        case .all:
            nextTracking()
        case .none:
            if currentIndex < queue.count - 1 {
                nextTracking()
            } else {
                playbackState = .stopped
            }
        }
    }
}
