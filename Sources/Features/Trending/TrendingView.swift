import SwiftUI

struct TrendingView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var videoService = VideoService.shared
  @State private var selectedRegion: String = "United States"

  let regions = ["United States", "United Kingdom", "Japan", "Germany", "France", "India", "Brazil", "Canada"]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        header
        trendingList
      }
    }
    .scrollIndicators(.never)
    .background(settings.themeColors.background)
    .task { await videoService.loadTrending() }
  }

  private var header: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 8) {
          Image(systemName: "flame.fill")
            .font(.title2.weight(.bold))
            .foregroundStyle(.orange)
          Text("Trending")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(settings.themeColors.primaryText)
        }
        Text("What's popular right now")
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
      Spacer()
      Menu {
        ForEach(regions, id: \.self) { region in
          Button(region) { selectedRegion = region }
        }
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "globe")
            .font(.subheadline)
          Text(selectedRegion)
            .font(.subheadline.weight(.medium))
          Image(systemName: "chevron.down")
            .font(.caption)
        }
        .foregroundStyle(settings.themeColors.primaryText)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(settings.themeColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      .menuStyle(.borderlessButton)
    }
    .padding(24)
  }

  private var trendingList: some View {
    LazyVStack(spacing: 0) {
      ForEach(Array(videoService.trendingVideos.enumerated()), id: \.1.id) { index, video in
        TrendingRow(video: video, rank: index + 1) {
          router.openVideo(video)
        }
        if index < videoService.trendingVideos.count - 1 {
          Divider().padding(.leading, 80).padding(.horizontal, 24).background(settings.themeColors.separator)
        }
      }
    }
    .background(settings.themeColors.card)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
  }
}

struct TrendingRow: View {
  let video: Video
  let rank: Int
  var onTap: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: onTap) {
      HStack(alignment: .top, spacing: 16) {
        Text("\(rank)")
          .font(.system(size: 20, weight: .black).monospacedDigit())
          .foregroundStyle(rank <= 3 ? settings.themeColors.accent : settings.themeColors.tertiaryText)
          .frame(width: 32, alignment: .center)

        AsyncThumbnail(url: video.thumbnailURL, cornerRadius: 10)
          .frame(width: 140, height: 79)
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

        VStack(alignment: .leading, spacing: 6) {
          Text(video.title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(settings.themeColors.primaryText)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
          Text(video.channelName)
            .font(.caption.weight(.medium))
            .foregroundStyle(settings.themeColors.secondaryText)
          HStack(spacing: 6) {
            Image(systemName: "eye.fill")
              .font(.caption2)
            Text(video.formattedViews)
              .font(.caption)
            Text("·")
            Text(video.relativeUploadDate)
              .font(.caption)
          }
          .foregroundStyle(settings.themeColors.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 14)
      .background(isHovered ? settings.themeColors.cardHover : Color.clear)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.18), value: isHovered)
  }
}
