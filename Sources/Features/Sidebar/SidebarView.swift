import SwiftUI

struct SidebarView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var hoveredItem: SidebarDestination? = nil

  private let topItems: [SidebarDestination] = [.home, .subscriptions, .trending, .search]
  private let libraryItems: [SidebarDestination] = [.library, .watchLater, .playlists, .history, .liked]
  private let bottomItems: [SidebarDestination] = [.downloads, .extensions, .settings]

  var body: some View {
    VStack(spacing: 0) {
      logoSection
        .padding(.top, 20)
        .padding(.horizontal, 14)

      ScrollView {
        VStack(spacing: 0) {
          sectionLabel("Discover")
          ForEach(topItems, id: \.self) { item in
            sidebarItem(item)
          }

          sectionLabel("Library")
          ForEach(libraryItems, id: \.self) { item in
            sidebarItem(item)
          }

          Spacer(minLength: 16)
        }
      }
      .scrollIndicators(.never)

      Divider()
        .background(settings.themeColors.separator)
        .padding(.horizontal, 12)

      VStack(spacing: 2) {
        ForEach(bottomItems, id: \.self) { item in
          sidebarItem(item)
        }
      }
      .padding(.bottom, 12)
      .padding(.top, 6)

      accountSection
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
    }
    .frame(width: 220)
    .background(.ultraThinMaterial)
    .overlay(
      Rectangle()
        .fill(settings.themeColors.separator)
        .frame(width: 0.5),
      alignment: .trailing
    )
  }

  private var logoSection: some View {
    HStack(spacing: 10) {
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(settings.themeColors.accent.gradient)
          .frame(width: 34, height: 34)
        Image(systemName: "play.tv.fill")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(.white)
      }
      VStack(alignment: .leading, spacing: 1) {
        Text("Lumet")
          .font(.title3.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text("YouTube Client")
          .font(.caption2)
          .foregroundStyle(settings.themeColors.tertiaryText)
      }
      Spacer()
    }
    .padding(.bottom, 16)
  }

  private func sectionLabel(_ text: String) -> some View {
    Text(text.uppercased())
      .font(.caption2.weight(.semibold))
      .foregroundStyle(settings.themeColors.tertiaryText)
      .tracking(0.8)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.top, 14)
      .padding(.bottom, 4)
  }

  private func sidebarItem(_ destination: SidebarDestination) -> some View {
    let isSelected = router.selectedDestination == destination
    let isHovered = hoveredItem == destination

    return HStack(spacing: 10) {
      ZStack {
        if isSelected {
          RoundedRectangle(cornerRadius: 7)
            .fill(settings.themeColors.accent.opacity(0.15))
            .frame(width: 28, height: 28)
        }
        Image(systemName: destination.systemImage)
          .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
          .foregroundStyle(isSelected ? settings.themeColors.accent : settings.themeColors.secondaryText)
          .frame(width: 28, height: 28)
      }

      Text(destination.rawValue)
        .font(.subheadline.weight(isSelected ? .semibold : .regular))
        .foregroundStyle(isSelected ? settings.themeColors.primaryText : settings.themeColors.secondaryText)

      Spacer()

      if destination == .downloads {
        let active = DownloadService.shared.activeDownloadsCount
        if active > 0 {
          Text("\(active)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(settings.themeColors.accent)
            .clipShape(Capsule())
        }
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(isSelected ? settings.themeColors.accent.opacity(0.1) : (isHovered ? settings.themeColors.cardHover : Color.clear))
    )
    .padding(.horizontal, 8)
    .contentShape(RoundedRectangle(cornerRadius: 10))
    .onHover { hoveredItem = $0 ? destination : nil }
    .onTapGesture { withAnimation(.spring(duration: 0.25)) { router.navigate(to: destination) } }
    .animation(.spring(duration: 0.2), value: isSelected)
  }

  private var accountSection: some View {
    Group {
      if let account = AuthService.shared.activeAccount {
        HStack(spacing: 10) {
          AsyncImage(url: account.avatarURL) { phase in
            if let img = phase.image {
              img.resizable().scaledToFill()
            } else {
              Circle().fill(settings.themeColors.accent.opacity(0.3))
            }
          }
          .frame(width: 30, height: 30)
          .clipShape(Circle())
          .overlay(Circle().strokeBorder(settings.themeColors.accent.opacity(0.4), lineWidth: 1.5))

          VStack(alignment: .leading, spacing: 1) {
            Text(account.displayName)
              .font(.caption.weight(.semibold))
              .foregroundStyle(settings.themeColors.primaryText)
              .lineLimit(1)
            Text(account.email)
              .font(.caption2)
              .foregroundStyle(settings.themeColors.tertiaryText)
              .lineLimit(1)
          }
          Spacer()
        }
        .padding(10)
        .background(settings.themeColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
      } else {
        Button {
          router.navigate(to: .settings)
        } label: {
          HStack(spacing: 8) {
            Image(systemName: "person.crop.circle")
              .font(.system(size: 16))
              .foregroundStyle(settings.themeColors.secondaryText)
            Text("Sign In")
              .font(.subheadline.weight(.medium))
              .foregroundStyle(settings.themeColors.secondaryText)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(settings.themeColors.card)
          .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
      }
    }
  }
}
