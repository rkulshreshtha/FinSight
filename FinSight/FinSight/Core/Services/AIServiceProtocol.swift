import Foundation

public struct ReceiptExtractionResult: Codable {
    public var merchant: String
    public var amount: Decimal
    public var date: Date
    public var items: [LineItem]
    public var rawText: String
    public var detectedLanguage: String
}

public struct SMSParseResult: Codable {
    public var amount: Decimal
    public var merchant: String
    public var date: Date
    public var cardLast4: String
    public var transactionType: String
    public var rawText: String
}

public struct RecurringPattern: Codable, Identifiable {
    public var id = UUID().uuidString
    public var title: String
    public var amount: Decimal
    public var frequency: String
    public var confidence: Double
    public var matchingTransactionIds: [String]
}

public struct ExpectedTransactionMatch: Codable {
    public var expectedId: String
    public var confidence: Double
    public var matchReason: String
}

public protocol AIServiceProtocol {
    func extractReceiptData(from image: Data) async throws -> ReceiptExtractionResult
    func translateText(_ text: String, from: String?, to: String) async throws -> String
    func suggestCategories(for title: String, description: String?, ocrText: String?, corrections: [CategoryCorrection]) async throws -> [String]
    func parseFinancialSMS(_ smsText: String) async throws -> SMSParseResult
    func detectRecurringPatterns(transactions: [Transaction]) async throws -> [RecurringPattern]
    func fetchExchangeRate(from: Currency, to: Currency, date: Date) async throws -> Decimal
    func matchExpectedTransaction(credit: Transaction, expectations: [ExpectedTransaction]) async throws -> ExpectedTransactionMatch?
}
