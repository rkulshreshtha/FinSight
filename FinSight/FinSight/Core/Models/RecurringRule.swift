import Foundation

public struct RecurringRule: Codable, Hashable, Identifiable {
    public let id: String
    public var templateTitle: String
    public var templateType: TransactionType
    public var templateAmount: Decimal
    public var templateCurrency: Currency
    public var templateCategories: [String]
    public var templatePaymentMethodId: String?
    public var frequency: RecurringFrequency
    public var startDate: Date
    public var nextOccurrence: Date
    public var isActive: Bool
    public var isAIDetected: Bool
    public var confidenceScore: Double?
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, templateTitle: String, templateType: TransactionType, templateAmount: Decimal, templateCurrency: Currency = .inr, templateCategories: [String] = [], templatePaymentMethodId: String? = nil, frequency: RecurringFrequency, startDate: Date, nextOccurrence: Date, isActive: Bool = true, isAIDetected: Bool = false, confidenceScore: Double? = nil, createdAt: Date = Date()) {
        self.id = id
        self.templateTitle = templateTitle
        self.templateType = templateType
        self.templateAmount = templateAmount
        self.templateCurrency = templateCurrency
        self.templateCategories = templateCategories
        self.templatePaymentMethodId = templatePaymentMethodId
        self.frequency = frequency
        self.startDate = startDate
        self.nextOccurrence = nextOccurrence
        self.isActive = isActive
        self.isAIDetected = isAIDetected
        self.confidenceScore = confidenceScore
        self.createdAt = createdAt
    }
}
