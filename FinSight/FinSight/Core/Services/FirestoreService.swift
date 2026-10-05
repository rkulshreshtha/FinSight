import Foundation
import FirebaseFirestore
import Observation

public enum DataError: LocalizedError {
    case documentNotFound
    case decodingError
    case unknown
}

@Observable
public final class FirestoreService: DataServiceProtocol {
    public init() {}
    
    public func getTransactions(filter: TransactionFilter) async throws -> [Transaction] {
        return []
    }
    
    public func searchTransactions(query: String) async throws -> [Transaction] {
        return []
    }
    
    public func getTotals(filter: TransactionFilter) async throws -> (credits: Decimal, debits: Decimal, net: Decimal, count: Int) {
        return (0, 0, 0, 0)
    }
    
    public func saveTransaction(_ transaction: Transaction) async throws {}
    public func deleteTransaction(id: String) async throws {}
    
    public func getPaymentMethods() async throws -> [PaymentMethod] { return [] }
    public func savePaymentMethod(_ method: PaymentMethod) async throws {}
    
    public func getBudgets() async throws -> [Budget] { return [] }
    public func saveBudget(_ budget: Budget) async throws {}
}
