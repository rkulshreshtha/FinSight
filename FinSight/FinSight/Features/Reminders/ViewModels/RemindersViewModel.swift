import SwiftUI

@Observable
public class RemindersViewModel {
    public var reminders: [Reminder] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var showAddReminder: Bool = false
    
    public init() {}
    
    public var upcomingReminders: [Reminder] {
        reminders.filter { $0.status == .upcoming || $0.status == .dueToday }
    }
    
    public var overdueReminders: [Reminder] {
        reminders.filter { $0.status == .overdue }
    }
    
    public var completedReminders: [Reminder] {
        reminders.filter { $0.status == .completed }
    }
    
    public var overdueCount: Int {
        overdueReminders.count
    }
    
    public var upcomingCount: Int {
        upcomingReminders.count
    }
    
    public func loadReminders() async {
        isLoading = true
        // Mock API call
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    public func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
    
    public func markAsPaid(id: String) async {
        if let idx = reminders.firstIndex(where: { $0.id == id }) {
            reminders[idx].status = .completed
            // In a real app, create a transaction here via Repository
        }
    }
    
    public func snooze(id: String, days: Int) {
        if let idx = reminders.firstIndex(where: { $0.id == id }) {
            reminders[idx].dueDate = Calendar.current.date(byAdding: .day, value: days, to: reminders[idx].dueDate) ?? Date()
            reminders[idx].status = .upcoming
        }
    }
    
    public func delete(id: String) {
        reminders.removeAll(where: { $0.id == id })
    }
}
