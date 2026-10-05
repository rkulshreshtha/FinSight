import Foundation
import Observation

public struct UserProfile {
    public let id: String
    public let displayName: String
    public let email: String
    public let avatarURL: URL?
    
    public init(id: String, displayName: String, email: String, avatarURL: URL? = nil) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
    }
}

@Observable
public class SettingsViewModel {
    public var userProfile: UserProfile?
    public var isLoading: Bool = false
    public var isDriveConnected: Bool = false
    public var driveEmail: String?
    public var paymentMethodCount: Int = 0
    public var correctionCount: Int = 0
    public var showSignOutConfirmation: Bool = false
    public var showClearCacheConfirmation: Bool = false
    
    // Toggles
    public var dailySummary: Bool = true
    public var budgetAlerts: Bool = true
    public var flagReminders: Bool = true
    public var dueDateReminders: Bool = true
    public var inactivityAlerts: Bool = false
    public var exportWarnings: Bool = true
    public var aiSuggestions: Bool = true
    
    public var selectedTheme: AppTheme = .system
    
    public init() {
        Task {
            await loadSettings()
        }
    }
    
    @MainActor
    public func loadSettings() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        self.userProfile = UserProfile(id: UUID().uuidString, displayName: "John Doe", email: "john@example.com")
        self.isDriveConnected = true
        self.driveEmail = "john@example.com"
        self.paymentMethodCount = 4
        self.correctionCount = 12
        isLoading = false
    }
    
    @MainActor
    public func signOut() throws {
        userProfile = nil
    }
    
    @MainActor
    public func connectGoogleDrive() async {
        isDriveConnected = true
        driveEmail = userProfile?.email
    }
    
    @MainActor
    public func disconnectGoogleDrive() async {
        isDriveConnected = false
        driveEmail = nil
    }
    
    @MainActor
    public func clearLocalCache() async {
        // Clear cache
    }
    
    public func toggleAISuggestions(_ enabled: Bool) {
        aiSuggestions = enabled
    }
}
