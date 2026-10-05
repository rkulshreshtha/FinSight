import Foundation
import Observation

@Observable
public final class TransactionRepository {
    private let dataService: DataServiceProtocol
    public var recentTransactions: [Transaction] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func fetchRecent() async throws {
        self.recentTransactions = try await dataService.getTransactions(filter: TransactionFilter())
    }
}
