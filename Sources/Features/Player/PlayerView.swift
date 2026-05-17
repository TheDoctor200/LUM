import SwiftUI
import AVKit

struct PlayerView: View {
  let video: Video
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var player = PlayerService.shared
  @State private var relatedVideos = Video.mockFeed.shuffled()
  @State private var isDescriptionExpanded = false
  @State private var downloadTarget: Video? = nil
  @State private var showDownloadSheet = false

  var body: some View {
    HStack(spacing: 0) {
      mainContent
      relatedSidebar
    }
    .background(settings.themeColors.background)
    .onAppear { player.load(video: video) }
    .sheet(isPresented: $showDownloadSheet) {
      if let v = downloadTarget {
        DownloadSheet(video: v, isPresented: $showDownloadSheet)
      }
    }
  }

  private var mainContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        videoPlayerSection
        videoInfoSection
      }
    }
    .scrollIndicators(.never)
  }

  private var videoPlayerSection: some View {
    ZStack {
      VideoPlayerCore()
        .aspectRatio(16 / 9, contentMode: .fit)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: settings.isTheaterMode ? 0 : 16))

      if player.isBuffering {
        ProgressView()
          .progressViewStyle(.circular)
          .tint(.white)
      }
    }
    .padding(settings.isTheaterMode ? 0 : 20)
  }

  private var videoInfoSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 10) {
        Text(video.title)
          .font(.title3.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
          .fixedSize(horizontal: false, vertical: true)

        HStack(spacing: 12) {
          Text(video.formattedViews)
          Text("·")
          Text(video.relativeUploadDate)
        }
        .font(.subheadline)
        .foregroundStyle(settings.themeColors.secondaryText)
      }

      HStack(spacing: 12) {
        channelPill
        Spacer()
        actionButtons
      }

      descriptionSection
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 30)
  }

  private var channelPill: some View {
    HStack(spacing: 10) {
      AsyncImage(url: video.channelAvatarURL) { phase in
        if let img = phase.image {
          img.resizable().scaledToFill()
        } else {
          Circle().fill(settings.themeColors.accent.opacity(0.3))
        }
      }
      .frame(width: 36, height: 36)
      .clipShape(Circle())

      VStack(alignment: .leading, spacing: 2) {
        Text(video.channelName)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
      }

      LumetPrimaryButton(title: "Subscribe") {}
        .padding(.leading, 4)
    }
  }

  private var actionButtons: some View {
    HStack(spacing: 8) {
      ActionPill(icon: "hand.thumbsup.fill", label: video.formattedLikes) {}
      ActionPill(icon: "clock.badge.plus", label: "Save") {}
      ActionPill(icon: "arrow.down.circle", label: "Download") {
        downloadTarget = video
        showDownloadSheet = true
      }
      ActionPill(icon: "arrow.turn.up.right", label: "Share") {}
      ActionPill(icon: "ellipsis", label: "") {}
    }
  }

  private var descriptionSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(video.description.isEmpty ? "No description available for this video." : video.description)
        .font(.subheadline)
        .foregroundStyle(settings.themeColors.secondaryText)
        .lineLimit(isDescriptionExpanded ? nil : 3)
        .fixedSize(horizontal: false, vertical: true)

      Button {
        withAnimation(.spring(duration: 0.3)) { isDescriptionExpanded.toggle() }
      } label: {
        Text(isDescriptionExpanded ? "Show less" : "Show more")
          .font(.caption.weight(.semibold))
          .foregroundStyle(settings.themeColors.accent)
      }
      .buttonStyle(.plain)
    }
    .padding(14)
    .background(settings.themeColors.card)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private var relatedSidebar: some View {
    VStack(spacing: 0) {
      Text("Up Next")
        .font(.headline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 12)

      ScrollView {
        LazyVStack(spacing: 8) {
          ForEach(relatedVideos.prefix(15)) { related in
            RelatedVideoRow(video: related) {
              router.openVideo(related)
              player.load(video: related)
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
      }
      .scrollIndicators(.never)
    }
    .frame(width: 360)
    .background(.ultraThinMaterial)
    .overlay(
      Rectangle()
        .fill(settings.themeColors.separator)
        .frame(width: 0.5),
      alignment: .leading
    )
  }
}

extension AppSettings {
  var isTheaterMode: Bool { false }
}

extension Video {
  var formattedLikes: String {
    if likeCount >= 1_000_000 {
      return String(format: "%.1fM", Double(likeCount) / 1_000_000)
    } else if likeCount >= 1_000 {
      return String(format: "%.0fK", Double(likeCount) / 1_000)
    }
    return "\(likeCount)"
  }
}

struct ActionPill: View {
  let icon: String
  let label: String
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        Image(systemName: icon)
          .font(.system(size: 13, weight: .medium))
        if !label.isEmpty {
          Text(label)
            .font(.subheadline.weight(.medium))
        }
      }
      .foregroundStyle(settings.themeColors.primaryText)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(isHovered ? settings.themeColors.cardHover : settings.themeColors.card)
      )
      .scaleEffect(isHovered ? 1.03 : 1.0)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isHovered)
  }
}

struct RelatedVideoRow: View {
  let video: Video
  var onTap: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: onTap) {
      HStack(alignment: .top, spacing: 10) {
        AsyncThumbnail(url: video.thumbnailURL, cornerRadius: 8)
          .frame(width: 120)
          .overlay(alignment: .bottomTrailing) {
            Text(video.formattedDuration)
              .font(.caption2.bold())
              .foregroundStyle(.white)
              .padding(.horizontal, 5)
              .padding(.vertical, 2)
              .background(.black.opacity(0.75))
              .clipShape(RoundedRectangle(cornerRadius: 4))
              .padding(5)
          }

        VStack(alignment: .leading, spacing: 4) {
          Text(video.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(settings.themeColors.primaryText)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
          Text(video.channelName)
            .font(.caption2)
            .foregroundStyle(settings.themeColors.secondaryText)
          Text("\(video.formattedViews) · \(video.relativeUploadDate)")
            .font(.caption2)
            .foregroundStyle(settings.themeColors.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(8)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(isHovered ? settings.themeColors.cardHover : Color.clear)
      )
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.18), value: isHovered)
  }
}
