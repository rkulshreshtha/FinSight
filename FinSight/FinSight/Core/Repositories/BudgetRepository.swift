import Foundation
import Observation

@Observable
public final class BudgetRepository {
    private let dataService: DataServiceProtocol
    public var budgets: [Budget] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func computeSpent(for budget: Budget, transactions: [Transaction]) -> Decimal {
        return 0
    }
    
    public func progress(for budget: Budget, spent: Decimal) -> Double {
        return 0.0
    }
    
    public func budgetStatus(progress: Double) -> BudgetStatus {
        if progress >= 1.0 { return .exceeded }
        if progress >= 0.9 { return .danger }
        if progress >= 0.75 { return .warning }
        return .safe
    }
}
