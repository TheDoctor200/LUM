import Foundation

struct UserAccount: Identifiable, Codable {
  var id: String
  var displayName: String
  var email: String
  var avatarURL: URL?
  var isActive: Bool
  var channelID: String?
  var subscriberCount: Int?
  var accessToken: String?
  var refreshToken: String?
  var tokenExpiry: Date?
}

enum AuthState {
  case signedOut
  case signingIn
  case signedIn(UserAccount)
  case error(String)
}
