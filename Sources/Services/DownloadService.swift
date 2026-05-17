import Foundation

@Observable
final class DownloadService {
  static let shared = DownloadService()

  var downloads: [DownloadItem] = []
  var isYtDlpAvailable: Bool = false

  private init() {
    checkYtDlpAvailability()
    loadMockDownloads()
  }

  private func checkYtDlpAvailability() {
    let paths = ["/usr/local/bin/yt-dlp", "/opt/homebrew/bin/yt-dlp", "/usr/bin/yt-dlp"]
    isYtDlpAvailable = paths.contains { FileManager.default.fileExists(atPath: $0) }
  }

  private func loadMockDownloads() {
    downloads = [
      DownloadItem(
        id: "dl1",
        video: Video.mockFeed[0],
        format: .mp4,
        quality: .p1080,
        status: .completed,
        progress: 1.0,
        filePath: FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appending(path: "video1.mp4"),
        fileSize: 1_234_567_890,
        startedAt: Date().addingTimeInterval(-3600),
        completedAt: Date().addingTimeInterval(-3000),
        includeSubtitles: true,
        includeThumbnail: true,
        includeMetadata: true
      ),
      DownloadItem(
        id: "dl2",
        video: Video.mockFeed[1],
        format: .mp4,
        quality: .p720,
        status: .downloading,
        progress: 0.67,
        filePath: nil,
        fileSize: 456_789_012,
        startedAt: Date().addingTimeInterval(-900),
        completedAt: nil,
        includeSubtitles: false,
        includeThumbnail: true,
        includeMetadata: true
      ),
      DownloadItem(
        id: "dl3",
        video: Video.mockFeed[2],
        format: .mp3,
        quality: .best,
        status: .queued,
        progress: 0.0,
        filePath: nil,
        fileSize: nil,
        startedAt: Date(),
        completedAt: nil,
        includeSubtitles: false,
        includeThumbnail: false,
        includeMetadata: true
      )
    ]
  }

  func startDownload(video: Video, format: DownloadFormat, quality: DownloadQuality,
                     subtitles: Bool, thumbnail: Bool, metadata: Bool) {
    let item = DownloadItem(
      id: UUID().uuidString,
      video: video,
      format: format,
      quality: quality,
      status: .queued,
      progress: 0,
      filePath: nil,
      fileSize: nil,
      startedAt: Date(),
      completedAt: nil,
      includeSubtitles: subtitles,
      includeThumbnail: thumbnail,
      includeMetadata: metadata
    )
    downloads.append(item)
    simulateDownload(id: item.id)
  }

  private func simulateDownload(id: String) {
    Task {
      guard let idx = downloads.firstIndex(where: { $0.id == id }) else { return }
      await MainActor.run { downloads[idx].status = .downloading }
      for tick in 1...20 {
        try? await Task.sleep(for: .milliseconds(300))
        await MainActor.run {
          guard let i = downloads.firstIndex(where: { $0.id == id }) else { return }
          downloads[i].progress = Double(tick) / 20.0
        }
      }
      await MainActor.run {
        guard let i = downloads.firstIndex(where: { $0.id == id }) else { return }
        downloads[i].status = .completed
        downloads[i].progress = 1.0
        downloads[i].completedAt = Date()
        downloads[i].fileSize = Int64.random(in: 100_000_000...2_000_000_000)
      }
    }
  }

  func pauseDownload(id: String) {
    guard let i = downloads.firstIndex(where: { $0.id == id }) else { return }
    downloads[i].status = .paused
  }

  func resumeDownload(id: String) {
    guard let i = downloads.firstIndex(where: { $0.id == id }) else { return }
    downloads[i].status = .downloading
    simulateDownload(id: id)
  }

  func cancelDownload(id: String) {
    downloads.removeAll { $0.id == id }
  }

  func retryDownload(id: String) {
    guard let i = downloads.firstIndex(where: { $0.id == id }) else { return }
    downloads[i].status = .queued
    downloads[i].progress = 0
    simulateDownload(id: id)
  }

  var activeDownloadsCount: Int {
    downloads.filter { $0.status == .downloading }.count
  }

  var totalStorageUsed: Int64 {
    downloads.compactMap { $0.fileSize }.reduce(0, +)
  }
}
