import SwiftUI

struct ContentView: View {
    @AppStorage(UserDefaultsKeys.hasSeenOnboarding.rawValue) private var hasSeenOnboarding: Bool = false
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !authViewModel.isAuthenticated {
                LoginView()
                    .transition(.opacity)
            } else {
                AdaptiveNavigationView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: hasSeenOnboarding)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}
