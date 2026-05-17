import SwiftUI

struct AppearanceSettingsView: View {
  @Bindable private var settings = AppSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsPageHeader(title: "Appearance", icon: "paintbrush.fill", color: Color(hex: "#7C5CFF"))

      SettingsSectionHeader(title: "Theme")
      SettingsGroupBox {
        VStack(spacing: 0) {
          themeGrid
        }
        .padding(16)
      }

      SettingsSectionHeader(title: "Accent Color")
      SettingsGroupBox {
        accentColorPicker
          .padding(16)
      }

      SettingsSectionHeader(title: "UI Density")
      SettingsGroupBox {
        densityPicker
      }

      SettingsSectionHeader(title: "Animations")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Reduced Motion", subtitle: "Simplify animations for accessibility", icon: "wind") {
            Toggle("", isOn: $settings.reducedMotion).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Smooth Scrolling", subtitle: "Fluid inertial scrolling", icon: "scroll") {
            Toggle("", isOn: $settings.smoothScrolling).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Dynamic Blur", subtitle: "Blur effects behind overlays", icon: "rays") {
            Toggle("", isOn: $settings.dynamicBlur).labelsHidden().tint(settings.themeColors.accent)
          }
        }
      }
    }
  }

  private var themeGrid: some View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    return LazyVGrid(columns: columns, spacing: 10) {
      ForEach(AppTheme.allCases, id: \.self) { theme in
        ThemeCard(theme: theme, isSelected: settings.theme == theme) {
          withAnimation(.spring(duration: 0.3)) { settings.theme = theme }
        }
      }
    }
  }

  private var accentColorPicker: some View {
    HStack(spacing: 12) {
      ForEach(AccentColorOption.allCases, id: \.self) { option in
        Button {
          withAnimation(.spring(duration: 0.25)) { settings.accentColor = option }
        } label: {
          ZStack {
            Circle()
              .fill(option.color)
              .frame(width: 30, height: 30)
            if settings.accentColor == option {
              Circle()
                .strokeBorder(.white, lineWidth: 2.5)
                .frame(width: 30, height: 30)
              Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
            }
          }
        }
        .buttonStyle(.plain)
        .help(option.rawValue)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var densityPicker: some View {
    VStack(spacing: 0) {
      ForEach(UIDensity.allCases, id: \.self) { density in
        let isLast = density == UIDensity.allCases.last
        Button {
          withAnimation(.spring(duration: 0.25)) { settings.density = density }
        } label: {
          HStack(spacing: 12) {
            ZStack {
              Circle()
                .strokeBorder(settings.density == density ? settings.themeColors.accent : settings.themeColors.separator, lineWidth: 2)
                .frame(width: 18, height: 18)
              if settings.density == density {
                Circle().fill(settings.themeColors.accent).frame(width: 10, height: 10)
              }
            }
            VStack(alignment: .leading, spacing: 2) {
              Text(density.rawValue)
                .font(.subheadline)
                .foregroundStyle(settings.themeColors.primaryText)
              Text("Card spacing: \(Int(density.cardSpacing))pt · Padding: \(Int(density.cardPadding))pt")
                .font(.caption)
                .foregroundStyle(settings.themeColors.tertiaryText)
            }
            Spacer()
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
        if !isLast {
          Divider().padding(.leading, 46).background(settings.themeColors.separator)
        }
      }
    }
    .background(settings.themeColors.card)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.horizontal, 16)
  }
}

struct ThemeCard: View {
  let theme: AppTheme
  var isSelected: Bool
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  private var previewBg: Color {
    switch theme {
    case .system: return Color(nsColor: .windowBackgroundColor)
    case .light: return Color(hex: "#F5F5F7")
    case .dark: return Color(hex: "#111111")
    case .midnight: return Color(hex: "#0A0A0F")
    case .oled: return .black
    case .frosted: return Color(hex: "#1A1A2E")
    }
  }

  private var previewAccent: Color { settings.themeColors.accent }

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        ZStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(previewBg)
            .frame(height: 60)
            .overlay(
              VStack(spacing: 4) {
                HStack(spacing: 4) {
                  RoundedRectangle(cornerRadius: 3).fill(previewAccent).frame(width: 20, height: 6)
                  RoundedRectangle(cornerRadius: 3).fill(.white.opacity(0.3)).frame(width: 30, height: 6)
                }
                HStack(spacing: 4) {
                  RoundedRectangle(cornerRadius: 3).fill(.white.opacity(0.15)).frame(width: 40, height: 5)
                  RoundedRectangle(cornerRadius: 3).fill(.white.opacity(0.1)).frame(width: 20, height: 5)
                }
              }
            )
          if isSelected {
            RoundedRectangle(cornerRadius: 10)
              .strokeBorder(previewAccent, lineWidth: 2.5)
          }
        }
        .shadow(color: .black.opacity(0.2), radius: 4)

        HStack(spacing: 5) {
          if isSelected {
            Image(systemName: "checkmark.circle.fill")
              .font(.caption)
              .foregroundStyle(settings.themeColors.accent)
          }
          Text(theme.rawValue)
            .font(.caption.weight(isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? settings.themeColors.primaryText : settings.themeColors.secondaryText)
        }
      }
    }
    .buttonStyle(.plain)
    .scaleEffect(isHovered ? 1.04 : 1.0)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isSelected)
  }
}
