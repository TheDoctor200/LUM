import SwiftUI

extension EnvironmentValues {
  @Entry var appSettings: AppSettings = AppSettings.shared
  @Entry var router: NavigationRouter = NavigationRouter.shared
}
