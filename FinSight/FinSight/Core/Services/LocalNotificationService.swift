import Foundation
import UserNotifications
import Observation

@Observable
public final class LocalNotificationService: NotificationServiceProtocol {
    
    public init() {}
    
    public func requestPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await center.requestAuthorization(options: options)
    }
    
    private func scheduleNotification(id: String, title: String, body: String, dateComponents: DateComponents? = nil, timeInterval: TimeInterval? = nil, repeats: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger: UNNotificationTrigger
        if let components = dateComponents {
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        } else if let interval = timeInterval {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
        } else {
            return
        }
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    public func scheduleDailySummary(at time: String, spent: Decimal, count: Int) {
        let id = "daily_summary"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        let spentStr = formatter.string(from: spent as NSDecimalNumber) ?? "₹\(spent)"
        
        let body = "You spent \(spentStr) today across \(count) transactions"
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        guard let date = df.date(from: time) else { return }
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        scheduleNotification(id: id, title: "Daily Summary", body: body, dateComponents: comps, repeats: true)
    }
    
    public func scheduleBudgetAlert(budget: Budget, currentSpent: Decimal) {
        let pct = (currentSpent / budget.limitAmount) * 100
        let threshold = pct >= 100 ? 100 : 80
        let id = "budget_alert_\(threshold)_\(budget.id)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        let spentStr = formatter.string(from: currentSpent as NSDecimalNumber) ?? "₹\(currentSpent)"
        let limitStr = formatter.string(from: budget.limitAmount as NSDecimalNumber) ?? "₹\(budget.limitAmount)"
        
        let catName = budget.category ?? "Overall"
        let body = "Budget alert: \(catName) spending at \(Int(NSDecimalNumber(decimal: pct).doubleValue))% (\(spentStr)/\(limitStr))"
        
        scheduleNotification(id: id, title: "Budget Alert", body: body, timeInterval: 5)
    }
    
    public func scheduleFlagReminder(count: Int) {
        let id = "flag_reminder"
        var comps = DateComponents()
        comps.hour = 9
        comps.minute = 0
        scheduleNotification(id: id, title: "Action Needed", body: "You have \(count) flagged transactions to review", dateComponents: comps, repeats: true)
    }
    
    public func schedulePaymentReminder(reminder: Reminder) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        let amtStr = formatter.string(from: reminder.amount as NSDecimalNumber) ?? "₹\(reminder.amount)"
        
        for days in [3, 1, 0] {
            let id = "payment_due_\(days)d_\(reminder.id)"
            let date = Calendar.current.date(byAdding: .day, value: -days, to: reminder.dueDate)!
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            let timeStr = days == 0 ? "today" : "in \(days) days"
            let body = "\(reminder.title) \(amtStr) is due \(timeStr)"
            
            scheduleNotification(id: id, title: "Payment Reminder", body: body, dateComponents: comps)
        }
    }
    
    public func scheduleExportWarning(daysUntilPurge: Int) {
        let id = "export_warning"
        scheduleNotification(id: id, title: "Data Deletion Warning", body: "Your oldest transactions will be deleted in \(daysUntilPurge) days. Export now!", timeInterval: 3600)
    }
    
    public func scheduleInactivityReminder(hours: Int) {
        let id = "inactivity"
        scheduleNotification(id: id, title: "We miss you!", body: "You haven't recorded any transactions in \(hours) hours. Check your messages!", timeInterval: TimeInterval(hours * 3600))
    }
    
    public func scheduleExpectedTransactionOverdue(source: String, amount: Decimal) {
        let id = "expected_overdue_\(UUID().uuidString)"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        let amtStr = formatter.string(from: amount as NSDecimalNumber) ?? "₹\(amount)"
        
        scheduleNotification(id: id, title: "Expected Payment Overdue", body: "Expected payment from \(source) for \(amtStr) is overdue", timeInterval: 3600)
    }
    
    public func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    public func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    public func cancelNotificationsWithPrefix(_ prefix: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix(prefix) }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    public func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}
