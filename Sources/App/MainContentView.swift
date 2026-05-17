import SwiftUI

struct MainContentView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var downloadService = DownloadService.shared

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      HStack(spacing: 0) {
        if !router.isSidebarCollapsed {
          SidebarView()
            .transition(.move(edge: .leading).combined(with: .opacity))
        }

        ZStack {
          destinationContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .background(settings.themeColors.background)

      if router.isMiniPlayerVisible {
        MiniPlayerView()
          .padding(20)
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .animation(.spring(duration: 0.35, bounce: 0.1), value: router.isMiniPlayerVisible)
    .animation(.spring(duration: 0.35, bounce: 0.1), value: router.isSidebarCollapsed)
  }

  @ViewBuilder
  private var destinationContent: some View {
    if router.isPlayerPresented, let video = router.selectedVideo {
      PlayerView(video: video)
        .transition(.asymmetric(
          insertion: .move(edge: .trailing).combined(with: .opacity),
          removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    } else {
      switch router.selectedDestination {
      case .home:
        HomeView()
      case .subscriptions:
        SubscriptionsView()
      case .trending:
        TrendingView()
      case .search:
        SearchView()
      case .library, .watchLater, .playlists, .history, .liked:
        LibraryView()
      case .downloads:
        DownloadsView()
      case .extensions:
        ExtensionsView()
      case .settings:
        SettingsView()
      }
    }
  }
}
