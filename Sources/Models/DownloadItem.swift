import Foundation

struct DownloadItem: Identifiable, Codable {
  var id: String
  var video: Video
  var format: DownloadFormat
  var quality: DownloadQuality
  var status: DownloadStatus
  var progress: Double
  var filePath: URL?
  var fileSize: Int64?
  var startedAt: Date
  var completedAt: Date?
  var error: String?
  var includeSubtitles: Bool
  var includeThumbnail: Bool
  var includeMetadata: Bool

  var formattedFileSize: String {
    guard let size = fileSize else { return "Unknown" }
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useAll]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: size)
  }
}

enum DownloadFormat: String, Codable, CaseIterable {
  case mp4 = "MP4"
  case mp3 = "MP3"
  case opus = "Opus"
  case webm = "WebM"

  var systemImage: String {
    switch self {
    case .mp4: return "film"
    case .mp3: return "music.note"
    case .opus: return "waveform"
    case .webm: return "video"
    }
  }
}

enum DownloadQuality: String, Codable, CaseIterable {
  case best = "Best"
  case p2160 = "4K (2160p)"
  case p1080 = "1080p"
  case p720 = "720p"
  case p480 = "480p"
  case p360 = "360p"
}

enum DownloadStatus: String, Codable {
  case queued = "Queued"
  case downloading = "Downloading"
  case processing = "Processing"
  case completed = "Completed"
  case failed = "Failed"
  case paused = "Paused"
  case cancelled = "Cancelled"

  var systemImage: String {
    switch self {
    case .queued: return "clock"
    case .downloading: return "arrow.down.circle"
    case .processing: return "gearshape"
    case .completed: return "checkmark.circle.fill"
    case .failed: return "exclamationmark.circle.fill"
    case .paused: return "pause.circle.fill"
    case .cancelled: return "xmark.circle.fill"
    }
  }
}
