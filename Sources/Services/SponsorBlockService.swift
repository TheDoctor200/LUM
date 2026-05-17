import Foundation

@Observable
final class SponsorBlockService {
  static let shared = SponsorBlockService()

  private let baseURL = "https://sponsor.ajay.app/api"
  private var segmentCache: [String: [SponsorSegment]] = [:]

  private init() {}

  func fetchSegments(videoID: String) async -> [SponsorSegment] {
    if let cached = segmentCache[videoID] { return cached }
    let urlString = "\(baseURL)/skipSegments?videoID=\(videoID)&categories=[\"sponsor\",\"intro\",\"outro\",\"selfpromo\",\"interaction\"]"
    guard let url = URL(string: urlString) else { return mockSegments(videoID: videoID) }
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let decoded = try JSONDecoder().decode([SBSegmentResponse].self, from: data)
      let segments = decoded.map { r in
        SponsorSegment(
          id: r.UUID,
          videoID: videoID,
          startTime: r.segment[0],
          endTime: r.segment[1],
          category: SponsorCategory(rawValue: r.category) ?? .sponsor,
          actionType: SponsorAction(rawValue: r.actionType) ?? .skip,
          votes: r.votes,
          locked: r.locked == 1
        )
      }
      segmentCache[videoID] = segments
      return segments
    } catch {
      return mockSegments(videoID: videoID)
    }
  }

  private func mockSegments(videoID: String) -> [SponsorSegment] {
    [
      SponsorSegment(id: "s1", videoID: videoID, startTime: 15, endTime: 75, category: .sponsor, actionType: .skip, votes: 42, locked: false),
      SponsorSegment(id: "s2", videoID: videoID, startTime: 0, endTime: 12, category: .intro, actionType: .skip, votes: 18, locked: false)
    ]
  }

  func shouldSkip(segment: SponsorSegment, settings: AppSettings) -> Bool {
    guard settings.sponsorBlockEnabled else { return false }
    switch segment.category {
    case .sponsor: return settings.skipSponsors
    case .intro: return settings.skipIntros
    case .outro: return settings.skipOutros
    case .selfPromo: return settings.skipSelfPromo
    case .interaction: return settings.skipInteractions
    default: return false
    }
  }
}

private struct SBSegmentResponse: Codable {
  var UUID: String
  var segment: [Double]
  var category: String
  var actionType: String
  var votes: Int
  var locked: Int
}
