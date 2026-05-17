import Foundation

struct AppExtension: Identifiable, Codable {
  var id: String
  var name: String
  var description: String
  var author: String
  var version: String
  var iconName: String
  var isEnabled: Bool
  var permissions: [ExtensionPermission]
  var settings: [ExtensionSetting]
  var bundleID: String
}

enum ExtensionPermission: String, Codable, CaseIterable {
  case videoData = "Video Data"
  case networkAccess = "Network Access"
  case playerControl = "Player Control"
  case uiOverlay = "UI Overlay"
  case downloadAccess = "Download Access"
  case userPreferences = "User Preferences"
}

struct ExtensionSetting: Identifiable, Codable {
  var id: String
  var key: String
  var label: String
  var type: ExtensionSettingType
  var value: String
}

enum ExtensionSettingType: String, Codable {
  case toggle
  case text
  case number
  case selection
}

extension AppExtension {
  static let builtIn: [AppExtension] = [
    AppExtension(
      id: "sponsorblock",
      name: "SponsorBlock",
      description: "Automatically skip sponsored segments, intros, outros, and more using crowd-sourced data.",
      author: "Community",
      version: "3.0",
      iconName: "forward.fill",
      isEnabled: true,
      permissions: [.videoData, .playerControl, .networkAccess],
      settings: [],
      bundleID: "app.lumet.ext.sponsorblock"
    ),
    AppExtension(
      id: "returndislike",
      name: "Return YouTube Dislike",
      description: "Restores the dislike count on YouTube videos using archived data.",
      author: "Community",
      version: "2.1",
      iconName: "hand.thumbsdown",
      isEnabled: true,
      permissions: [.videoData, .networkAccess, .uiOverlay],
      settings: [],
      bundleID: "app.lumet.ext.returndislike"
    ),
    AppExtension(
      id: "transcripts",
      name: "Transcript Tools",
      description: "View and search video transcripts with automatic timestamps and language support.",
      author: "Lumet",
      version: "1.0",
      iconName: "text.bubble",
      isEnabled: false,
      permissions: [.videoData, .networkAccess],
      settings: [],
      bundleID: "app.lumet.ext.transcripts"
    ),
    AppExtension(
      id: "aisummary",
      name: "AI Summaries",
      description: "Get instant AI-generated summaries and key takeaways for any video.",
      author: "Lumet",
      version: "1.0",
      iconName: "sparkles",
      isEnabled: false,
      permissions: [.videoData, .networkAccess],
      settings: [],
      bundleID: "app.lumet.ext.aisummary"
    ),
    AppExtension(
      id: "lyrics",
      name: "Lyrics Overlay",
      description: "Display synchronized lyrics for music videos.",
      author: "Lumet",
      version: "1.2",
      iconName: "music.quarternote.3",
      isEnabled: false,
      permissions: [.videoData, .networkAccess, .uiOverlay],
      settings: [],
      bundleID: "app.lumet.ext.lyrics"
    )
  ]
}
