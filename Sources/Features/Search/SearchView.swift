import SwiftUI

struct SearchView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var videoService = VideoService.shared
  @State private var query = ""
  @State private var isFocused = false
  @State private var recentSearches: [String] = ["SwiftUI tutorial", "macOS Sonoma", "Apple Event 2024", "WWDC sessions"]
  @State private var selectedFilter: SearchFilter = .all
  @State private var downloadTarget: Video? = nil
  @State private var showDownloadSheet = false

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        searchBar
        filterBar
        content
      }
    }
    .scrollIndicators(.never)
    .background(settings.themeColors.background)
    .sheet(isPresented: $showDownloadSheet) {
      if let video = downloadTarget {
        DownloadSheet(video: video, isPresented: $showDownloadSheet)
      }
    }
  }

  private var searchBar: some View {
    HStack(spacing: 12) {
      HStack(spacing: 10) {
        Image(systemName: videoService.isLoadingSearch ? "arrow.triangle.2.circlepath" : "magnifyingglass")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(isFocused ? settings.themeColors.accent : settings.themeColors.secondaryText)
          .rotationEffect(.degrees(videoService.isLoadingSearch ? 360 : 0))
          .animation(videoService.isLoadingSearch ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: videoService.isLoadingSearch)

        TextField("Search YouTube…", text: $query)
          .textFieldStyle(.plain)
          .font(.system(size: 15))
          .foregroundStyle(settings.themeColors.primaryText)
          .onSubmit { performSearch() }
          .onChange(of: query) { _, new in
            Task { await videoService.search(query: new) }
          }

        if !query.isEmpty {
          Button {
            query = ""
            videoService.searchResults = []
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 13))
              .foregroundStyle(settings.themeColors.tertiaryText)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(settings.themeColors.card)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .strokeBorder(isFocused ? settings.themeColors.accent.opacity(0.6) : settings.themeColors.separator, lineWidth: 1)
          )
      )
      .onTapGesture { isFocused = true }

      if !query.isEmpty {
        LumetPrimaryButton(title: "Search", icon: "magnifyingglass") {
          performSearch()
        }
      }
    }
    .padding(20)
  }

  private var filterBar: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        ForEach(SearchFilter.allCases, id: \.self) { filter in
          CategoryChip(
            title: filter.rawValue,
            isSelected: selectedFilter == filter
          ) {
            withAnimation(.spring(duration: 0.25)) { selectedFilter = filter }
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 12)
    }
    .scrollIndicators(.never)
  }

  @ViewBuilder
  private var content: some View {
    if query.isEmpty {
      recentSearchSection
    } else if videoService.isLoadingSearch {
      searchSkeletons
    } else if videoService.searchResults.isEmpty {
      emptyState
    } else {
      searchResultsGrid
    }
  }

  private var recentSearchSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Recent Searches")
        .font(.headline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)
        .padding(.horizontal, 20)

      VStack(spacing: 2) {
        ForEach(recentSearches, id: \.self) { search in
          Button {
            query = search
            Task { await videoService.search(query: search) }
          } label: {
            HStack(spacing: 12) {
              Image(systemName: "clock")
                .font(.system(size: 13))
                .foregroundStyle(settings.themeColors.tertiaryText)
              Text(search)
                .font(.subheadline)
                .foregroundStyle(settings.themeColors.primaryText)
              Spacer()
              Image(systemName: "arrow.up.left")
                .font(.system(size: 11))
                .foregroundStyle(settings.themeColors.tertiaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
          }
          .buttonStyle(.plain)
          .background(settings.themeColors.background)
          .onHover { isHovered in
            // Hover handled by system
          }
        }
      }

      Spacer(minLength: 40)
    }
    .padding(.top, 8)
  }

  private var searchResultsGrid: some View {
    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    return LazyVGrid(columns: columns, spacing: 14) {
      ForEach(videoService.searchResults) { video in
        VideoCard(
          video: video,
          onPlay: { router.openVideo(video) },
          onSave: {},
          onDownload: {
            downloadTarget = video
            showDownloadSheet = true
          }
        )
        .transition(.opacity)
      }
    }
    .padding(20)
    .animation(.spring(duration: 0.3), value: videoService.searchResults.map { $0.id })
  }

  private var searchSkeletons: some View {
    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    return LazyVGrid(columns: columns, spacing: 14) {
      ForEach(0..<6, id: \.self) { _ in
        VStack(alignment: .leading, spacing: 0) {
          ShimmerView().aspectRatio(16 / 9, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 12))
          VStack(spacing: 6) {
            ShimmerView().frame(height: 12).clipShape(RoundedRectangle(cornerRadius: 4))
            ShimmerView().frame(height: 10).frame(maxWidth: 120, alignment: .leading).clipShape(RoundedRectangle(cornerRadius: 4))
          }
          .padding(12)
        }
        .background(settings.themeColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
    .padding(20)
  }

  private var emptyState: some View {
    VStack(spacing: 20) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 48))
        .foregroundStyle(settings.themeColors.tertiaryText)
      VStack(spacing: 6) {
        Text("No results for \"\(query)\"")
          .font(.title3.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text("Try different keywords or check for typos.")
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 80)
  }

  private func performSearch() {
    if !query.isEmpty && !recentSearches.contains(query) {
      recentSearches.insert(query, at: 0)
      if recentSearches.count > 8 { recentSearches.removeLast() }
    }
    Task { await videoService.search(query: query) }
  }
}

enum SearchFilter: String, CaseIterable {
  case all = "All"
  case videos = "Videos"
  case channels = "Channels"
  case playlists = "Playlists"
  case live = "Live"
  case shortVideos = "Short Videos"
}
