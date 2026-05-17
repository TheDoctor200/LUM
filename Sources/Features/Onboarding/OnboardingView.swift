import SwiftUI

struct OnboardingView: View {
  @Binding var isCompleted: Bool
  @Environment(\.appSettings) private var settings
  @State private var currentStep = 0
  @State private var selectedTheme: AppTheme = .dark
  @State private var selectedAccent: AccentColorOption = .purple

  private let totalSteps = 4

  var body: some View {
    ZStack {
      backgroundGradient
      VStack(spacing: 0) {
        stepContent
        navigationBar
      }
    }
    .frame(minWidth: 700, minHeight: 500)
    .ignoresSafeArea()
  }

  private var backgroundGradient: some View {
    ZStack {
      Color(hex: "#0A0A0F")
      RadialGradient(
        colors: [settings.accentColor.color.opacity(0.3), .clear],
        center: .topLeading,
        startRadius: 0,
        endRadius: 500
      )
      RadialGradient(
        colors: [Color(hex: "#1A0A2E").opacity(0.6), .clear],
        center: .bottomTrailing,
        startRadius: 0,
        endRadius: 400
      )
    }
    .ignoresSafeArea()
  }

  @ViewBuilder
  private var stepContent: some View {
    ZStack {
      switch currentStep {
      case 0: welcomeStep
      case 1: themeStep
      case 2: featuresStep
      case 3: signInStep
      default: welcomeStep
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .transition(.asymmetric(
      insertion: .move(edge: .trailing).combined(with: .opacity),
      removal: .move(edge: .leading).combined(with: .opacity)
    ))
  }

  private var welcomeStep: some View {
    VStack(spacing: 28) {
      ZStack {
        Circle()
          .fill(settings.accentColor.color.opacity(0.15))
          .frame(width: 120, height: 120)
          .blur(radius: 20)
        ZStack {
          RoundedRectangle(cornerRadius: 28)
            .fill(settings.accentColor.color.gradient)
            .frame(width: 80, height: 80)
          Image(systemName: "play.tv.fill")
            .font(.system(size: 34, weight: .bold))
            .foregroundStyle(.white)
        }
        .shadow(color: settings.accentColor.color.opacity(0.5), radius: 20)
      }

      VStack(spacing: 12) {
        Text("Welcome to Lumet")
          .font(.system(size: 42, weight: .black))
          .foregroundStyle(.white)
        Text("The premium native macOS YouTube client.\nBeautiful. Fast. Powerful.")
          .font(.title3)
          .foregroundStyle(.white.opacity(0.65))
          .multilineTextAlignment(.center)
      }

      HStack(spacing: 20) {
        FeaturePill(icon: "play.circle.fill", text: "Native Playback")
        FeaturePill(icon: "forward.fill", text: "SponsorBlock")
        FeaturePill(icon: "arrow.down.circle.fill", text: "Downloads")
      }
    }
    .padding(40)
  }

  private var themeStep: some View {
    VStack(spacing: 28) {
      Text("Choose Your Style")
        .font(.system(size: 36, weight: .black))
        .foregroundStyle(.white)
      Text("Pick a theme that feels right to you.")
        .font(.title3)
        .foregroundStyle(.white.opacity(0.65))

      let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(AppTheme.allCases, id: \.self) { theme in
          ThemeCard(theme: theme, isSelected: selectedTheme == theme) {
            selectedTheme = theme
            settings.theme = theme
          }
        }
      }
      .frame(maxWidth: 500)

      HStack(spacing: 12) {
        ForEach(AccentColorOption.allCases, id: \.self) { opt in
          Button {
            selectedAccent = opt
            settings.accentColor = opt
          } label: {
            Circle()
              .fill(opt.color)
              .frame(width: 30, height: 30)
              .overlay(Circle().strokeBorder(.white, lineWidth: selectedAccent == opt ? 2.5 : 0))
          }
          .buttonStyle(.plain)
          .scaleEffect(selectedAccent == opt ? 1.2 : 1.0)
          .animation(.spring(duration: 0.2), value: selectedAccent)
        }
      }
    }
    .padding(40)
  }

  private var featuresStep: some View {
    VStack(spacing: 32) {
      Text("Everything You Need")
        .font(.system(size: 36, weight: .black))
        .foregroundStyle(.white)

      let features: [(String, String, String)] = [
        ("play.tv.fill", "Native Video Player", "Custom AVPlayer with cinematic controls, PiP, and theater mode"),
        ("forward.fill", "SponsorBlock", "Automatically skip sponsors, intros, and outros"),
        ("arrow.down.circle.fill", "Download Manager", "Download videos in MP4, MP3, or Opus with yt-dlp"),
        ("puzzlepiece.extension.fill", "Extension System", "Expand Lumet with plugins and themes")
      ]

      VStack(spacing: 12) {
        ForEach(features, id: \.0) { (icon, title, desc) in
          HStack(spacing: 16) {
            ZStack {
              RoundedRectangle(cornerRadius: 10)
                .fill(settings.accentColor.color.opacity(0.2))
                .frame(width: 44, height: 44)
              Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(settings.accentColor.color)
            }
            VStack(alignment: .leading, spacing: 3) {
              Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
              Text(desc)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
          }
          .padding(14)
          .background(.white.opacity(0.05))
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }
      }
      .frame(maxWidth: 500)
    }
    .padding(40)
  }

  private var signInStep: some View {
    VStack(spacing: 24) {
      Text("Sign In (Optional)")
        .font(.system(size: 36, weight: .black))
        .foregroundStyle(.white)
      Text("Access your subscriptions and watch history.\nYou can skip this and sign in later.")
        .font(.title3)
        .foregroundStyle(.white.opacity(0.65))
        .multilineTextAlignment(.center)

      VStack(spacing: 12) {
        Button {
          isCompleted = true
        } label: {
          HStack(spacing: 10) {
            Image(systemName: "globe")
              .font(.subheadline.weight(.semibold))
            Text("Continue with Google")
              .font(.subheadline.weight(.semibold))
          }
          .foregroundStyle(.white)
          .frame(maxWidth: 300)
          .padding(.vertical, 14)
          .background(settings.accentColor.color)
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)

        Button {
          isCompleted = true
        } label: {
          Text("Skip for now")
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.5))
        }
        .buttonStyle(.plain)
      }
    }
    .padding(40)
  }

