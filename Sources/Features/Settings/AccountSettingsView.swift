import SwiftUI

struct AccountSettingsView: View {
  @Environment(\.appSettings) private var settings
  @State private var auth = AuthService.shared
  @State private var email = ""
  @State private var password = ""
  @State private var showAddAccount = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsPageHeader(title: "Accounts", icon: "person.crop.circle.fill", color: .orange)

      if auth.accounts.isEmpty {
        signInPrompt
      } else {
        accountsList
      }

      if showAddAccount {
        addAccountForm
      }
    }
  }

  private var signInPrompt: some View {
    VStack(spacing: 20) {
      Image(systemName: "person.crop.circle.badge.plus")
        .font(.system(size: 52))
        .foregroundStyle(settings.themeColors.tertiaryText)
      VStack(spacing: 8) {
        Text("Sign in to YouTube")
          .font(.title3.weight(.semibold))
          .foregroundStyle(settings.themeColors.primaryText)
        Text("Access your subscriptions, playlists, history, and liked videos.")
          .font(.subheadline)
          .foregroundStyle(settings.themeColors.secondaryText)
          .multilineTextAlignment(.center)
          .frame(maxWidth: 300)
      }
      addAccountForm
    }
    .frame(maxWidth: .infinity)
    .padding(32)
  }

  private var accountsList: some View {
    VStack(alignment: .leading, spacing: 0) {
      SettingsSectionHeader(title: "Signed In Accounts")
      SettingsGroupBox {
        VStack(spacing: 0) {
          ForEach(auth.accounts) { account in
            AccountRow(account: account, isActive: auth.activeAccount?.id == account.id) {
              auth.switchAccount(to: account)
            } onSignOut: {
              auth.signOut(account: account)
            }
            if account.id != auth.accounts.last?.id {
              Divider().padding(.leading, 62).background(settings.themeColors.separator)
            }
          }
        }
      }

      SettingsSectionHeader(title: "Add Account")
      addAccountForm
    }
  }

  private var addAccountForm: some View {
    VStack(spacing: 12) {
      VStack(spacing: 8) {
        TextField("Email or username", text: $email)
          .textFieldStyle(.plain)
          .font(.subheadline)
          .padding(12)
          .background(settings.themeColors.card)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .strokeBorder(settings.themeColors.separator, lineWidth: 1)
          )

        SecureField("Password", text: $password)
          .textFieldStyle(.plain)
          .font(.subheadline)
          .padding(12)
          .background(settings.themeColors.card)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .strokeBorder(settings.themeColors.separator, lineWidth: 1)
          )
      }

      LumetPrimaryButton(title: "Sign In with Google", icon: "globe", isLoading: auth.isSigningIn) {
        Task { await auth.signIn(email: email, password: password) }
      }
      .frame(maxWidth: .infinity)

      Text("Lumet uses OAuth 2.0 to securely authenticate with your Google account. Your credentials are never stored.")
        .font(.caption)
        .foregroundStyle(settings.themeColors.tertiaryText)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
}

struct AccountRow: View {
  let account: UserAccount
  var isActive: Bool
  var onSwitch: () -> Void
  var onSignOut: () -> Void
  @State private var isHovered = false
  @Environment(\.appSettings) private var settings

  var body: some View {
    HStack(spacing: 12) {
      AsyncImage(url: account.avatarURL) { phase in
        if let img = phase.image {
          img.resizable().scaledToFill()
        } else {
          Circle().fill(settings.themeColors.accent.opacity(0.3))
        }
      }
      .frame(width: 38, height: 38)
      .clipShape(Circle())
      .overlay(
        Circle().strokeBorder(isActive ? settings.themeColors.accent : Color.clear, lineWidth: 2)
      )

      VStack(alignment: .leading, spacing: 3) {
        HStack(spacing: 6) {
          Text(account.displayName)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(settings.themeColors.primaryText)
          if isActive {
            Text("Active")
              .font(.caption2.weight(.bold))
              .foregroundStyle(.white)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(settings.themeColors.accent)
              .clipShape(Capsule())
          }
        }
        Text(account.email)
          .font(.caption)
          .foregroundStyle(settings.themeColors.secondaryText)
      }
      Spacer()

      if isHovered {
        HStack(spacing: 8) {
          if !isActive {
            LumetSecondaryButton(title: "Switch") { onSwitch() }
          }
          Button { onSignOut() } label: {
            Text("Sign Out")
              .font(.subheadline.weight(.medium))
              .foregroundStyle(.red)
          }
          .buttonStyle(.plain)
        }
        .transition(.opacity)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .onHover { isHovered = $0 }
    .animation(.spring(duration: 0.2), value: isHovered)
  }
}
