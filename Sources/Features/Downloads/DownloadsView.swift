import SwiftUI

struct DownloadsView: View {
  @State private var downloadService = DownloadService.shared
  @Environment(\.appSettings) private var settings
  @State private var selectedFilter: DownloadFilter = .all
  @State private var sortOrder: DownloadSortOrder = .date

  var filteredDownloads: [DownloadItem] {
    let items: [DownloadItem]
    switch selectedFilter {
    case .all: items = downloadService.downloads
    case .active: items = downloadService.downloads.filter { $0.status == .downloading || $0.status == .queued }
    case .completed: items = downloadService.downloads.filter { $0.status == .completed }
    case .failed: items = downloadService.downloads.filter { $0.status == .failed }
    }
    return items.sorted { a, b in
      switch sortOrder {
      case .date: return a.startedAt > b.startedAt
      case .title: return a.video.title < b.video.title
      case .size: return (a.fileSize ?? 0) > (b.fileSize ?? 0)
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        headerSection
        statsRow
        filterAndSort
        if filteredDownloads.isEmpty {
          emptyState
        } else {
          downloadsList
        }
      }
    }
    .scrollIndicators(.never)
    .background(settings.themeColors.background)
  }

  private var headerSection: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Downloads")
          .font(.largeTitle.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text("\(downloadService.downloads.count) items · \(formattedStorage)")
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
      Spacer()
      if downloadService.activeDownloadsCount > 0 {
        HStack(spacing: 8) {
          ProgressView()
            .scaleEffect(0.7)
            .tint(settings.themeColors.accent)
          Text("\(downloadService.activeDownloadsCount) active")
            .font(.caption.weight(.semibold))
            .foregroundStyle(settings.themeColors.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(settings.themeColors.accent.opacity(0.1))
        .clipShape(Capsule())
      }
    }
    .padding(24)
  }

  private var statsRow: some View {
    HStack(spacing: 12) {
      StatCard(title: "Total", value: "\(downloadService.downloads.count)", icon: "arrow.down.circle", color: settings.themeColors.accent)
      StatCard(title: "Completed", value: "\(downloadService.downloads.filter { $0.status == .completed }.count)", icon: "checkmark.circle.fill", color: .green)
      StatCard(title: "Active", value: "\(downloadService.activeDownloadsCount)", icon: "arrow.down.circle.fill", color: .orange)
      StatCard(title: "Storage", value: formattedStorage, icon: "internaldrive", color: .blue)
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 16)
  }

  private var filterAndSort: some View {
    HStack(spacing: 16) {
      ScrollView(.horizontal) {
        HStack(spacing: 8) {
          ForEach(DownloadFilter.allCases, id: \.self) { filter in
            CategoryChip(title: filter.rawValue, isSelected: selectedFilter == filter) {
              withAnimation(.spring(duration: 0.25)) { selectedFilter = filter }
            }
          }
        }
        .padding(.leading, 24)
        .padding(.trailing, 4)
      }
      .scrollIndicators(.never)

      Spacer()

      Menu {
        ForEach(DownloadSortOrder.allCases, id: \.self) { order in
          Button(order.rawValue) { sortOrder = order }
        }
      } label: {
        HStack(spacing: 5) {
          Image(systemName: "arrow.up.arrow.down")
            .font(.caption)
          Text(sortOrder.rawValue)
            .font(.caption.weight(.medium))
        }
        .foregroundStyle(settings.themeColors.secondaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(settings.themeColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      .menuStyle(.borderlessButton)
      .padding(.trailing, 24)
    }
    .padding(.bottom, 12)
  }

  private var downloadsList: some View {
    LazyVStack(spacing: 10) {
      ForEach(filteredDownloads) { item in
        DownloadRowView(item: item)
          .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
    .animation(.spring(duration: 0.3), value: filteredDownloads.map { $0.id })
  }

  private var emptyState: some View {
    VStack(spacing: 20) {
      Image(systemName: "arrow.down.circle")
        .font(.system(size: 52))
        .foregroundStyle(settings.themeColors.tertiaryText)
      VStack(spacing: 6) {
        Text("No Downloads")
          .font(.title3.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text("Videos you download will appear here.")
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 80)
  }

  private var formattedStorage: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useGB, .useMB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: downloadService.totalStorageUsed)
  }
}

struct DownloadRowView: View {
  let item: DownloadItem
  @State private var isHovered = false
  @Environment(\.appSettings) private var settings
  @State private var downloadService = DownloadService.shared

  var body: some View {
    HStack(spacing: 14) {
      AsyncThumbnail(url: item.video.thumbnailURL, cornerRadius: 8)
        .frame(width: 80, height: 45)

      VStack(alignment: .leading, spacing: 4) {
        Text(item.video.title)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
          .lineLimit(1)
        HStack(spacing: 8) {
          Text(item.format.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundStyle(settings.themeColors.accent)
          Text(item.quality.rawValue)
            .font(.caption)
            .foregroundStyle(settings.themeColors.secondaryText)
          if item.fileSize != nil {
            Text(item.formattedFileSize)
              .font(.caption)
              .foregroundStyle(settings.themeColors.tertiaryText)
          }
        }
        if item.status == .downloading {
          VStack(alignment: .leading, spacing: 3) {
            GeometryReader { geo in
              ZStack(alignment: .leading) {
                Capsule().fill(settings.themeColors.separator).frame(height: 4)
                Capsule()
                  .fill(settings.themeColors.accent)
                  .frame(width: geo.size.width * item.progress, height: 4)
                  .animation(.easeInOut(duration: 0.3), value: item.progress)
              }
            }
            .frame(height: 4)
            Text("\(Int(item.progress * 100))%")
              .font(.caption2.monospacedDigit())
              .foregroundStyle(settings.themeColors.tertiaryText)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      statusBadge

      if isHovered {
        actionButtons
          .transition(.opacity)
      }
    }
    .padding(14)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(settings.themeColors.card)
        .shadow(color: .black.opacity(isHovered ? 0.15 : 0.06), radius: isHovered ? 12 : 4)
    )
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isHovered)
  }

  private var statusBadge: some View {
    HStack(spacing: 5) {
      Image(systemName: item.status.systemImage)
        .font(.caption)
      Text(item.status.rawValue)
        .font(.caption.weight(.semibold))
    }
    .foregroundStyle(statusColor)
    .padding(.horizontal, 9)
    .padding(.vertical, 4)
    .background(statusColor.opacity(0.12))
    .clipShape(Capsule())
  }

  private var statusColor: Color {
    switch item.status {
    case .completed: return .green
    case .downloading: return settings.themeColors.accent
    case .failed: return .red
    case .paused: return .orange
    case .queued: return .blue
    case .processing: return .yellow
    case .cancelled: return .gray
    }
  }

  private var actionButtons: some View {
    HStack(spacing: 6) {
      switch item.status {
      case .downloading:
        LumetIconButton(icon: "pause.fill", label: "Pause") { downloadService.pauseDownload(id: item.id) }
        LumetIconButton(icon: "xmark", label: "Cancel") { downloadService.cancelDownload(id: item.id) }
      case .paused:
        LumetIconButton(icon: "play.fill", label: "Resume") { downloadService.resumeDownload(id: item.id) }
        LumetIconButton(icon: "xmark", label: "Cancel") { downloadService.cancelDownload(id: item.id) }
      case .failed:
        LumetIconButton(icon: "arrow.clockwise", label: "Retry") { downloadService.retryDownload(id: item.id) }
        LumetIconButton(icon: "trash", label: "Remove") { downloadService.cancelDownload(id: item.id) }
      case .completed:
        LumetIconButton(icon: "folder", label: "Show in Finder") {}
        LumetIconButton(icon: "trash", label: "Delete") { downloadService.cancelDownload(id: item.id) }
      default:
        LumetIconButton(icon: "xmark", label: "Remove") { downloadService.cancelDownload(id: item.id) }
      }
    }
  }
}

struct StatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  @Environment(\.appSettings) private var settings

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(color)
        Spacer()
      }
      Text(value)
        .font(.title2.weight(.bold))
        .foregroundStyle(settings.themeColors.primaryText)
      Text(title)
        .font(.caption)
        .foregroundStyle(settings.themeColors.secondaryText)
    }
    .padding(14)
    .frame(maxWidth: .infinity)
    .background(settings.themeColors.card)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

enum DownloadFilter: String, CaseIterable {
  case all = "All"
  case active = "Active"
  case completed = "Completed"
  case failed = "Failed"
}

enum DownloadSortOrder: String, CaseIterable {
  case date = "Date"
  case title = "Title"
  case size = "Size"
}
