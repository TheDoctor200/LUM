import Foundation

struct Channel: Identifiable, Codable, Hashable {
  var id: String
  var name: String
  var handle: String
  var description: String
  var avatarURL: URL?
  var bannerURL: URL?
  var subscriberCount: Int
  var videoCount: Int
  var isVerified: Bool
  var isSubscribed: Bool

  var formattedSubscribers: String {
    if subscriberCount >= 1_000_000 {
      return String(format: "%.1fM subscribers", Double(subscriberCount) / 1_000_000)
    } else if subscriberCount >= 1_000 {
      return String(format: "%.0fK subscribers", Double(subscriberCount) / 1_000)
    }
    return "\(subscriberCount) subscribers"
  }
}

struct Subscription: Identifiable, Codable {
  var id: String
  var channel: Channel
  var notificationsEnabled: Bool
  var lastWatched: Date?
  var hasNewContent: Bool
}

extension Channel {
  static let mockSubscriptions: [Channel] = [
    Channel(id: "1", name: "WWDC Notes", handle: "@wwdcnotes", description: "", avatarURL: URL(string: "https://picsum.photos/seed/c1/64/64"), subscriberCount: 245000, videoCount: 312, isVerified: true, isSubscribed: true),
    Channel(id: "2", name: "Swift Weekly", handle: "@swiftweekly", description: "", avatarURL: URL(string: "https://picsum.photos/seed/c2/64/64"), subscriberCount: 182000, videoCount: 198, isVerified: false, isSubscribed: true),
    Channel(id: "3", name: "Design Matters", handle: "@designmatters", description: "", avatarURL: URL(string: "https://picsum.photos/seed/c3/64/64"), subscriberCount: 890000, videoCount: 445, isVerified: true, isSubscribed: true),
    Channel(id: "4", name: "Code Craft", handle: "@codecraft", description: "", avatarURL: URL(string: "https://picsum.photos/seed/c4/64/64"), subscriberCount: 1_200_000, videoCount: 623, isVerified: true, isSubscribed: true),
    Channel(id: "5", name: "Tech Pulse", handle: "@techpulse", description: "", avatarURL: URL(string: "https://picsum.photos/seed/c5/64/64"), subscriberCount: 3_400_000, videoCount: 891, isVerified: true, isSubscribed: true)
  ]
}
