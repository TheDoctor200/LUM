import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
  case system = "System"
  case light = "Light"
  case dark = "Dark"
  case midnight = "Midnight"
  case oled = "OLED"
  case frosted = "Frosted Glass"
}

enum AccentColorOption: String, CaseIterable, Codable {
  case purple = "Purple"
  case blue = "Blue"
  case orange = "Orange"
  case red = "Red"
  case graphite = "Graphite"
  case pink = "Pink"
  case mint = "Mint"

  var color: Color {
    switch self {
    case .purple: return Color(hex: "#7C5CFF")
    case .blue: return Color(hex: "#0A84FF")
    case .orange: return Color(hex: "#FF9F0A")
    case .red: return Color(hex: "#FF453A")
    case .graphite: return Color(hex: "#8E8E93")
    case .pink: return Color(hex: "#FF2D55")
    case .mint: return Color(hex: "#00C7BE")
    }
  }
}

enum UIDensity: String, CaseIterable, Codable {
  case compact = "Compact"
  case comfortable = "Comfortable"
  case spacious = "Spacious"

  var cardSpacing: CGFloat {
    switch self {
    case .compact: return 8
    case .comfortable: return 14
    case .spacious: return 20
    }
  }

  var cardPadding: CGFloat {
    switch self {
    case .compact: return 10
    case .comfortable: return 14
    case .spacious: return 18
    }
  }
}

struct ThemeColors {
  var background: Color
  var secondaryBackground: Color
  var card: Color
  var cardHover: Color
  var surface: Color
  var primaryText: Color
  var secondaryText: Color
  var tertiaryText: Color
  var separator: Color
  var accent: Color
}

extension ThemeColors {
  static func colors(for theme: AppTheme, accent: AccentColorOption) -> ThemeColors {
    let accentColor = accent.color
    switch theme {
    case .system:
      return ThemeColors(
        background: Color(nsColor: .windowBackgroundColor),
        secondaryBackground: Color(nsColor: .underPageBackgroundColor),
        card: Color(nsColor: .controlBackgroundColor),
        cardHover: Color(nsColor: .selectedControlColor).opacity(0.15),
        surface: Color(nsColor: .windowBackgroundColor),
        primaryText: Color(nsColor: .labelColor),
        secondaryText: Color(nsColor: .secondaryLabelColor),
        tertiaryText: Color(nsColor: .tertiaryLabelColor),
        separator: Color(nsColor: .separatorColor),
        accent: accentColor
      )
    case .light:
      return ThemeColors(
        background: Color(hex: "#F5F5F7"),
        secondaryBackground: Color(hex: "#EBEBED"),
        card: Color.white,
        cardHover: Color(hex: "#F0F0F2"),
        surface: Color(hex: "#FFFFFF"),
        primaryText: Color(hex: "#1D1D1F"),
        secondaryText: Color(hex: "#6E6E73"),
        tertiaryText: Color(hex: "#AEAEB2"),
        separator: Color(hex: "#D2D2D7"),
        accent: accentColor
      )
    case .dark:
      return ThemeColors(
        background: Color(hex: "#111111"),
        secondaryBackground: Color(hex: "#0A0A0A"),
        card: Color(hex: "#1A1A1A"),
        cardHover: Color(hex: "#252525"),
        surface: Color(hex: "#1C1C1E"),
        primaryText: Color(hex: "#FFFFFF"),
        secondaryText: Color(hex: "#999999"),
        tertiaryText: Color(hex: "#636366"),
        separator: Color(hex: "#2C2C2E"),
        accent: accentColor
      )
    case .midnight:
      return ThemeColors(
        background: Color(hex: "#0A0A0F"),
        secondaryBackground: Color(hex: "#050508"),
        card: Color(hex: "#12121A"),
        cardHover: Color(hex: "#1A1A28"),
        surface: Color(hex: "#0E0E18"),
        primaryText: Color(hex: "#E8E8FF"),
        secondaryText: Color(hex: "#7878AA"),
        tertiaryText: Color(hex: "#4A4A6A"),
        separator: Color(hex: "#1E1E30"),
        accent: accentColor
      )
    case .oled:
      return ThemeColors(
        background: Color.black,
        secondaryBackground: Color(hex: "#030303"),
        card: Color(hex: "#0D0D0D"),
        cardHover: Color(hex: "#161616"),
        surface: Color(hex: "#080808"),
        primaryText: Color.white,
        secondaryText: Color(hex: "#888888"),
        tertiaryText: Color(hex: "#505050"),
        separator: Color(hex: "#1A1A1A"),
        accent: accentColor
      )
    case .frosted:
      return ThemeColors(
        background: Color(hex: "#1A1A2E").opacity(0.85),
        secondaryBackground: Color(hex: "#16213E").opacity(0.9),
        card: Color.white.opacity(0.08),
        cardHover: Color.white.opacity(0.12),
        surface: Color.white.opacity(0.06),
        primaryText: Color.white,
        secondaryText: Color.white.opacity(0.65),
        tertiaryText: Color.white.opacity(0.35),
        separator: Color.white.opacity(0.1),
        accent: accentColor
      )
    }
  }
}
