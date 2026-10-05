import Foundation

public struct Transaction: Codable, Hashable, Identifiable {
    public let id: String
    public var type: TransactionType
    public var amount: Decimal
    public var currency: Currency
    public var exchangeRate: Decimal?
    public var title: String
    public var description: String?
    public var date: Date
    public var categories: [String]
    public var paymentSplits: [PaymentSplit]
    public var receiptImageLinks: [String]
    public var localImagePaths: [String]
    public var ocrText: String?
    public var translatedText: String?
    public var note: String?
    public var location: GeoLocation?
    public var items: [LineItem]
    public var isRecurring: Bool
    public var recurringRuleId: String?
    public var recurringFrequency: RecurringFrequency?
    public var isFlagged: Bool
    public var flagNote: String?
    public var isShared: Bool
    public var sharedWith: String?
    public var isExpected: Bool
    public var expectedTransactionId: String?
    public var source: TransactionSource
    public let createdAt: Date
    public var updatedAt: Date
    public var syncStatus: SyncStatus
    
    public var equivalentINR: Decimal {
        if let exchangeRate = exchangeRate {
            return amount * exchangeRate
        }
        return amount
    }
    
    public var isCredit: Bool {
        return type.isCredit
    }
    
    public var signedAmount: Decimal {
        return isCredit ? amount : -amount
    }
    
    public var itemsSubtotal: Decimal {
        return items.reduce(0) { $0 + $1.lineTotal }
    }
    
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency.symbol
        let val = formatter.string(from: amount as NSDecimalNumber) ?? "\(currency.symbol)\(amount)"
        return isCredit ? "+\(val)" : "-\(val)"
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    public init(id: String = UUID().uuidString, type: TransactionType, amount: Decimal, currency: Currency = .inr, exchangeRate: Decimal? = nil, title: String, description: String? = nil, date: Date, categories: [String] = [], paymentSplits: [PaymentSplit] = [], receiptImageLinks: [String] = [], localImagePaths: [String] = [], ocrText: String? = nil, translatedText: String? = nil, note: String? = nil, location: GeoLocation? = nil, items: [LineItem] = [], isRecurring: Bool = false, recurringRuleId: String? = nil, recurringFrequency: RecurringFrequency? = nil, isFlagged: Bool = false, flagNote: String? = nil, isShared: Bool = false, sharedWith: String? = nil, isExpected: Bool = false, expectedTransactionId: String? = nil, source: TransactionSource, createdAt: Date = Date(), updatedAt: Date = Date(), syncStatus: SyncStatus = .pending) {
        self.id = id
        self.type = type
        self.amount = amount
        self.currency = currency
        self.exchangeRate = exchangeRate
        self.title = title
        self.description = description
        self.date = date
        self.categories = categories
        self.paymentSplits = paymentSplits
        self.receiptImageLinks = receiptImageLinks
        self.localImagePaths = localImagePaths
        self.ocrText = ocrText
        self.translatedText = translatedText
        self.note = note
        self.location = location
        self.items = items
        self.isRecurring = isRecurring
        self.recurringRuleId = recurringRuleId
        self.recurringFrequency = recurringFrequency
        self.isFlagged = isFlagged
        self.flagNote = flagNote
        self.isShared = isShared
        self.sharedWith = sharedWith
        self.isExpected = isExpected
        self.expectedTransactionId = expectedTransactionId
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
    
    public static var empty: Transaction {
        Transaction(
            id: UUID().uuidString,
            type: .expense,
            amount: 0,
            currency: .inr,
            title: "",
            date: Date(),
            source: .manual
        )
    }
}
