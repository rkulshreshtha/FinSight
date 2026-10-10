import Foundation
import FirebaseFirestore
import FirebaseAuth
import Observation

public enum DataError: LocalizedError {
    case documentNotFound
    case decodingError(String)
    case encodingError(String)
    case permissionDenied
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found."
        case .decodingError(let msg):
            return "Failed to decode data: \(msg)"
        case .encodingError(let msg):
            return "Failed to encode data: \(msg)"
        case .permissionDenied:
            return "Permission denied."
        case .unknown(let msg):
            return msg
        }
    }
}

@Observable
public final class FirestoreService: DataServiceProtocol {
    private let db = Firestore.firestore()
    
    public init() {}
    
    private var currentUserId: String {
        if let uid = Auth.auth().currentUser?.uid, !uid.isEmpty {
            return uid
        }
        if let cachedId = UserDefaults.standard.string(forKey: "FinSight_LocalUserId") {
            return cachedId
        }
        let newId = "user_" + UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12)
        UserDefaults.standard.set(newId, forKey: "FinSight_LocalUserId")
        return newId
    }
    
    private var transactionsCollection: CollectionReference {
        db.collection("users").document(currentUserId).collection("transactions")
    }
    
    private var paymentMethodsCollection: CollectionReference {
        db.collection("users").document(currentUserId).collection("paymentMethods")
    }
    
    private var budgetsCollection: CollectionReference {
        db.collection("users").document(currentUserId).collection("budgets")
    }
    
    // MARK: - Transactions
    
    public func getTransactions(filter: TransactionFilter) async throws -> [Transaction] {
        let snapshot = try await transactionsCollection.order(by: "date", descending: true).getDocuments()
        
        let allTransactions = snapshot.documents.compactMap { doc -> Transaction? in
            do {
                return try Firestore.Decoder().decode(Transaction.self, from: doc.data())
            } catch {
                print("Failed to decode transaction \(doc.documentID): \(error)")
                return nil
            }
        }
        
        var filtered = allTransactions
        
        if let range = filter.dateRange {
            filtered = filtered.filter { range.contains($0.date) }
        }
        if let types = filter.types, !types.isEmpty {
            filtered = filtered.filter { types.contains($0.type.rawValue) }
        }
        if let categories = filter.categories, !categories.isEmpty {
            filtered = filtered.filter { !Set($0.categories).isDisjoint(with: Set(categories)) }
        }
        if let paymentMethodIds = filter.paymentMethodIds, !paymentMethodIds.isEmpty {
            filtered = filtered.filter { txn in
                txn.paymentSplits.contains { paymentMethodIds.contains($0.methodId) }
            }
        }
        if let cardLast4 = filter.cardLast4, !cardLast4.isEmpty {
            // Check payment methods or splits matching cardLast4
        }
        if let isFlagged = filter.isFlagged {
            filtered = filtered.filter { $0.isFlagged == isFlagged }
        }
        if let isShared = filter.isShared {
            filtered = filtered.filter { $0.isShared == isShared }
        }
        if let amountRange = filter.amountRange {
            filtered = filtered.filter { amountRange.contains($0.amount) }
        }
        if let search = filter.searchText, !search.isEmpty {
            let lower = search.lowercased()
            filtered = filtered.filter { txn in
                txn.title.lowercased().contains(lower) ||
                (txn.description?.lowercased().contains(lower) ?? false) ||
                (txn.note?.lowercased().contains(lower) ?? false) ||
                (txn.ocrText?.lowercased().contains(lower) ?? false)
            }
        }
        if let itemSearch = filter.itemSearchText, !itemSearch.isEmpty {
            let lower = itemSearch.lowercased()
            filtered = filtered.filter { txn in
                txn.items.contains { $0.name.lowercased().contains(lower) }
            }
        }
        
        return filtered
    }
    
    public func searchTransactions(query: String) async throws -> [Transaction] {
        var filter = TransactionFilter()
        filter.searchText = query
        return try await getTransactions(filter: filter)
    }
    
    public func getTotals(filter: TransactionFilter) async throws -> (credits: Decimal, debits: Decimal, net: Decimal, count: Int) {
        let txns = try await getTransactions(filter: filter)
        let credits = txns.filter { $0.isCredit }.reduce(Decimal(0)) { $0 + $1.amount }
        let debits = txns.filter { !$0.isCredit }.reduce(Decimal(0)) { $0 + $1.amount }
        let net = credits - debits
        return (credits, debits, net, txns.count)
    }
    
    public func saveTransaction(_ transaction: Transaction) async throws {
        do {
            let data = try Firestore.Encoder().encode(transaction)
            try await transactionsCollection.document(transaction.id).setData(data, merge: true)
        } catch {
            throw DataError.encodingError(error.localizedDescription)
        }
    }
    
    public func deleteTransaction(id: String) async throws {
        try await transactionsCollection.document(id).delete()
    }
    
    // MARK: - Payment Methods
    
    public func getPaymentMethods() async throws -> [PaymentMethod] {
        let snapshot = try await paymentMethodsCollection.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? Firestore.Decoder().decode(PaymentMethod.self, from: doc.data())
        }
    }
    
    public func savePaymentMethod(_ method: PaymentMethod) async throws {
        do {
            let data = try Firestore.Encoder().encode(method)
            try await paymentMethodsCollection.document(method.id).setData(data, merge: true)
        } catch {
            throw DataError.encodingError(error.localizedDescription)
        }
    }
    
    public func deletePaymentMethod(id: String) async throws {
        try await paymentMethodsCollection.document(id).delete()
    }
    
    // MARK: - Budgets
    
    public func getBudgets() async throws -> [Budget] {
        let snapshot = try await budgetsCollection.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? Firestore.Decoder().decode(Budget.self, from: doc.data())
        }
    }
    
    public func saveBudget(_ budget: Budget) async throws {
        do {
            let data = try Firestore.Encoder().encode(budget)
            try await budgetsCollection.document(budget.id).setData(data, merge: true)
        } catch {
            throw DataError.encodingError(error.localizedDescription)
        }
    }
    
    public func deleteBudget(id: String) async throws {
        try await budgetsCollection.document(id).delete()
    }
}
