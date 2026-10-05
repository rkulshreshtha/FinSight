import Foundation

public struct UserPreferences: Codable, Hashable {
    public var theme: AppTheme
    public var dailySummaryTime: String
    public var inactivityReminderHours: Int
    public var notifications: NotificationPreferences
    
    public init(theme: AppTheme = .system, dailySummaryTime: String = "20:00", inactivityReminderHours: Int = 48, notifications: NotificationPreferences = NotificationPreferences()) {
        self.theme = theme
        self.dailySummaryTime = dailySummaryTime
        self.inactivityReminderHours = inactivityReminderHours
        self.notifications = notifications
    }
}

public struct NotificationPreferences: Codable, Hashable {
    public var dailySummary: Bool
    public var budgetAlerts: Bool
    public var flagReminders: Bool
    public var dueReminders: Bool
    public var exportWarnings: Bool
    public var inactivityAlerts: Bool
    
    public init(dailySummary: Bool = true, budgetAlerts: Bool = true, flagReminders: Bool = true, dueReminders: Bool = true, exportWarnings: Bool = true, inactivityAlerts: Bool = true) {
        self.dailySummary = dailySummary
        self.budgetAlerts = budgetAlerts
        self.flagReminders = flagReminders
        self.dueReminders = dueReminders
        self.exportWarnings = exportWarnings
        self.inactivityAlerts = inactivityAlerts
    }
}

public struct UserProfile: Codable, Hashable, Identifiable {
    public let id: String
    public var email: String
    public var displayName: String?
    public var primaryCurrency: Currency
    public var driveConnected: Bool
    public var driveEmail: String?
    public var driveFolderId: String?
    public var preferences: UserPreferences
    public let createdAt: Date
    public var lastActiveAt: Date
    
    public init(id: String, email: String, displayName: String? = nil, primaryCurrency: Currency = .inr, driveConnected: Bool = false, driveEmail: String? = nil, driveFolderId: String? = nil, preferences: UserPreferences = UserPreferences(), createdAt: Date = Date(), lastActiveAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.primaryCurrency = primaryCurrency
        self.driveConnected = driveConnected
        self.driveEmail = driveEmail
        self.driveFolderId = driveFolderId
        self.preferences = preferences
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
    }
}
