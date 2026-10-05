import Foundation
import SwiftUI

public struct Reminder: Codable, Hashable, Identifiable {
    public let id: String
    public var title: String
    public var amount: Decimal
    public var dueDate: Date
    public var recurrence: RecurringFrequency?
    public var notes: String?
    public var status: ReminderStatus
    public var linkedTransactionId: String?
    public var notifyDaysBefore: [Int]
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, title: String, amount: Decimal, dueDate: Date, recurrence: RecurringFrequency? = nil, notes: String? = nil, status: ReminderStatus = .upcoming, linkedTransactionId: String? = nil, notifyDaysBefore: [Int] = [3, 1, 0], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.recurrence = recurrence
        self.notes = notes
        self.status = status
        self.linkedTransactionId = linkedTransactionId
        self.notifyDaysBefore = notifyDaysBefore
        self.createdAt = createdAt
    }
    
    public var isOverdue: Bool {
        return status == .overdue || (status == .upcoming && dueDate < Date() && !Calendar.current.isDateInToday(dueDate))
    }
    
    public var daysUntilDue: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfDueDate = calendar.startOfDay(for: dueDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfDueDate)
        return components.day ?? 0
    }
    
    public var statusColor: Color {
        switch status {
        case .upcoming: return .blue
        case .dueToday: return .orange
        case .overdue: return .red
        case .completed: return .green
        case .snoozed: return .gray
        }
    }
}
