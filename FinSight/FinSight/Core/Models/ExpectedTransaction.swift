import Foundation

public struct ExpectedTransaction: Codable, Hashable, Identifiable {
    public let id: String
    public var source: String
    public var expectedAmount: Decimal
    public var amountTolerance: Double
    public var expectedBy: Date
    public var notes: String?
    public var status: ExpectedTransactionStatus
    public var matchedTransactionId: String?
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, source: String, expectedAmount: Decimal, amountTolerance: Double = 0.05, expectedBy: Date, notes: String? = nil, status: ExpectedTransactionStatus = .pending, matchedTransactionId: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.source = source
        self.expectedAmount = expectedAmount
        self.amountTolerance = amountTolerance
        self.expectedBy = expectedBy
        self.notes = notes
        self.status = status
        self.matchedTransactionId = matchedTransactionId
        self.createdAt = createdAt
    }
    
    public var isOverdue: Bool {
        return status == .pending && expectedBy < Date() && !Calendar.current.isDateInToday(expectedBy)
    }
    
    public var daysRemaining: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpectedDate = calendar.startOfDay(for: expectedBy)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpectedDate)
        return components.day ?? 0
    }
}
