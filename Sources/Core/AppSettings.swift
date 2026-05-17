import SwiftUI
import Combine

@Observable
final class AppSettings {
  static let shared = AppSettings()

  // Appearance
  var theme: AppTheme = .dark {
    didSet { UserDefaults.standard.set(theme.rawValue, forKey: "theme") }
  }
  var accentColor: AccentColorOption = .purple {
    didSet { UserDefaults.standard.set(accentColor.rawValue, forKey: "accentColor") }
  }
  var density: UIDensity = .comfortable {
    didSet { UserDefaults.standard.set(density.rawValue, forKey: "density") }
  }
  var reducedMotion: Bool = false {
    didSet { UserDefaults.standard.set(reducedMotion, forKey: "reducedMotion") }
  }
  var smoothScrolling: Bool = true {
    didSet { UserDefaults.standard.set(smoothScrolling, forKey: "smoothScrolling") }
  }
  var dynamicBlur: Bool = true {
    didSet { UserDefaults.standard.set(dynamicBlur, forKey: "dynamicBlur") }
  }

  // Playback
  var defaultQuality: DownloadQuality = .p1080 {
    didSet { UserDefaults.standard.set(defaultQuality.rawValue, forKey: "defaultQuality") }
  }
  var autoplay: Bool = true {
    didSet { UserDefaults.standard.set(autoplay, forKey: "autoplay") }
  }
  var playbackSpeed: Double = 1.0 {
    didSet { UserDefaults.standard.set(playbackSpeed, forKey: "playbackSpeed") }
  }
  var rememberSpeed: Bool = false {
    didSet { UserDefaults.standard.set(rememberSpeed, forKey: "rememberSpeed") }
  }
  var audioNormalization: Bool = true {
    didSet { UserDefaults.standard.set(audioNormalization, forKey: "audioNormalization") }
  }
  var subtitlesEnabled: Bool = false {
    didSet { UserDefaults.standard.set(subtitlesEnabled, forKey: "subtitlesEnabled") }
  }
  var hardwareDecoding: Bool = true {
    didSet { UserDefaults.standard.set(hardwareDecoding, forKey: "hardwareDecoding") }
  }

  // SponsorBlock
  var sponsorBlockEnabled: Bool = true {
    didSet { UserDefaults.standard.set(sponsorBlockEnabled, forKey: "sponsorBlockEnabled") }
  }
  var skipSponsors: Bool = true {
    didSet { UserDefaults.standard.set(skipSponsors, forKey: "skipSponsors") }
  }
  var skipIntros: Bool = true {
    didSet { UserDefaults.standard.set(skipIntros, forKey: "skipIntros") }
  }
  var skipOutros: Bool = false {
    didSet { UserDefaults.standard.set(skipOutros, forKey: "skipOutros") }
  }
  var skipSelfPromo: Bool = false {
    didSet { UserDefaults.standard.set(skipSelfPromo, forKey: "skipSelfPromo") }
  }
  var skipInteractions: Bool = false {
    didSet { UserDefaults.standard.set(skipInteractions, forKey: "skipInteractions") }
  }
  var showTimelineMarkers: Bool = true {
    didSet { UserDefaults.standard.set(showTimelineMarkers, forKey: "showTimelineMarkers") }
  }

  // Downloads
  var downloadPath: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first! {
    didSet { UserDefaults.standard.set(downloadPath.path, forKey: "downloadPath") }
  }
  var defaultFormat: DownloadFormat = .mp4 {
    didSet { UserDefaults.standard.set(defaultFormat.rawValue, forKey: "defaultFormat") }
  }
  var downloadQuality: DownloadQuality = .p1080 {
    didSet { UserDefaults.standard.set(downloadQuality.rawValue, forKey: "downloadQuality") }
  }
  var maxConcurrentDownloads: Int = 3 {
    didSet { UserDefaults.standard.set(maxConcurrentDownloads, forKey: "maxConcurrentDownloads") }
  }
  var embedSubtitles: Bool = true {
    didSet { UserDefaults.standard.set(embedSubtitles, forKey: "embedSubtitles") }
  }
  var embedThumbnail: Bool = true {
    didSet { UserDefaults.standard.set(embedThumbnail, forKey: "embedThumbnail") }
  }
  var embedMetadata: Bool = true {
    didSet { UserDefaults.standard.set(embedMetadata, forKey: "embedMetadata") }
  }

  // General
  var launchAtLogin: Bool = false {
    didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
  }
  var showMenuBarIcon: Bool = false {
    didSet { UserDefaults.standard.set(showMenuBarIcon, forKey: "showMenuBarIcon") }
  }
  var checkForUpdates: Bool = true {
    didSet { UserDefaults.standard.set(checkForUpdates, forKey: "checkForUpdates") }
  }

  var themeColors: ThemeColors {
    ThemeColors.colors(for: theme, accent: accentColor)
  }

  private init() {
    load()
  }

  private func load() {
    if let v = UserDefaults.standard.string(forKey: "theme"), let t = AppTheme(rawValue: v) { theme = t }
    if let v = UserDefaults.standard.string(forKey: "accentColor"), let t = AccentColorOption(rawValue: v) { accentColor = t }
    if let v = UserDefaults.standard.string(forKey: "density"), let t = UIDensity(rawValue: v) { density = t }
    reducedMotion = UserDefaults.standard.bool(forKey: "reducedMotion")
    smoothScrolling = UserDefaults.standard.object(forKey: "smoothScrolling") as? Bool ?? true
    dynamicBlur = UserDefaults.standard.object(forKey: "dynamicBlur") as? Bool ?? true
    autoplay = UserDefaults.standard.object(forKey: "autoplay") as? Bool ?? true
    sponsorBlockEnabled = UserDefaults.standard.object(forKey: "sponsorBlockEnabled") as? Bool ?? true
    skipSponsors = UserDefaults.standard.object(forKey: "skipSponsors") as? Bool ?? true
    skipIntros = UserDefaults.standard.object(forKey: "skipIntros") as? Bool ?? true
    skipOutros = UserDefaults.standard.object(forKey: "skipOutros") as? Bool ?? false
    skipSelfPromo = UserDefaults.standard.object(forKey: "skipSelfPromo") as? Bool ?? false
    skipInteractions = UserDefaults.standard.object(forKey: "skipInteractions") as? Bool ?? false
    showTimelineMarkers = UserDefaults.standard.object(forKey: "showTimelineMarkers") as? Bool ?? true
    embedSubtitles = UserDefaults.standard.object(forKey: "embedSubtitles") as? Bool ?? true
    embedThumbnail = UserDefaults.standard.object(forKey: "embedThumbnail") as? Bool ?? true
    embedMetadata = UserDefaults.standard.object(forKey: "embedMetadata") as? Bool ?? true
    audioNormalization = UserDefaults.standard.object(forKey: "audioNormalization") as? Bool ?? true
    hardwareDecoding = UserDefaults.standard.object(forKey: "hardwareDecoding") as? Bool ?? true
    if let v = UserDefaults.standard.string(forKey: "defaultFormat"), let f = DownloadFormat(rawValue: v) { defaultFormat = f }
    if let v = UserDefaults.standard.string(forKey: "downloadQuality"), let q = DownloadQuality(rawValue: v) { downloadQuality = q }
    if let p = UserDefaults.standard.string(forKey: "downloadPath") { downloadPath = URL(fileURLWithPath: p) }
  }
}
