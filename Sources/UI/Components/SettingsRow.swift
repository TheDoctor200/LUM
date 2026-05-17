import SwiftUI

struct SettingsRow<Content: View>: View {
  let title: String
  var subtitle: String? = nil
  var icon: String? = nil
  var iconColor: Color = .accentColor
  @ViewBuilder var content: () -> Content

  @Environment(\.appSettings) private var settings

  var body: some View {
    HStack(spacing: 12) {
      if let icon {
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(iconColor.gradient)
            .frame(width: 32, height: 32)
          Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
        }
      }
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.primaryText)
        if let subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(settings.themeColors.tertiaryText)
        }
      }
      Spacer()
      content()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(settings.themeColors.card)
  }
}

struct SettingsSectionHeader: View {
  let title: String
  @Environment(\.appSettings) private var settings

  var body: some View {
    Text(title.uppercased())
      .font(.caption.weight(.semibold))
      .foregroundStyle(settings.themeColors.tertiaryText)
      .tracking(0.8)
      .padding(.horizontal, 20)
      .padding(.top, 20)
      .padding(.bottom, 4)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct SettingsGroupBox<Content: View>: View {
  @ViewBuilder var content: () -> Content
  @Environment(\.appSettings) private var settings

  var body: some View {
    VStack(spacing: 0) {
      content()
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .strokeBorder(settings.themeColors.separator, lineWidth: 0.5)
        )
    }
    .padding(.horizontal, 16)
  }
}
