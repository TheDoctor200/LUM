import SwiftUI

struct PlaybackSettingsView: View {
  @Bindable private var settings = AppSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsPageHeader(title: "Playback", icon: "play.rectangle.fill", color: .blue)

      SettingsSectionHeader(title: "Video")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Default Quality", subtitle: "Preferred resolution for playback", icon: "4k.tv.fill", iconColor: .blue) {
            Picker("", selection: $settings.defaultQuality) {
              ForEach(DownloadQuality.allCases, id: \.self) { q in
                Text(q.rawValue).tag(q)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 120)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Autoplay", subtitle: "Automatically play the next video", icon: "play.circle.fill", iconColor: .blue) {
            Toggle("", isOn: $settings.autoplay).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Hardware Decoding", subtitle: "Use Apple Silicon / GPU for video", icon: "cpu", iconColor: .blue) {
            Toggle("", isOn: $settings.hardwareDecoding).labelsHidden().tint(settings.themeColors.accent)
          }
        }
      }

      SettingsSectionHeader(title: "Audio")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Audio Normalization", subtitle: "Normalize volume across videos", icon: "waveform.path.ecg", iconColor: .purple) {
            Toggle("", isOn: $settings.audioNormalization).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Default Playback Speed", subtitle: "Speed applied on video open", icon: "gauge.with.dots.needle.67percent", iconColor: .purple) {
            Picker("", selection: $settings.playbackSpeed) {
              Text("0.5×").tag(0.5)
              Text("0.75×").tag(0.75)
              Text("Normal").tag(1.0)
              Text("1.25×").tag(1.25)
              Text("1.5×").tag(1.5)
              Text("2×").tag(2.0)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 100)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Remember Speed", subtitle: "Keep playback speed between sessions", icon: "clock.arrow.circlepath", iconColor: .purple) {
            Toggle("", isOn: $settings.rememberSpeed).labelsHidden().tint(settings.themeColors.accent)
          }
        }
      }

      SettingsSectionHeader(title: "Subtitles")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Show Subtitles", subtitle: "Display captions when available", icon: "captions.bubble.fill", iconColor: .orange) {
            Toggle("", isOn: $settings.subtitlesEnabled).labelsHidden().tint(settings.themeColors.accent)
          }
        }
      }
    }
  }
}