  private var navigationBar: some View {
    HStack {
      stepIndicator

      Spacer()

      if currentStep < totalSteps - 1 {
        Button {
          withAnimation(.spring(duration: 0.4, bounce: 0.15)) { currentStep += 1 }
        } label: {
          HStack(spacing: 8) {
            Text("Continue")
              .font(.subheadline.weight(.semibold))
            Image(systemName: "arrow.right")
              .font(.subheadline.weight(.semibold))
          }
          .foregroundStyle(.white)
          .padding(.horizontal, 20)
          .padding(.vertical, 11)
          .background(settings.accentColor.color)
          .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 40)
    .padding(.bottom, 32)
  }

  private var stepIndicator: some View {
    HStack(spacing: 6) {
      ForEach(0..<totalSteps, id: \.self) { i in
        Capsule()
          .fill(i == currentStep ? settings.accentColor.color : .white.opacity(0.2))
          .frame(width: i == currentStep ? 20 : 6, height: 6)
          .animation(.spring(duration: 0.3), value: currentStep)
      }
    }
  }
}

struct FeaturePill: View {
  let icon: String
  let text: String

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: icon)
        .font(.caption.weight(.semibold))
      Text(text)
        .font(.caption.weight(.semibold))
    }
    .foregroundStyle(.white.opacity(0.85))
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background(.white.opacity(0.08))
    .clipShape(Capsule())
  }
}
