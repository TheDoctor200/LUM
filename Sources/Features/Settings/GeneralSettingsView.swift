import SwiftUI

struct GeneralSettingsView: View {
  @Bindable private var settings = AppSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsPageHeader(title: "General", icon: "gearshape", color: .gray)

      SettingsSectionHeader(title: "App")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Launch at Login", subtitle: "Start Lumet when you log in", icon: "rectangle.portrait.and.arrow.right") {
            Toggle("", isOn: $settings.launchAtLogin).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Show Menu Bar Icon", subtitle: "Quick access from the menu bar", icon: "menubar.rectangle") {
            Toggle("", isOn: $settings.showMenuBarIcon).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Check for Updates", subtitle: "Automatically check for new versions", icon: "arrow.triangle.2.circlepath") {
            Toggle("", isOn: $settings.checkForUpdates).labelsHidden().tint(settings.themeColors.accent)
          }
        }
      }

      SettingsSectionHeader(title: "Keyboard Shortcuts")
      SettingsGroupBox {
        VStack(spacing: 0) {
          ForEach(keyboardShortcuts, id: \.0) { shortcut in
            SettingsRow(title: shortcut.0, icon: "keyboard") {
              Text(shortcut.1)
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(settings.themeColors.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(settings.themeColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                  RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(settings.themeColors.separator, lineWidth: 0.5)
                )
            }
            if shortcut.0 != keyboardShortcuts.last?.0 {
              Divider().padding(.leading, 60).background(settings.themeColors.separator)
            }
          }
        }
      }

      SettingsSectionHeader(title: "About")
      SettingsGroupBox {
        VStack(spacing: 16) {
          HStack(spacing: 14) {
            ZStack {
              RoundedRectangle(cornerRadius: 14)
                .fill(settings.themeColors.accent.gradient)
                .frame(width: 52, height: 52)
              Image(systemName: "play.tv.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
              Text("Lumet")
                .font(.title3.weight(.bold))
                .foregroundStyle(settings.themeColors.primaryText)
              Text("Version 1.0.0 (Build 1)")
                .font(.subheadline)
                .foregroundStyle(settings.themeColors.secondaryText)
              Text("Premium macOS YouTube Client")
                .font(.caption)
                .foregroundStyle(settings.themeColors.tertiaryText)
            }
            Spacer()
          }
          .padding(16)
          Divider().background(settings.themeColors.separator)
          HStack(spacing: 12) {
            LumetSecondaryButton(title: "Check for Updates", icon: "arrow.triangle.2.circlepath") {}
            LumetSecondaryButton(title: "Release Notes", icon: "doc.text") {}
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 14)
        }
      }
    }
  }

  private var keyboardShortcuts: [(String, String)] {
    [
      ("Play / Pause", "Space"),
      ("Fullscreen", "F"),
      ("Mute", "M"),
      ("Seek Back 10s", "J"),
      ("Seek Forward 10s", "L"),
      ("Search", "⌘F"),
      ("Settings", "⌘,"),
      ("Mini Player", "⌘M"),
      ("New Download", "⌘D")
    ]
  }
}

struct SettingsPageHeader: View {
  let title: String
  let icon: String
  let color: Color
  @Environment(\.appSettings) private var settings

  var body: some View {
    HStack(spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .fill(color.gradient)
          .frame(width: 44, height: 44)
        Image(systemName: icon)
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(.white)
      }
      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(.title2.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
