import SwiftUI

enum SidebarDestination: String, CaseIterable, Hashable {
  case home = "Home"
  case subscriptions = "Subscriptions"
  case trending = "Trending"
  case search = "Search"
  case library = "Library"
  case watchLater = "Watch Later"
  case playlists = "Playlists"
  case downloads = "Downloads"
  case history = "History"
  case liked = "Liked Videos"
  case extensions = "Extensions"
  case settings = "Settings"

  var systemImage: String {
    switch self {
    case .home: return "house.fill"
    case .subscriptions: return "bell.fill"
    case .trending: return "flame.fill"
    case .search: return "magnifyingglass"
    case .library: return "rectangle.stack.fill"
    case .watchLater: return "clock.fill"
    case .playlists: return "list.triangle"
    case .downloads: return "arrow.down.circle.fill"
    case .history: return "clock.arrow.circlepath"
    case .liked: return "hand.thumbsup.fill"
    case .extensions: return "puzzlepiece.extension.fill"
    case .settings: return "gearshape.fill"
    }
  }
}

@Observable
final class NavigationRouter {
  static let shared = NavigationRouter()

  var selectedDestination: SidebarDestination = .home
  var selectedVideo: Video? = nil
  var isPlayerPresented: Bool = false
  var isMiniPlayerVisible: Bool = false
  var isSidebarCollapsed: Bool = false
  var searchQuery: String = ""
  var isSearchFocused: Bool = false

  private init() {}

  func openVideo(_ video: Video) {
    selectedVideo = video
    isPlayerPresented = true
    isMiniPlayerVisible = false
  }

  func dismissPlayer() {
    isPlayerPresented = false
  }

  func openMiniPlayer() {
    isPlayerPresented = false
    isMiniPlayerVisible = true
  }

  func navigate(to destination: SidebarDestination) {
    selectedDestination = destination
  }
}
