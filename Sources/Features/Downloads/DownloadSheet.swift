import SwiftUI

struct DownloadSheet: View {
  let video: Video
  @Binding var isPresented: Bool
  @State private var selectedFormat: DownloadFormat = .mp4
  @State private var selectedQuality: DownloadQuality = .p1080
  @State private var includeSubtitles = true
  @State private var includeThumbnail = true
  @State private var includeMetadata = true
  @Environment(\.appSettings) private var settings

  var body: some View {
    VStack(spacing: 0) {
      header
      Divider().background(settings.themeColors.separator)
      ScrollView {
        VStack(spacing: 20) {
          videoPreview
          formatSection
          qualitySection
          optionsSection
        }
        .padding(20)
      }
      Divider().background(settings.themeColors.separator)
      footer
    }
    .frame(width: 440)
    .frame(minHeight: 560)
    .background(settings.themeColors.background)
    .clipShape(RoundedRectangle(cornerRadius: 18))
  }

  private var header: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("Download Video")
          .font(.title3.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text("Choose format and quality")
          .font(.caption)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
      Spacer()
      Button { isPresented = false } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .foregroundStyle(settings.themeColors.tertiaryText)
      }
      .buttonStyle(.plain)
    }
    .padding(20)
  }

  private var videoPreview: some View {
    HStack(spacing: 12) {
      AsyncThumbnail(url: video.thumbnailURL, cornerRadius: 8)
        .frame(width: 100)
      VStack(alignment: .leading, spacing: 4) {
        Text(video.title)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
          .lineLimit(2)
        Text(video.channelName)
          .font(.caption)
          .foregroundStyle(settings.themeColors.secondaryText)
        Text(video.formattedDuration)
          .font(.caption)
          .foregroundStyle(settings.themeColors.tertiaryText)
      }
    }
    .padding(14)
    .background(settings.themeColors.card)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private var formatSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Format")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)

      HStack(spacing: 8) {
        ForEach(DownloadFormat.allCases, id: \.self) { format in
          FormatChip(format: format, isSelected: selectedFormat == format) {
            selectedFormat = format
          }
        }
      }
    }
  }

  private var qualitySection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Quality")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)

      let qualities: [DownloadQuality] = selectedFormat == .mp3 || selectedFormat == .opus
        ? [.best]
        : [.best, .p2160, .p1080, .p720, .p480, .p360]

      VStack(spacing: 2) {
        ForEach(qualities, id: \.self) { quality in
          QualityRow(quality: quality, isSelected: selectedQuality == quality) {
            selectedQuality = quality
          }
        }
      }
      .background(settings.themeColors.card)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(settings.themeColors.separator, lineWidth: 0.5)
      )
    }
  }

  private var optionsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Additional Options")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)

      VStack(spacing: 0) {
        if selectedFormat == .mp4 {
          DownloadOptionRow(icon: "captions.bubble", label: "Include Subtitles", isOn: $includeSubtitles)
          Divider().padding(.leading, 48).background(settings.themeColors.separator)
        }
        DownloadOptionRow(icon: "photo", label: "Embed Thumbnail", isOn: $includeThumbnail)
        Divider().padding(.leading, 48).background(settings.themeColors.separator)
        DownloadOptionRow(icon: "info.circle", label: "Embed Metadata", isOn: $includeMetadata)
      }
      .background(settings.themeColors.card)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(settings.themeColors.separator, lineWidth: 0.5)
      )
    }
  }

  private var footer: some View {
    HStack(spacing: 12) {
      LumetSecondaryButton(title: "Cancel") { isPresented = false }
      LumetPrimaryButton(title: "Download", icon: "arrow.down.circle.fill") {
        DownloadService.shared.startDownload(
          video: video,
          format: selectedFormat,
          quality: selectedQuality,
          subtitles: includeSubtitles,
          thumbnail: includeThumbnail,
          metadata: includeMetadata
        )
        isPresented = false
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .trailing)
  }
}

struct FormatChip: View {
  let format: DownloadFormat
  var isSelected: Bool
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        Image(systemName: format.systemImage)
          .font(.system(size: 12, weight: .medium))
        Text(format.rawValue)
          .font(.subheadline.weight(.medium))
      }
      .foregroundStyle(isSelected ? .white : settings.themeColors.primaryText)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? settings.themeColors.accent : settings.themeColors.card)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(isSelected ? settings.themeColors.accent : settings.themeColors.separator, lineWidth: 1)
          )
      )
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isSelected)
  }
}

struct QualityRow: View {
  let quality: DownloadQuality
  var isSelected: Bool
  var action: () -> Void

  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        ZStack {
          Circle()
            .strokeBorder(isSelected ? settings.themeColors.accent : settings.themeColors.separator, lineWidth: 2)
            .frame(width: 18, height: 18)
          if isSelected {
            Circle()
              .fill(settings.themeColors.accent)
              .frame(width: 10, height: 10)
          }
        }
        Text(quality.rawValue)
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.primaryText)
        Spacer()
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 11)
    }
    .buttonStyle(.plain)
    .animation(.spring(duration: 0.15), value: isSelected)
  }
}

struct DownloadOptionRow: View {
  let icon: String
  let label: String
  @Binding var isOn: Bool
  @Environment(\.appSettings) private var settings

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 14))
        .foregroundStyle(settings.themeColors.secondaryText)
        .frame(width: 24)
      Text(label)
        .font(.subheadline)
        .foregroundStyle(settings.themeColors.primaryText)
      Spacer()
      Toggle("", isOn: $isOn)
        .labelsHidden()
        .toggleStyle(.switch)
        .tint(settings.themeColors.accent)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 11)
  }
}
