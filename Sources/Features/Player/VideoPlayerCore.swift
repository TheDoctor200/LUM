import SwiftUI
import AVKit
import AppKit

struct VideoPlayerCore: View {
  @State private var player = PlayerService.shared
  @State private var showControls = true
  @State private var isHovered = false

  var body: some View {
    ZStack {
      AVPlayerViewRepresentable(player: player.player)
        .ignoresSafeArea()

      if isHovered || showControls {
        playerControls
          .transition(.opacity)
      }
    }
    .background(Color.black)
    .onHover { h in
      isHovered = h
      if h { player.showControlsTemporarily() }
    }
    .onAppear { showControls = true }
  }

  private var playerControls: some View {
    VStack(spacing: 0) {
      topBar
      Spacer()
      bottomBar
    }
    .background(
      LinearGradient(
        colors: [.black.opacity(0.7), .clear, .clear, .black.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
      )
    )
  }

  private var topBar: some View {
    HStack(spacing: 12) {
      Spacer()
      ControlButton(icon: "pip.enter", label: "Picture in Picture") {
        player.isPiPActive.toggle()
      }
      ControlButton(icon: player.isTheaterMode ? "rectangle.compress.vertical" : "rectangle.expand.vertical", label: "Theater Mode") {}
      ControlButton(icon: "arrow.up.left.and.arrow.down.right", label: "Fullscreen") {
        player.isFullscreen.toggle()
      }
    }
    .padding(14)
  }

  private var bottomBar: some View {
    VStack(spacing: 8) {
      progressBar
      HStack(alignment: .center, spacing: 14) {
        ControlButton(icon: "backward.fill", label: "Previous") { player.seekRelative(seconds: -10) }
        ControlButton(icon: player.isPlaying ? "pause.fill" : "play.fill", label: player.isPlaying ? "Pause" : "Play", size: 22) {
          player.togglePlayback()
        }
        ControlButton(icon: "forward.fill", label: "Next") { player.seekRelative(seconds: 10) }

        volumeControl

        Text(timeString)
          .font(.caption.weight(.medium).monospacedDigit())
          .foregroundStyle(.white.opacity(0.9))

        Spacer()

        speedMenu
        audioOnlyButton
        subtitleButton
        qualityButton
      }
      .padding(.horizontal, 14)
      .padding(.bottom, 12)
    }
  }

  private var progressBar: some View {
    let duration = max(player.duration, 1)
    let progress = player.currentTime / duration
    let buffered = player.bufferedTime / duration

    return GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule().fill(.white.opacity(0.2)).frame(height: 4)
        Capsule().fill(.white.opacity(0.4)).frame(width: geo.size.width * buffered, height: 4)
        Capsule().fill(Color(hex: "#7C5CFF")).frame(width: geo.size.width * progress, height: 4)
        Circle()
          .fill(.white)
          .frame(width: 14, height: 14)
          .shadow(color: .black.opacity(0.4), radius: 4)
          .offset(x: max(0, geo.size.width * progress - 7))
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { drag in
            let fraction = drag.location.x / geo.size.width
            player.seek(to: min(max(0, fraction), 1) * player.duration)
          }
      )
    }
    .frame(height: 14)
    .padding(.horizontal, 14)
    .padding(.top, 8)
  }

  private var volumeControl: some View {
    HStack(spacing: 6) {
      ControlButton(icon: player.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill", label: "Mute") {
        player.toggleMute()
      }
      Slider(value: Binding(
        get: { Double(player.volume) },
        set: { player.setVolume(Float($0)) }
      ), in: 0...1) {
        Text("Volume")
      } minimumValueLabel: {
        Image(systemName: "speaker")
          .font(.caption2)
          .foregroundStyle(.white.opacity(0.6))
      } maximumValueLabel: {
        Image(systemName: "speaker.wave.3")
          .font(.caption2)
          .foregroundStyle(.white.opacity(0.6))
      }
      .tint(.white)
      .frame(width: 80)
    }
  }

  private var speedMenu: some View {
    Menu {
      ForEach([0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], id: \.self) { speed in
        Button("\(speed == 1.0 ? "Normal" : "\(speed)x")") {
          player.setPlaybackRate(Float(speed))
        }
      }
    } label: {
      HStack(spacing: 4) {
        Image(systemName: "gauge.with.dots.needle.67percent")
          .font(.caption)
        Text(player.playbackRate == 1.0 ? "1×" : "\(player.playbackRate, specifier: "%.2g")×")
          .font(.caption.weight(.semibold))
      }
      .foregroundStyle(.white.opacity(0.9))
    }
    .menuStyle(.borderlessButton)
    .fixedSize()
  }

  private var audioOnlyButton: some View {
    ControlButton(icon: player.isAudioOnly ? "waveform" : "waveform", label: "Audio Only") {
      player.isAudioOnly.toggle()
    }
  }

  private var subtitleButton: some View {
    ControlButton(icon: "captions.bubble", label: "Subtitles") {}
  }

  private var qualityButton: some View {
    Menu {
      ForEach(Video.mock.qualityOptions) { q in
        Button(q.label) {}
      }
    } label: {
      Text("HD")
        .font(.caption.weight(.bold))
        .foregroundStyle(.white.opacity(0.9))
    }
    .menuStyle(.borderlessButton)
    .fixedSize()
  }

  private var timeString: String {
    "\(formatTime(player.currentTime)) / \(formatTime(player.duration))"
  }

  private func formatTime(_ t: TimeInterval) -> String {
    let h = Int(t) / 3600
    let m = (Int(t) % 3600) / 60
    let s = Int(t) % 60
    return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
  }
}

struct ControlButton: View {
  let icon: String
  let label: String
  var size: CGFloat = 15
  var action: () -> Void

  @State private var isHovered = false

  var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .font(.system(size: size, weight: .medium))
        .foregroundStyle(.white.opacity(isHovered ? 1.0 : 0.85))
        .frame(width: size + 16, height: size + 16)
        .background(isHovered ? Color.white.opacity(0.15) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .scaleEffect(isHovered ? 1.1 : 1.0)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.15), value: isHovered)
    .help(label)
  }
}

struct AVPlayerViewRepresentable: NSViewRepresentable {
  var player: AVPlayer?

  func makeNSView(context: Context) -> AVPlayerView {
    let view = AVPlayerView()
    view.controlsStyle = .none
    view.player = player
    return view
  }

  func updateNSView(_ nsView: AVPlayerView, context: Context) {
    nsView.player = player
  }
}
