import SwiftUI

struct HomeView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var videoService = VideoService.shared
  @State private var selectedCategory: VideoCategory = .all
  @State private var downloadTarget: Video? = nil
  @State private var showDownloadSheet = false
  @State private var columns: Int = 3

  var filteredVideos: [Video] {
    if selectedCategory == .all { return videoService.feedVideos }
    return videoService.feedVideos.filter { $0.category == selectedCategory }
  }

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
        Section {
          if videoService.isLoadingFeed {
            skeletonGrid
          } else {
            videoGrid
          }
        } header: {
          categoryBar
        }
      }
    }
    .scrollIndicators(.never)
    .background(settings.themeColors.background)
    .task { await videoService.loadFeed() }
    .sheet(isPresented: $showDownloadSheet) {
      if let video = downloadTarget {
        DownloadSheet(video: video, isPresented: $showDownloadSheet)
      }
    }
    .navigationTitle("Home")
  }

  private var categoryBar: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        ForEach(VideoCategory.allCases, id: \.self) { category in
          CategoryChip(
            title: category.rawValue,
            isSelected: selectedCategory == category
          ) {
            withAnimation(.spring(duration: 0.28)) {
              selectedCategory = category
            }
          }
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
    }
    .scrollIndicators(.never)
    .background(.ultraThinMaterial)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(settings.themeColors.separator)
        .frame(height: 0.5)
    }
  }

  private var videoGrid: some View {
    let gridColumns = Array(repeating: GridItem(.flexible(), spacing: settings.density.cardSpacing), count: columns)

    return LazyVGrid(columns: gridColumns, spacing: settings.density.cardSpacing) {
      ForEach(filteredVideos) { video in
        VideoCard(
          video: video,
          onPlay: { router.openVideo(video) },
          onSave: { Task { await VideoService.shared.saveToWatchLater(video) } },
          onDownload: {
            downloadTarget = video
            showDownloadSheet = true
          }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
      }
    }
    .padding(20)
    .animation(.spring(duration: 0.35), value: filteredVideos.map { $0.id })
    .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
      columns = width > 1200 ? 4 : width > 900 ? 3 : width > 600 ? 2 : 1
    }
  }

  private var skeletonGrid: some View {
    let gridColumns = Array(repeating: GridItem(.flexible(), spacing: settings.density.cardSpacing), count: 3)
    return LazyVGrid(columns: gridColumns, spacing: settings.density.cardSpacing) {
      ForEach(0..<9, id: \.self) { _ in
        VStack(alignment: .leading, spacing: 0) {
          ShimmerView()
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
          VStack(alignment: .leading, spacing: 8) {
            ShimmerView().frame(height: 14).clipShape(RoundedRectangle(cornerRadius: 4))
            ShimmerView().frame(height: 12).frame(maxWidth: .infinity, alignment: .leading)
              .clipShape(RoundedRectangle(cornerRadius: 4))
              .frame(maxWidth: 160)
          }
          .padding(12)
        }
        .background(settings.themeColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
      }
    }
    .padding(20)
  }
}

struct CategoryChip: View {
  let title: String
  var isSelected: Bool
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(isSelected ? .semibold : .regular))
        .foregroundStyle(isSelected ? .white : settings.themeColors.secondaryText)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
          Capsule()
            .fill(isSelected ? settings.themeColors.accent : (isHovered ? settings.themeColors.cardHover : settings.themeColors.card))
        )
        .scaleEffect(isHovered ? 1.04 : 1.0)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isSelected)
  }
}
