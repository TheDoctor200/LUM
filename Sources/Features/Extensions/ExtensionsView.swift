import SwiftUI

struct ExtensionsView: View {
  @Environment(\.appSettings) private var settings
  @State private var extensions: [AppExtension] = AppExtension.builtIn
  @State private var selectedExtension: AppExtension? = nil

  var body: some View {
    HStack(spacing: 0) {
      extensionList
      if let ext = selectedExtension {
        Divider().background(settings.themeColors.separator)
        ExtensionDetailView(ext: ext, onToggle: { enabled in
          if let i = extensions.firstIndex(where: { $0.id == ext.id }) {
            extensions[i].isEnabled = enabled
          }
        })
      } else {
        emptyDetail
      }
    }
    .background(settings.themeColors.background)
  }

  private var extensionList: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Extensions")
          .font(.title3.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
        Spacer()
        Text("\(extensions.filter { $0.isEnabled }.count) active")
          .font(.caption)
          .foregroundStyle(settings.themeColors.secondaryText)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(settings.themeColors.card)
          .clipShape(Capsule())
      }
      .padding(20)

      ScrollView {
        LazyVStack(spacing: 8) {
          ForEach(extensions) { ext in
            ExtensionRow(ext: ext, isSelected: selectedExtension?.id == ext.id) {
              withAnimation(.spring(duration: 0.25)) { selectedExtension = ext }
            } onToggle: { enabled in
              if let i = extensions.firstIndex(where: { $0.id == ext.id }) {
                extensions[i].isEnabled = enabled
              }
            }
          }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 20)
      }
      .scrollIndicators(.never)
    }
    .frame(width: 280)
    .background(.ultraThinMaterial)
  }

  private var emptyDetail: some View {
    VStack(spacing: 16) {
      Image(systemName: "puzzlepiece.extension")
        .font(.system(size: 48))
        .foregroundStyle(settings.themeColors.tertiaryText)
      Text("Select an Extension")
        .font(.title3.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)
      Text("Choose an extension to view details and configure settings.")
        .font(.subheadline)
        .foregroundStyle(settings.themeColors.secondaryText)
        .multilineTextAlignment(.center)
        .frame(maxWidth: 280)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct ExtensionRow: View {
  let ext: AppExtension
  var isSelected: Bool
  var onSelect: () -> Void
  var onToggle: (Bool) -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: onSelect) {
      HStack(spacing: 12) {
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(settings.themeColors.accent.opacity(0.15))
            .frame(width: 34, height: 34)
          Image(systemName: ext.iconName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(settings.themeColors.accent)
        }
        VStack(alignment: .leading, spacing: 2) {
          Text(ext.name)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(settings.themeColors.primaryText)
          Text("v\(ext.version)")
            .font(.caption2)
            .foregroundStyle(settings.themeColors.tertiaryText)
        }
        Spacer()
        Toggle("", isOn: Binding(get: { ext.isEnabled }, set: { onToggle($0) }))
          .labelsHidden()
          .tint(settings.themeColors.accent)
      }
      .padding(10)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(isSelected ? settings.themeColors.accent.opacity(0.1) : (isHovered ? settings.themeColors.cardHover : settings.themeColors.card))
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .strokeBorder(isSelected ? settings.themeColors.accent.opacity(0.3) : Color.clear, lineWidth: 1.5)
          )
      )
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isSelected)
  }
}

struct ExtensionDetailView: View {
  let ext: AppExtension
  var onToggle: (Bool) -> Void
  @Environment(\.appSettings) private var settings

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        extHeader
        permissionsSection
        aboutSection
      }
      .padding(28)
    }
    .scrollIndicators(.never)
  }

  private var extHeader: some View {
    HStack(spacing: 16) {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(settings.themeColors.accent.gradient)
          .frame(width: 60, height: 60)
        Image(systemName: ext.iconName)
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(.white)
      }
      VStack(alignment: .leading, spacing: 6) {
        Text(ext.name)
          .font(.title2.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
        HStack(spacing: 8) {
          Text("v\(ext.version)")
            .font(.caption.weight(.semibold))
            .foregroundStyle(settings.themeColors.secondaryText)
          Text("·")
            .foregroundStyle(settings.themeColors.tertiaryText)
          Text(ext.author)
            .font(.caption)
            .foregroundStyle(settings.themeColors.secondaryText)
        }
        Toggle(isOn: Binding(get: { ext.isEnabled }, set: { onToggle($0) })) {
          Text(ext.isEnabled ? "Enabled" : "Disabled")
            .font(.caption.weight(.semibold))
            .foregroundStyle(ext.isEnabled ? settings.themeColors.accent : settings.themeColors.secondaryText)
        }
        .toggleStyle(.switch)
        .tint(settings.themeColors.accent)
      }
    }
  }

  private var permissionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Permissions")
        .font(.headline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)

      VStack(spacing: 6) {
        ForEach(ext.permissions, id: \.self) { permission in
          HStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
              .font(.caption)
              .foregroundStyle(.green)
            Text(permission.rawValue)
              .font(.subheadline)
              .foregroundStyle(settings.themeColors.primaryText)
            Spacer()
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 9)
          .background(settings.themeColors.card)
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
    }
  }

  private var aboutSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("About")
        .font(.headline.weight(.semibold))
        .foregroundStyle(settings.themeColors.primaryText)
      Text(ext.description)
        .font(.subheadline)
        .foregroundStyle(settings.themeColors.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
      Text("Bundle ID: \(ext.bundleID)")
        .font(.caption.monospacedDigit())
        .foregroundStyle(settings.themeColors.tertiaryText)
        .textSelection(.enabled)
    }
  }
}

struct ExtensionsSettingsView: View {
  var body: some View {
    ExtensionsView()
  }
}
