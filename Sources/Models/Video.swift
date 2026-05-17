import Foundation

struct Video: Identifiable, Codable, Hashable {
  var id: String
  var title: String
  var description: String
  var thumbnailURL: URL?
  var channelID: String
  var channelName: String
  var channelAvatarURL: URL?
  var viewCount: Int
  var likeCount: Int
  var uploadDate: Date
  var duration: TimeInterval
  var isLive: Bool
  var tags: [String]
  var category: VideoCategory
  var qualityOptions: [VideoQuality]
  var chapters: [VideoChapter]

  var formattedViews: String {
    if viewCount >= 1_000_000 {
      return String(format: "%.1fM views", Double(viewCount) / 1_000_000)
    } else if viewCount >= 1_000 {
      return String(format: "%.0fK views", Double(viewCount) / 1_000)
    }
    return "\(viewCount) views"
  }

  var formattedDuration: String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%d:%02d", minutes, seconds)
  }

  var relativeUploadDate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: uploadDate, relativeTo: Date())
  }
}

enum VideoCategory: String, Codable, CaseIterable {
  case all = "All"
  case music = "Music"
  case gaming = "Gaming"
  case news = "News"
  case sports = "Sports"
  case education = "Education"
  case technology = "Technology"
  case entertainment = "Entertainment"
  case films = "Films"
  case live = "Live"
}

struct VideoQuality: Identifiable, Codable, Hashable {
  var id: String { label }
  var label: String
  var resolution: String
  var bitrate: Int
  var url: URL?
}

struct VideoChapter: Identifiable, Codable, Hashable {
  var id: String
  var title: String
  var startTime: TimeInterval
  var thumbnailURL: URL?
}

extension Video {
  static let mock = Video(
    id: "dQw4w9WgXcQ",
    title: "Exploring the Future of Native macOS Development",
    description: "A deep dive into SwiftUI and modern Apple frameworks.",
    thumbnailURL: URL(string: "https://picsum.photos/seed/vid1/640/360"),
    channelID: "UC123",
    channelName: "Apple Developer",
    channelAvatarURL: URL(string: "https://picsum.photos/seed/ch1/64/64"),
    viewCount: 1_240_000,
    likeCount: 45_000,
    uploadDate: Date().addingTimeInterval(-86400 * 3),
    duration: 2340,
    isLive: false,
    tags: ["macOS", "SwiftUI", "development"],
    category: .technology,
    qualityOptions: [
      VideoQuality(label: "Best", resolution: "2160p", bitrate: 15000),
      VideoQuality(label: "1080p", resolution: "1080p", bitrate: 8000),
      VideoQuality(label: "720p", resolution: "720p", bitrate: 4000),
      VideoQuality(label: "480p", resolution: "480p", bitrate: 2000)
    ],
    chapters: []
  )

  static let mockFeed: [Video] = (0..<20).map { i in
    Video(
      id: "vid_\(i)",
      title: [
        "Building a Premium macOS App from Scratch",
        "SwiftUI Mastery: Advanced Animations",
        "The Art of Native UI Design",
        "Apple Silicon Performance Secrets",
        "WWDC 2024: Everything You Missed",
        "macOS Sonoma Deep Dive",
        "Creating Cinematic Video Experiences",
        "AVFoundation Complete Guide",
        "Metal Performance for Apps",
        "Accessibility First Development"
      ][i % 10],
      description: "Amazing content about Apple development and design.",
      thumbnailURL: URL(string: "https://picsum.photos/seed/\(i + 100)/640/360"),
      channelID: "ch_\(i % 5)",
      channelName: ["WWDC Notes", "Swift Weekly", "Design Matters", "Code Craft", "Tech Pulse"][i % 5],
      channelAvatarURL: URL(string: "https://picsum.photos/seed/\(i + 200)/64/64"),
      viewCount: Int.random(in: 10_000...5_000_000),
      likeCount: Int.random(in: 500...200_000),
      uploadDate: Date().addingTimeInterval(-Double.random(in: 3600...86400 * 30)),
      duration: Double.random(in: 120...7200),
      isLive: i == 2,
      tags: ["apple", "swift", "macos"],
      category: VideoCategory.allCases[i % VideoCategory.allCases.count],
      qualityOptions: [
        VideoQuality(label: "1080p", resolution: "1080p", bitrate: 8000),
        VideoQuality(label: "720p", resolution: "720p", bitrate: 4000)
      ],
      chapters: []
    )
  }
}
