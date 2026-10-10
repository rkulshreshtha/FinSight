import SwiftUI
import Observation

public enum AppTheme: String, Codable, Hashable, CaseIterable, Identifiable {
    case light
    case dark
    case system

    public var id: String { self.rawValue }
    
    public var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

@Observable
public final class ThemeManager {
    public var currentTheme: AppTheme = .system {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: UserDefaultsKeys.appTheme.rawValue)
        }
    }
    
    public init() {
        if let stored = UserDefaults.standard.string(forKey: UserDefaultsKeys.appTheme.rawValue),
           let theme = AppTheme(rawValue: stored) {
            self.currentTheme = theme
        }
    }
    
    public var colorScheme: ColorScheme? {
        switch currentTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
