import AVFoundation
import SwiftUI
import Combine

@Observable
final class PlayerService {
  static let shared = PlayerService()

  var player: AVPlayer?
  var currentVideo: Video?
  var isPlaying: Bool = false
  var currentTime: TimeInterval = 0
  var duration: TimeInterval = 0
  var bufferedTime: TimeInterval = 0
  var volume: Float = 1.0
  var isMuted: Bool = false
  var playbackRate: Float = 1.0
  var isBuffering: Bool = false
  var isPiPActive: Bool = false
  var isFullscreen: Bool = false
  var isTheaterMode: Bool = false
  var showControls: Bool = true
  var isAudioOnly: Bool = false
  var queue: [Video] = []
  var sponsorSegments: [SponsorSegment] = []

  private var timeObserver: Any?
  private var cancellables = Set<AnyCancellable>()
  private var controlsTimer: Timer?

  private init() {}

  func load(video: Video) {
    currentVideo = video
    let testURL = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
    let item = AVPlayerItem(url: testURL)
    if player == nil {
      player = AVPlayer(playerItem: item)
    } else {
      player?.replaceCurrentItem(with: item)
    }
    setupObservers()
    player?.play()
    isPlaying = true
    Task {
      sponsorSegments = await SponsorBlockService.shared.fetchSegments(videoID: video.id)
    }
  }

  private func setupObservers() {
    timeObserver.map { player?.removeTimeObserver($0) }
    let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
      self?.currentTime = time.seconds
      self?.checkSponsorSegments(at: time.seconds)
    }
    if let item = player?.currentItem {
      NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
        self?.isPlaying = false
      }
    }
  }

  private func checkSponsorSegments(at time: TimeInterval) {
    let settings = AppSettings.shared
    for segment in sponsorSegments {
      if time >= segment.startTime && time < segment.endTime {
        if SponsorBlockService.shared.shouldSkip(segment: segment, settings: settings) {
          seek(to: segment.endTime)
          return
        }
      }
    }
  }

  func togglePlayback() {
    if isPlaying {
      player?.pause()
    } else {
      player?.play()
    }
    isPlaying.toggle()
  }

  func seek(to time: TimeInterval) {
    let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    currentTime = time
  }

  func seekRelative(seconds: TimeInterval) {
    seek(to: max(0, currentTime + seconds))
  }

  func setVolume(_ vol: Float) {
    volume = vol
    player?.volume = vol
    isMuted = vol == 0
  }

  func toggleMute() {
    isMuted.toggle()
    player?.volume = isMuted ? 0 : volume
  }

  func setPlaybackRate(_ rate: Float) {
    playbackRate = rate
    player?.rate = isPlaying ? rate : 0
  }

  func showControlsTemporarily() {
    showControls = true
    controlsTimer?.invalidate()
    controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
      withAnimation(.easeOut(duration: 0.4)) {
        self?.showControls = false
      }
    }
  }

  func nextInQueue() {
    guard !queue.isEmpty else { return }
    let next = queue.removeFirst()
    load(video: next)
  }
}
