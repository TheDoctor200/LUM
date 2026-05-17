import SwiftUI

struct DownloadSettingsView: View {
  @Bindable private var settings = AppSettings.shared
  @State private var downloadService = DownloadService.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsPageHeader(title: "Downloads", icon: "arrow.down.circle.fill", color: .green)

      if !downloadService.isYtDlpAvailable {
        ytDlpNotice
      }

      SettingsSectionHeader(title: "Format & Quality")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Default Format", subtitle: "Preferred container format", icon: "film", iconColor: .green) {
            Picker("", selection: $settings.defaultFormat) {
              ForEach(DownloadFormat.allCases, id: \.self) { f in
                Text(f.rawValue).tag(f as DownloadFormat)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 100)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Default Quality", subtitle: "Preferred download resolution", icon: "4k.tv", iconColor: .green) {
            Picker("", selection: $settings.downloadQuality) {
              ForEach(DownloadQuality.allCases, id: \.self) { q in
                Text(q.rawValue).tag(q)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 120)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Concurrent Downloads", subtitle: "Maximum simultaneous downloads", icon: "arrow.down.to.line.alt", iconColor: .green) {
            Picker("", selection: $settings.maxConcurrentDownloads) {
              ForEach([1, 2, 3, 4, 5], id: \.self) { n in Text("\(n)").tag(n) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 60)
          }
        }
      }

      SettingsSectionHeader(title: "Metadata & Options")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Embed Subtitles", subtitle: "Include subtitle tracks in file", icon: "captions.bubble", iconColor: .teal) {
            Toggle("", isOn: $settings.embedSubtitles).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Embed Thumbnail", subtitle: "Attach cover art to file", icon: "photo", iconColor: .teal) {
            Toggle("", isOn: $settings.embedThumbnail).labelsHidden().tint(settings.themeColors.accent)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Embed Metadata", subtitle: "Include title, channel, description", icon: "info.circle", iconColor: .teal) {
            Toggle("", isOn: $settings.embedMetadata).labelsHidden().tint(settings.themeColors.accent)
          }
        }
      }

      SettingsSectionHeader(title: "Storage")
      SettingsGroupBox {
        VStack(spacing: 0) {
          SettingsRow(title: "Download Folder", subtitle: settings.downloadPath.lastPathComponent, icon: "folder.fill", iconColor: .yellow) {
            Button("Choose…") {
              chooseFolder()
            }
            .buttonStyle(.link)
          }
          Divider().padding(.leading, 60).background(settings.themeColors.separator)
          SettingsRow(title: "Storage Used", subtitle: "Across all downloaded files", icon: "internaldrive", iconColor: .yellow) {
            let formatter = ByteCountFormatter()
            let _ = formatter.allowedUnits = [.useGB, .useMB]
            let _ = formatter.countStyle = .file
            Text(formatter.string(fromByteCount: DownloadService.shared.totalStorageUsed))
              .font(.subheadline)
              .foregroundStyle(settings.themeColors.secondaryText)
          }
        }
      }
    }
  }

  private var ytDlpNotice: some View {
    HStack(spacing: 14) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.title3)
        .foregroundStyle(.orange)
      VStack(alignment: .leading, spacing: 4) {
        Text("yt-dlp Not Found")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text("Install yt-dlp via Homebrew: brew install yt-dlp")
          .font(.caption)
          .foregroundStyle(settings.themeColors.secondaryText)
          .textSelection(.enabled)
      }
      Spacer()
    }
    .padding(16)
    .background(Color.orange.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
    )
    .padding(.horizontal, 16)
    .padding(.top, 16)
  }

  private func chooseFolder() {
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.allowsMultipleSelection = false
    panel.prompt = "Choose"
    if panel.runModal() == .OK, let url = panel.url {
      settings.downloadPath = url
    }
  }
}
