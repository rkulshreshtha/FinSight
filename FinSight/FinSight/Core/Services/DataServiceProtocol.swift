import Foundation


public struct TransactionFilter: Codable {
    public var dateRange: ClosedRange<Date>?
    public var types: [String]?
    public var categories: [String]?
    public var paymentMethodIds: [String]?
    public var cardLast4: String?
    public var bankName: String?
    public var isFlagged: Bool?
    public var isShared: Bool?
    public var amountRange: ClosedRange<Decimal>?
    public var searchText: String?
    public var itemSearchText: String?
    
    public init() {}
}

public protocol DataServiceProtocol {
    func getTransactions(filter: TransactionFilter) async throws -> [Transaction]
    func searchTransactions(query: String) async throws -> [Transaction]
    func getTotals(filter: TransactionFilter) async throws -> (credits: Decimal, debits: Decimal, net: Decimal, count: Int)
    func saveTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(id: String) async throws
    
    func getPaymentMethods() async throws -> [PaymentMethod]
    func savePaymentMethod(_ method: PaymentMethod) async throws
    
    func getBudgets() async throws -> [Budget]
    func saveBudget(_ budget: Budget) async throws
}
