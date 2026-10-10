import Foundation
import Observation

@Observable
public final class TransactionRepository {
    private let dataService: DataServiceProtocol
    public var transactions: [Transaction] = []
    public var recentTransactions: [Transaction] {
        Array(transactions.prefix(10))
    }
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func fetchRecent() async throws {
        try await fetchTransactions()
    }
    
    public func fetchTransactions() async throws {
        self.transactions = try await dataService.getTransactions(filter: TransactionFilter())
    }
    
    public func saveTransaction(_ transaction: Transaction) async throws {
        try await dataService.saveTransaction(transaction)
        if let idx = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[idx] = transaction
        } else {
            transactions.insert(transaction, at: 0)
        }
    }
    
    public func deleteTransaction(id: String) async throws {
        try await dataService.deleteTransaction(id: id)
        transactions.removeAll(where: { $0.id == id })
    }
    
    public func totals(for date: Date) -> (income: Decimal, expense: Decimal, net: Decimal) {
        let calendar = Calendar.current
        let monthTxns = transactions.filter {
            calendar.isDate($0.date, equalTo: date, toGranularity: .month)
        }
        let income = monthTxns.filter { $0.isCredit }.reduce(Decimal(0)) { $0 + $1.amount }
        let expense = monthTxns.filter { !$0.isCredit }.reduce(Decimal(0)) { $0 + $1.amount }
        let net = income - expense
        return (income, expense, net)
    }
}
