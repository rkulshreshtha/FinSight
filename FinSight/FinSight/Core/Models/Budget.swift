import Foundation

public struct Budget: Codable, Hashable, Identifiable {
    public let id: String
    public var period: BudgetPeriod
    public var category: String?
    public var limitAmount: Decimal
    public var isOverall: Bool
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, period: BudgetPeriod, category: String? = nil, limitAmount: Decimal, isOverall: Bool, createdAt: Date = Date()) {
        self.id = id
        self.period = period
        self.category = category
        self.limitAmount = limitAmount
        self.isOverall = isOverall
        self.createdAt = createdAt
    }
}
