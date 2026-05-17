import SwiftUI

struct VideoCard: View {
  let video: Video
  var onPlay: () -> Void = {}
  var onSave: () -> Void = {}
  var onDownload: () -> Void = {}

  @State private var isHovered = false
  @State private var showActions = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      thumbnailSection
      infoSection
    }
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(settings.themeColors.card)
        .shadow(color: .black.opacity(isHovered ? 0.35 : 0.15), radius: isHovered ? 20 : 8, y: isHovered ? 8 : 3)
    )
    .scaleEffect(isHovered ? 1.025 : 1.0)
    .animation(.spring(duration: 0.3, bounce: 0.2), value: isHovered)
    .onHover { isHovered = $0; showActions = $0 }
    .onTapGesture(perform: onPlay)
  }

  private var thumbnailSection: some View {
    ZStack(alignment: .bottomTrailing) {
      AsyncThumbnail(url: video.thumbnailURL, cornerRadius: 0)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
        .overlay(
          RoundedRectangle(cornerRadius: 0)
            .fill(.black.opacity(isHovered ? 0.3 : 0))
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
        )

      if isHovered {
        HStack(spacing: 8) {
          CardActionButton(icon: "play.fill", label: "Play") { onPlay() }
          CardActionButton(icon: "clock.badge.plus", label: "Watch Later") { onSave() }
          CardActionButton(icon: "arrow.down.circle", label: "Download") { onDownload() }
        }
        .padding(10)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
      }

      HStack(spacing: 0) {
        if video.isLive {
          Text("LIVE")
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
          Text(video.formattedDuration)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.black.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
      }
      .padding(8)
    }
    .aspectRatio(16 / 9, contentMode: .fit)
  }

  private var infoSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(video.title)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)

      HStack(spacing: 6) {
        AsyncImage(url: video.channelAvatarURL) { phase in
          if let img = phase.image {
            img.resizable().scaledToFill()
          } else {
            Circle().fill(Color.white.opacity(0.1))
          }
        }
        .frame(width: 20, height: 20)
        .clipShape(Circle())

        Text(video.channelName)
          .font(.caption.weight(.medium))
          .foregroundStyle(settings.themeColors.secondaryText)

        Spacer()
      }

      HStack(spacing: 4) {
        Text(video.formattedViews)
        Text("·")
        Text(video.relativeUploadDate)
      }
      .font(.caption)
      .foregroundStyle(settings.themeColors.tertiaryText)
    }
    .padding(12)
  }
}

struct CardActionButton: View {
  let icon: String
  let label: String
  var action: () -> Void

  @State private var isHovered = false

  var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white)
        .frame(width: 28, height: 28)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .scaleEffect(isHovered ? 1.15 : 1.0)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isHovered)
    .help(label)
  }
}
