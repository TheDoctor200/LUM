import SwiftUI

struct SubscriptionsView: View {
  @Environment(\.appSettings) private var settings
  @Environment(\.router) private var router
  @State private var selectedChannel: Channel? = nil

  var body: some View {
    HStack(spacing: 0) {
      channelList
      Divider().background(settings.themeColors.separator)
      if let channel = selectedChannel {
        channelFeed(channel: channel)
      } else {
        allSubscriptionsFeed
      }
    }
    .background(settings.themeColors.background)
  }

  private var channelList: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Subscriptions")
          .font(.title3.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
        Spacer()
      }
      .padding(20)

      Button {
        withAnimation(.spring(duration: 0.25)) { selectedChannel = nil }
      } label: {
        HStack(spacing: 10) {
          ZStack {
            Circle()
              .fill(selectedChannel == nil ? settings.themeColors.accent : settings.themeColors.card)
              .frame(width: 34, height: 34)
            Image(systemName: "rectangle.grid.1x2.fill")
              .font(.caption.weight(.semibold))
              .foregroundStyle(selectedChannel == nil ? .white : settings.themeColors.secondaryText)
          }
          Text("All")
            .font(.subheadline.weight(selectedChannel == nil ? .semibold : .regular))
            .foregroundStyle(selectedChannel == nil ? settings.themeColors.primaryText : settings.themeColors.secondaryText)
          Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(selectedChannel == nil ? settings.themeColors.accent.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 10)
      }
      .buttonStyle(.plain)

      ScrollView {
        VStack(spacing: 4) {
          ForEach(Channel.mockSubscriptions) { channel in
            SubscriptionChannelRow(channel: channel, isSelected: selectedChannel?.id == channel.id) {
              withAnimation(.spring(duration: 0.25)) { selectedChannel = channel }
            }
          }
        }
        .padding(.horizontal, 10)
        .padding(.top, 4)
        .padding(.bottom, 20)
      }
      .scrollIndicators(.never)
    }
    .frame(width: 240)
    .background(.ultraThinMaterial)
  }

  private var allSubscriptionsFeed: some View {
    ScrollView {
      let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
      LazyVGrid(columns: columns, spacing: 14) {
        ForEach(Video.mockFeed.shuffled()) { video in
          VideoCard(video: video, onPlay: { router.openVideo(video) })
        }
      }
      .padding(24)
    }
    .scrollIndicators(.never)
  }

  private func channelFeed(channel: Channel) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        channelHeader(channel)
        let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
        LazyVGrid(columns: columns, spacing: 14) {
          ForEach(Video.mockFeed.filter { $0.channelID == channel.id || true }.prefix(12)) { video in
            VideoCard(video: video, onPlay: { router.openVideo(video) })
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
      }
    }
    .scrollIndicators(.never)
  }

  private func channelHeader(_ channel: Channel) -> some View {
    HStack(spacing: 14) {
      AsyncImage(url: channel.avatarURL) { phase in
        if let img = phase.image { img.resizable().scaledToFill() } else { Circle().fill(settings.themeColors.accent.opacity(0.3)) }
      }
      .frame(width: 56, height: 56)
      .clipShape(Circle())
      .overlay(Circle().strokeBorder(settings.themeColors.accent.opacity(0.4), lineWidth: 2))

      VStack(alignment: .leading, spacing: 4) {
        Text(channel.name)
          .font(.title3.weight(.bold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text(channel.formattedSubscribers)
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
      Spacer()
      LumetSecondaryButton(title: "Subscribed ✓") {}
    }
    .padding(24)
  }
}

struct SubscriptionChannelRow: View {
  let channel: Channel
  var isSelected: Bool
  var action: () -> Void

  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    Button(action: action) {
      HStack(spacing: 10) {
        AsyncImage(url: channel.avatarURL) { phase in
          if let img = phase.image { img.resizable().scaledToFill() } else { Circle().fill(settings.themeColors.accent.opacity(0.2)) }
        }
        .frame(width: 30, height: 30)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(isSelected ? settings.themeColors.accent : Color.clear, lineWidth: 1.5))

        Text(channel.name)
          .font(.subheadline.weight(isSelected ? .semibold : .regular))
          .foregroundStyle(isSelected ? settings.themeColors.primaryText : settings.themeColors.secondaryText)
          .lineLimit(1)
        Spacer()
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? settings.themeColors.accent.opacity(0.1) : (isHovered ? settings.themeColors.cardHover : Color.clear))
      )
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.18), value: isSelected)
  }
}
