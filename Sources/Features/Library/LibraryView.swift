import SwiftUI

struct LibraryView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var selectedTab: LibraryTab = .watchLater

  var body: some View {
    VStack(spacing: 0) {
      tabBar
      tabContent
    }
    .background(settings.themeColors.background)
  }

  private var tabBar: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        ForEach(LibraryTab.allCases, id: \.self) { tab in
          CategoryChip(title: tab.rawValue, isSelected: selectedTab == tab) {
            withAnimation(.spring(duration: 0.25)) { selectedTab = tab }
          }
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 14)
    }
    .scrollIndicators(.never)
    .background(.ultraThinMaterial)
    .overlay(alignment: .bottom) {
      Rectangle().fill(settings.themeColors.separator).frame(height: 0.5)
    }
  }

  @ViewBuilder
  private var tabContent: some View {
    switch selectedTab {
    case .watchLater, .history, .liked:
      genericVideoList(for: selectedTab)
    case .playlists:
      playlistsView
    case .subscriptions:
      subscriptionsGrid
    }
  }

  private func genericVideoList(for tab: LibraryTab) -> some View {
    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    return ScrollView {
      if Video.mockFeed.isEmpty {
        emptyState(for: tab)
      } else {
        LazyVGrid(columns: columns, spacing: 14) {
          ForEach(Video.mockFeed.shuffled().prefix(12)) { video in
            VideoCard(video: video, onPlay: { router.openVideo(video) })
          }
        }
        .padding(24)
      }
    }
    .scrollIndicators(.never)
  }

  private var playlistsView: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
        ForEach(mockPlaylists) { playlist in
          PlaylistCard(playlist: playlist)
        }
      }
      .padding(24)
    }
    .scrollIndicators(.never)
  }

  private var subscriptionsGrid: some View {
    ScrollView {
      VStack(spacing: 16) {
        ForEach(Channel.mockSubscriptions) { channel in
          ChannelRow(channel: channel)
        }
      }
      .padding(24)
    }
    .scrollIndicators(.never)
  }

  private func emptyState(for tab: LibraryTab) -> some View {
    VStack(spacing: 16) {
      Image(systemName: tab.emptyIcon)
        .font(.system(size: 48))
        .foregroundStyle(settings.themeColors.tertiaryText)
      Text(tab.emptyMessage)
        .font(.title3.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 80)
  }

  private var mockPlaylists: [MockPlaylist] {
    [
      MockPlaylist(id: "1", title: "SwiftUI Deep Dives", videoCount: 24, thumbnailURL: URL(string: "https://picsum.photos/seed/pl1/320/180")),
      MockPlaylist(id: "2", title: "WWDC Sessions 2024", videoCount: 56, thumbnailURL: URL(string: "https://picsum.photos/seed/pl2/320/180")),
      MockPlaylist(id: "3", title: "Design Inspiration", videoCount: 18, thumbnailURL: URL(string: "https://picsum.photos/seed/pl3/320/180")),
      MockPlaylist(id: "4", title: "Chill Music", videoCount: 72, thumbnailURL: URL(string: "https://picsum.photos/seed/pl4/320/180"))
    ]
  }
}

enum LibraryTab: String, CaseIterable {
  case watchLater = "Watch Later"
  case history = "History"
  case liked = "Liked"
  case playlists = "Playlists"
  case subscriptions = "Subscriptions"

  var emptyIcon: String {
    switch self {
    case .watchLater: return "clock"
    case .history: return "clock.arrow.circlepath"
    case .liked: return "hand.thumbsup"
    case .playlists: return "list.triangle"
    case .subscriptions: return "bell"
    }
  }

  var emptyMessage: String {
    switch self {
    case .watchLater: return "Watch later is empty"
    case .history: return "No watch history yet"
    case .liked: return "No liked videos yet"
    case .playlists: return "No playlists yet"
    case .subscriptions: return "Not subscribed to anyone"
    }
  }
}

struct MockPlaylist: Identifiable {
  var id: String
  var title: String
  var videoCount: Int
  var thumbnailURL: URL?
}

struct PlaylistCard: View {
  let playlist: MockPlaylist
  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ZStack(alignment: .bottomTrailing) {
        AsyncThumbnail(url: playlist.thumbnailURL, cornerRadius: 0)
          .clipShape(UnevenRoundedRectangle(topLeadingRadius: 14, topTrailingRadius: 14))
        Text("\(playlist.videoCount) videos")
          .font(.caption2.bold())
          .foregroundStyle(.white)
          .padding(.horizontal, 7)
          .padding(.vertical, 3)
          .background(.black.opacity(0.75))
          .clipShape(RoundedRectangle(cornerRadius: 4))
          .padding(8)
      }
      .aspectRatio(16 / 9, contentMode: .fit)

      HStack(spacing: 10) {
        VStack(alignment: .leading, spacing: 3) {
          Text(playlist.title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(settings.themeColors.primaryText)
            .lineLimit(1)
          Text("\(playlist.videoCount) videos")
            .font(.caption)
            .foregroundStyle(settings.themeColors.secondaryText)
        }
        Spacer()
        Image(systemName: "play.fill")
          .font(.caption)
          .foregroundStyle(settings.themeColors.accent)
      }
      .padding(12)
    }
    .background(settings.themeColors.card)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .shadow(color: .black.opacity(isHovered ? 0.25 : 0.1), radius: isHovered ? 16 : 6)
    .scaleEffect(isHovered ? 1.02 : 1.0)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.25), value: isHovered)
  }
}

struct ChannelRow: View {
  let channel: Channel
  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    HStack(spacing: 16) {
      AsyncImage(url: channel.avatarURL) { phase in
        if let img = phase.image { img.resizable().scaledToFill() } else { Circle().fill(settings.themeColors.accent.opacity(0.3)) }
      }
      .frame(width: 48, height: 48)
      .clipShape(Circle())

      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 6) {
          Text(channel.name)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(settings.themeColors.primaryText)
          if channel.isVerified {
            Image(systemName: "checkmark.seal.fill")
              .font(.caption)
              .foregroundStyle(.blue)
          }
        }
        Text(channel.formattedSubscribers)
          .font(.caption)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
      Spacer()
      LumetSecondaryButton(title: "Subscribed", icon: "checkmark") {}
    }
    .padding(16)
    .background(settings.themeColors.card)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .onHover { isHovered = $0 }
  }
}
