import SwiftUI

struct AdvancedSettingsView: View {
  @Environment(\.appSettings) private var settings

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsPageHeader(title: "Advanced", icon: "wrench.and.screwdriver.fill", color: .red)

      SettingsSectionHeader(title: "Performance")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Thumbnail Cache", subtitle: "Preload and cache video thumbnails", icon: "photo.on.rectangle.angled", iconColor: .blue) {
            Toggle("", isOn: .constant(true)).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Preload Videos", subtitle: "Buffer next video in background", icon: "arrow.down.circle.dotted", iconColor: .blue) {
            Toggle("", isOn: .constant(false)).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Clear Cache", subtitle: "Free up disk space", icon: "trash.circle", iconColor: .red) {
            LumetSecondaryButton(title: "Clear") {}
          }
        }
      }

      SettingsSectionHeader(title: "Network")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Proxy Settings", subtitle: "Configure network proxy", icon: "network", iconColor: .green) {
            LumetSecondaryButton(title: "Configure") {}
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Request Timeout", subtitle: "Seconds before giving up on requests", icon: "timer", iconColor: .green) {
            Picker("", selection: .constant(30)) {
              Text("15s").tag(15)
              Text("30s").tag(30)
              Text("60s").tag(60)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 80)
          }
        }
      }

      SettingsSectionHeader(title: "Developer")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Debug Logging", subtitle: "Write detailed logs to console", icon: "terminal.fill", iconColor: .gray) {
            Toggle("", isOn: .constant(false)).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Export Logs", subtitle: "Save session logs to file", icon: "square.and.arrow.up", iconColor: .gray) {
            LumetSecondaryButton(title: "Export") {}
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Reset All Settings", subtitle: "Restore Lumet to default state", icon: "arrow.counterclockwise", iconColor: .red) {
            LumetSecondaryButton(title: "Reset…") {}
          }
        }
      }
    }
  }
}
