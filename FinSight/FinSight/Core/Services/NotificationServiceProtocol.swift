import Foundation

public protocol NotificationServiceProtocol {
    func requestPermission() async throws -> Bool
    func scheduleDailySummary(at time: String, spent: Decimal, count: Int)
    func scheduleBudgetAlert(budget: Budget, currentSpent: Decimal)
    func scheduleFlagReminder(count: Int)
    func schedulePaymentReminder(reminder: Reminder)
    func scheduleExportWarning(daysUntilPurge: Int)
    func cancelAll()
    func cancelNotification(id: String)
}
