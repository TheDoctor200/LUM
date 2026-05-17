import Foundation

@Observable
final class VideoService {
  static let shared = VideoService()

  var feedVideos: [Video] = []
  var trendingVideos: [Video] = []
  var searchResults: [Video] = []
  var isLoadingFeed: Bool = false
  var isLoadingSearch: Bool = false
  var hasError: Bool = false
  var errorMessage: String = ""

  private init() {}

  func loadFeed() async {
    await MainActor.run { isLoadingFeed = true; hasError = false }
    try? await Task.sleep(for: .milliseconds(800))
    await MainActor.run {
      feedVideos = Video.mockFeed
      isLoadingFeed = false
    }
  }

  func loadTrending() async {
    try? await Task.sleep(for: .milliseconds(600))
    await MainActor.run {
      trendingVideos = Video.mockFeed.shuffled()
    }
  }

  func search(query: String) async {
    guard !query.isEmpty else {
      await MainActor.run { searchResults = [] }
      return
    }
    await MainActor.run { isLoadingSearch = true }
    try? await Task.sleep(for: .milliseconds(500))
    await MainActor.run {
      searchResults = Video.mockFeed.filter {
        $0.title.localizedCaseInsensitiveContains(query) ||
        $0.channelName.localizedCaseInsensitiveContains(query)
      }
      isLoadingSearch = false
    }
  }

  func fetchVideoDetails(id: String) async -> Video? {
    try? await Task.sleep(for: .milliseconds(300))
    return Video.mockFeed.first { $0.id == id } ?? Video.mock
  }

  func likeVideo(_ video: Video) async {}
  func saveToWatchLater(_ video: Video) async {}
  func addToPlaylist(_ video: Video, playlistID: String) async {}
}
