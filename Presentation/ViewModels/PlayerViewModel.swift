import Foundation
import Combine
import SwiftUI

@MainActor
final class PlayerViewModel: ObservableObject {
    
    @Published var currentSong: Song?
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isShuffleOn: Bool = false
    @Published var repeatMode: RepeatMode = .none
    
    private var cancellables = Set<AnyCancellable>()
    private let playerService = AudioPlayerService.shared

    init() {
        // Sync with service
        playerService.$currentSong.assign(to: &$currentSong)
        playerService.$playbackState.assign(to: &$playbackState)
        playerService.$currentTime.assign(to: &$currentTime)
        playerService.$duration.assign(to: &$duration)
        playerService.$isShuffleOn.assign(to: &$isShuffleOn)
        playerService.$repeatMode.assign(to: &$repeatMode)
    }

    func togglePlayPause() {
        playerService.togglePlayPause()
    }

    func next() {
        playerService.nextTracking()
    }

    func previous() {
        playerService.previousTrack()
    }

    func seek(to time: TimeInterval) {
        playerService.seek(to: time)
    }
}
