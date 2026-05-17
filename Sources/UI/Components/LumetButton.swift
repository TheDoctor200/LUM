import SwiftUI

struct LumetPrimaryButton: View {
  let title: String
  var icon: String? = nil
  var isLoading: Bool = false
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        if isLoading {
          ProgressView().scaleEffect(0.7)
        } else if let icon {
          Image(systemName: icon)
            .font(.subheadline.weight(.semibold))
        }
        Text(title)
          .font(.subheadline.weight(.semibold))
      }
      .foregroundStyle(.white)
      .padding(.horizontal, 18)
      .padding(.vertical, 9)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(settings.themeColors.accent)
          .brightness(isHovered ? 0.08 : 0)
      )
      .scaleEffect(isHovered ? 1.03 : 1.0)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isHovered)
  }
}

struct LumetSecondaryButton: View {
  let title: String
  var icon: String? = nil
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        if let icon {
          Image(systemName: icon)
            .font(.subheadline.weight(.medium))
        }
        Text(title)
          .font(.subheadline.weight(.medium))
      }
      .foregroundStyle(settings.themeColors.primaryText)
      .padding(.horizontal, 16)
      .padding(.vertical, 9)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(settings.themeColors.card)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .strokeBorder(settings.themeColors.separator, lineWidth: 1)
          )
          .brightness(isHovered ? 0.04 : 0)
      )
      .scaleEffect(isHovered ? 1.02 : 1.0)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isHovered)
  }
}

struct LumetIconButton: View {
  let icon: String
  var label: String = ""
  var size: CGFloat = 32
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(settings.themeColors.secondaryText)
        .frame(width: size, height: size)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(isHovered ? settings.themeColors.cardHover : Color.clear)
        )
        .scaleEffect(isHovered ? 1.1 : 1.0)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.18), value: isHovered)
    .help(label)
  }
}
