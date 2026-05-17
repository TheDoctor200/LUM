import SwiftUI

enum SettingsSection: String, CaseIterable, Hashable {
  case general = "General"
  case appearance = "Appearance"
  case playback = "Playback"
  case downloads = "Downloads"
  case sponsorBlock = "SponsorBlock"
  case accounts = "Accounts"
  case extensions = "Extensions"
  case advanced = "Advanced"

  var systemImage: String {
    switch self {
    case .general: return "gearshape"
    case .appearance: return "paintbrush.fill"
    case .playback: return "play.rectangle.fill"
    case .downloads: return "arrow.down.circle.fill"
    case .sponsorBlock: return "forward.fill"
    case .accounts: return "person.crop.circle.fill"
    case .extensions: return "puzzlepiece.extension.fill"
    case .advanced: return "wrench.and.screwdriver.fill"
    }
  }

  var color: Color {
    switch self {
    case .general: return .gray
    case .appearance: return Color(hex: "#7C5CFF")
    case .playback: return .blue
    case .downloads: return .green
    case .sponsorBlock: return Color(hex: "#00D000")
    case .accounts: return .orange
    case .extensions: return .pink
    case .advanced: return .red
    }
  }
}

struct SettingsView: View {
  @Environment(\.appSettings) private var settings
  @State private var selectedSection: SettingsSection = .general

  var body: some View {
    HStack(spacing: 0) {
      settingsSidebar
      Divider().background(settings.themeColors.separator)
      settingsContent
    }
    .background(settings.themeColors.background)
  }

  private var settingsSidebar: some View {
    ScrollView {
      VStack(spacing: 2) {
        Text("Settings")
          .font(.title2.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.top, 24)
          .padding(.bottom, 12)

        ForEach(SettingsSection.allCases, id: \.self) { section in
          SettingsSidebarItem(section: section, isSelected: selectedSection == section) {
            withAnimation(.spring(duration: 0.25)) { selectedSection = section }
          }
        }
      }
      .padding(.horizontal, 8)
      .padding(.bottom, 20)
    }
    .scrollIndicators(.never)
    .frame(width: 200)
    .background(.ultraThinMaterial)
  }

  private var settingsContent: some View {
    ScrollView {
      VStack(spacing: 0) {
        switch selectedSection {
        case .general: GeneralSettingsView()
        case .appearance: AppearanceSettingsView()
        case .playback: PlaybackSettingsView()
        case .downloads: DownloadSettingsView()
        case .sponsorBlock: SponsorBlockSettingsView()
        case .accounts: AccountSettingsView()
        case .extensions: ExtensionsSettingsView()
        case .advanced: AdvancedSettingsView()
        }
      }
      .padding(.bottom, 40)
    }
    .scrollIndicators(.never)
    .frame(maxWidth: .infinity)
  }
}

struct SettingsSidebarItem: View {
  let section: SettingsSection
  var isSelected: Bool
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      HStack(spacing: 10) {
        ZStack {
          RoundedRectangle(cornerRadius: 7)
            .fill(section.color.gradient)
            .frame(width: 26, height: 26)
          Image(systemName: section.systemImage)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
        }
        Text(section.rawValue)
          .font(.subheadline.weight(isSelected ? .semibold : .regular))
          .foregroundStyle(isSelected ? settings.themeColors.primaryText : settings.themeColors.secondaryText)
        Spacer()
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? settings.themeColors.cardHover : (isHovered ? settings.themeColors.cardHover.opacity(0.5) : Color.clear))
      )
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.18), value: isSelected)
  }
}
