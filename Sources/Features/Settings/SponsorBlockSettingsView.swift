import SwiftUI

struct SponsorBlockSettingsView: View {
  @Bindable private var settings = AppSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsPageHeader(title: "SponsorBlock", icon: "forward.fill", color: Color(hex: "#00D000"))

      SettingsSectionHeader(title: "Enable")
      SettingsGroupBox {
        SettingsRow(title: "SponsorBlock", subtitle: "Community-powered skip segments", icon: "forward.circle.fill", iconColor: Color(hex: "#00D000")) {
          Toggle("", isOn: $settings.sponsorBlockEnabled).labelsHidden().tint(settings.themeColors.accent)
        }
      }

      if settings.sponsorBlockEnabled {
        SettingsSectionHeader(title: "Skip Categories")
        SettingsGroupBox {
          VStack(spacing: 0) {
            ForEach(Array(SponsorCategory.allCases.enumerated()), id: \.1) { (index, category) in
              let binding = bindingFor(category)
              VStack(spacing: 0) {
                HStack(spacing: 12) {
                  Circle()
                    .fill(Color(hex: category.color))
                    .frame(width: 10, height: 10)
                  Text(category.displayName)
                    .font(.subheadline)
                    .foregroundStyle(settings.themeColors.primaryText)
                  Spacer()
                  Toggle("", isOn: binding).labelsHidden().tint(Color(hex: category.color))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                if index < SponsorCategory.allCases.count - 1 {
                  Divider().padding(.leading, 38).background(settings.themeColors.separator)
                }
              }
            }
          }
        }

        SettingsSectionHeader(title: "Player Integration")
        SettingsGroupBox {
          SettingsRow(title: "Timeline Markers", subtitle: "Show colored markers on the seek bar", icon: "timeline.selection", iconColor: Color(hex: "#00D000")) {
            Toggle("", isOn: $settings.showTimelineMarkers).labelsHidden().tint(settings.themeColors.accent)
          }
        }

        SettingsSectionHeader(title: "About SponsorBlock")
        VStack(alignment: .leading, spacing: 8) {
          Text("SponsorBlock is an open-source, crowdsourced browser extension and API that lets users submit and skip non-content segments in YouTube videos. Lumet uses the public SponsorBlock API.")
            .font(.caption)
            .foregroundStyle(settings.themeColors.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
      }
    }
  }

  private func bindingFor(_ category: SponsorCategory) -> Binding<Bool> {
    switch category {
    case .sponsor: return $settings.skipSponsors
    case .intro: return $settings.skipIntros
    case .outro: return $settings.skipOutros
    case .selfPromo: return $settings.skipSelfPromo
    case .interaction: return $settings.skipInteractions
    default: return .constant(false)
    }
  }
}
