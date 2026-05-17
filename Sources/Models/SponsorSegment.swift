import Foundation

struct SponsorSegment: Identifiable, Codable, Hashable {
  var id: String
  var videoID: String
  var startTime: TimeInterval
  var endTime: TimeInterval
  var category: SponsorCategory
  var actionType: SponsorAction
  var votes: Int
  var locked: Bool

  var duration: TimeInterval { endTime - startTime }
}

enum SponsorCategory: String, Codable, CaseIterable {
  case sponsor = "sponsor"
  case intro = "intro"
  case outro = "outro"
  case selfPromo = "selfpromo"
  case interaction = "interaction"
  case preview = "preview"
  case filler = "filler"
  case music = "music_offtopic"

  var displayName: String {
    switch self {
    case .sponsor: return "Sponsor"
    case .intro: return "Intro"
    case .outro: return "Outro"
    case .selfPromo: return "Self-Promotion"
    case .interaction: return "Interaction Reminder"
    case .preview: return "Preview"
    case .filler: return "Filler"
    case .music: return "Off-topic Music"
    }
  }

  var color: String {
    switch self {
    case .sponsor: return "#00D000"
    case .intro: return "#00FFFF"
    case .outro: return "#0202ED"
    case .selfPromo: return "#FFFF00"
    case .interaction: return "#CC00FF"
    case .preview: return "#008FD6"
    case .filler: return "#7300FF"
    case .music: return "#FF9900"
    }
  }
}

enum SponsorAction: String, Codable {
  case skip = "skip"
  case mute = "mute"
  case full = "full"
  case poi = "poi"
}
