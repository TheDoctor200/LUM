import SwiftUI

@main
struct LumetApp: App {
  @State private var settings = AppSettings.shared
  @State private var router = NavigationRouter.shared
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

  var body: some Scene {
    WindowGroup {
      Group {
        if hasCompletedOnboarding {
          MainContentView()
            .environment(\.appSettings, settings)
            .environment(\.router, router)
            .preferredColorScheme(colorScheme)
            .frame(minWidth: 900, minHeight: 600)
        } else {
          OnboardingView(isCompleted: $hasCompletedOnboarding)
            .environment(\.appSettings, settings)
            .environment(\.router, router)
            .preferredColorScheme(.dark)
            .frame(minWidth: 700, minHeight: 500)
        }
      }
    }
    .windowStyle(.hiddenTitleBar)
    .windowToolbarStyle(.unifiedCompact)
    .defaultSize(width: 1280, height: 800)
    .commands {
      CommandGroup(after: .appSettings) {
        Button("Settings") {
          router.navigate(to: .settings)
        }
        .keyboardShortcut(",", modifiers: .command)
      }

      CommandMenu("Playback") {
        Button("Play / Pause") {
          PlayerService.shared.togglePlayback()
        }
        .keyboardShortcut(" ", modifiers: [])

        Button("Mute") {
          PlayerService.shared.toggleMute()
        }
        .keyboardShortcut("m", modifiers: [])

        Button("Seek Back 10s") {
          PlayerService.shared.seekRelative(seconds: -10)
        }
        .keyboardShortcut("j", modifiers: [])

        Button("Seek Forward 10s") {
          PlayerService.shared.seekRelative(seconds: 10)
        }
        .keyboardShortcut("l", modifiers: [])
      }

      CommandMenu("Navigate") {
        Button("Search") {
          router.navigate(to: .search)
        }
        .keyboardShortcut("f", modifiers: .command)

        Button("Home") {
          router.navigate(to: .home)
        }
        .keyboardShortcut("h", modifiers: [.command, .shift])

        Button("Toggle Sidebar") {
          withAnimation(.spring(duration: 0.35)) {
            router.isSidebarCollapsed.toggle()
          }
        }
        .keyboardShortcut("\\", modifiers: .command)

        Button("Mini Player") {
          router.openMiniPlayer()
        }
        .keyboardShortcut("m", modifiers: [.command, .shift])
      }
    }
  }

  private var colorScheme: ColorScheme? {
    switch settings.theme {
    case .system: return nil
    case .light: return .light
    case .dark, .midnight, .oled, .frosted: return .dark
    }
  }
}
