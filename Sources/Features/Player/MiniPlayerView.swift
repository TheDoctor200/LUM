import SwiftUI

struct MiniPlayerView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var player = PlayerService.shared
  @State private var isHovered = false
  @State private var isExpanded = false
  @State private var offset: CGSize = .zero

  var body: some View {
    VStack(spacing: 0) {
      if isExpanded {
        expandedContent
      } else {
        compactContent
      }
    }
    .frame(width: isExpanded ? 320 : 280)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 18))
    .shadow(color: .black.opacity(0.4), radius: 24, y: 8)
    .overlay(
      RoundedRectangle(cornerRadius: 18)
        .strokeBorder(settings.themeColors.separator, lineWidth: 0.5)
    )
    .offset(offset)
    .gesture(
      DragGesture()
        .onChanged { offset = $0.translation }
        .onEnded { _ in withAnimation(.spring(duration: 0.4, bounce: 0.3)) { offset = .zero } }
    )
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.3, bounce: 0.2), value: isExpanded)
  }

  private var compactContent: some View {
    HStack(spacing: 10) {
      AsyncThumbnail(url: player.currentVideo?.thumbnailURL, cornerRadius: 8)
        .frame(width: 56, height: 32)

      VStack(alignment: .leading, spacing: 2) {
        Text(player.currentVideo?.title ?? "Nothing playing")
          .font(.caption.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
          .lineLimit(1)
        Text(player.currentVideo?.channelName ?? "")
          .font(.caption2)
          .foregroundStyle(settings.themeColors.secondaryText)
          .lineLimit(1)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      HStack(spacing: 4) {
        MiniControlButton(icon: "backward.fill") { player.seekRelative(seconds: -10) }
        MiniControlButton(icon: player.isPlaying ? "pause.fill" : "play.fill") { player.togglePlayback() }
        MiniControlButton(icon: "forward.fill") { player.seekRelative(seconds: 10) }
      }

      Divider().frame(height: 20)

      MiniControlButton(icon: "arrow.up.left.and.arrow.down.right") {
        withAnimation { isExpanded = true }
      }
      MiniControlButton(icon: "xmark") {
        router.isMiniPlayerVisible = false
        player.isPlaying = false
        player.player?.pause()
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
  }

  private var expandedContent: some View {
    VStack(spacing: 0) {
      HStack {
        Spacer()
        MiniControlButton(icon: "arrow.down.right.and.arrow.up.left") {
          withAnimation { isExpanded = false }
        }
        MiniControlButton(icon: "arrow.up.backward.and.arrow.down.forward") {
          if let video = player.currentVideo {
            router.openVideo(video)
          }
          router.isMiniPlayerVisible = false
        }
        MiniControlButton(icon: "xmark") {
          router.isMiniPlayerVisible = false
          player.isPlaying = false
          player.player?.pause()
        }
      }
      .padding(.horizontal, 12)
      .padding(.top, 10)
      .padding(.bottom, 6)

      AsyncThumbnail(url: player.currentVideo?.thumbnailURL, cornerRadius: 10)
        .padding(.horizontal, 12)

      VStack(alignment: .leading, spacing: 4) {
        Text(player.currentVideo?.title ?? "Nothing playing")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
          .lineLimit(2)
        Text(player.currentVideo?.channelName ?? "")
          .font(.caption)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
      .padding(.horizontal, 14)
      .padding(.top, 10)
      .frame(maxWidth: .infinity, alignment: .leading)

      miniProgressBar
        .padding(.horizontal, 14)
        .padding(.top, 10)

      HStack(spacing: 20) {
        MiniControlButton(icon: "backward.fill", size: 16) { player.seekRelative(seconds: -15) }
        MiniControlButton(icon: player.isPlaying ? "pause.fill" : "play.fill", size: 22) { player.togglePlayback() }
        MiniControlButton(icon: "forward.fill", size: 16) { player.seekRelative(seconds: 15) }
      }
      .padding(.vertical, 14)
    }
  }

  private var miniProgressBar: some View {
    let duration = max(player.duration, 1)
    let progress = player.currentTime / duration
    return GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule().fill(Color.white.opacity(0.15)).frame(height: 3)
        Capsule()
          .fill(settings.themeColors.accent)
          .frame(width: geo.size.width * progress, height: 3)
      }
    }
    .frame(height: 3)
  }
}

struct MiniControlButton: View {
  let icon: String
  var size: CGFloat = 13
  var action: () -> Void

  @State private var isHovered = false

  var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .font(.system(size: size, weight: .medium))
        .foregroundStyle(Color.primary.opacity(isHovered ? 1 : 0.75))
        .frame(width: 28, height: 28)
        .background(isHovered ? Color.primary.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.15), value: isHovered)
  }
}
