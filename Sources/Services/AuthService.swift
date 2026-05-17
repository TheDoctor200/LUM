import Foundation

@Observable
final class AuthService {
  static let shared = AuthService()

  var accounts: [UserAccount] = []
  var activeAccount: UserAccount? = nil
  var authState: AuthState = .signedOut
  var isSigningIn: Bool = false

  private init() {}

  func signIn(email: String, password: String) async {
    await MainActor.run { isSigningIn = true; authState = .signingIn }
    try? await Task.sleep(for: .seconds(1.5))
    let account = UserAccount(
      id: UUID().uuidString,
      displayName: "Demo User",
      email: email,
      avatarURL: URL(string: "https://picsum.photos/seed/user/128/128"),
      isActive: true,
      channelID: "UCDemo123",
      subscriberCount: 0
    )
    await MainActor.run {
      accounts.append(account)
      activeAccount = account
      authState = .signedIn(account)
      isSigningIn = false
    }
  }

  func signOut(account: UserAccount) {
    accounts.removeAll { $0.id == account.id }
    if activeAccount?.id == account.id {
      activeAccount = accounts.first
      authState = accounts.isEmpty ? .signedOut : .signedIn(accounts.first!)
    }
  }

  func switchAccount(to account: UserAccount) {
    activeAccount = account
    authState = .signedIn(account)
  }

  var isAuthenticated: Bool { activeAccount != nil }
}
