import Foundation
import Observation

@Observable
public final class BudgetRepository {
    private let dataService: DataServiceProtocol
    public var budgets: [Budget] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func fetchBudgets() async throws {
        self.budgets = try await dataService.getBudgets()
    }
    
    public func saveBudget(_ budget: Budget) async throws {
        try await dataService.saveBudget(budget)
        if let idx = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[idx] = budget
        } else {
            budgets.append(budget)
        }
    }
    
    public func deleteBudget(id: String) async throws {
        try await dataService.deleteBudget(id: id)
        budgets.removeAll(where: { $0.id == id })
    }
    
    public func computeSpent(for budget: Budget, transactions: [Transaction]) -> Decimal {
        let calendar = Calendar.current
        let now = Date()
        
        let matching = transactions.filter { txn in
            guard !txn.isCredit else { return false }
            
            let inPeriod: Bool
            switch budget.period {
            case .weekly:
                inPeriod = calendar.isDate(txn.date, equalTo: now, toGranularity: .weekOfYear)
            case .monthly:
                inPeriod = calendar.isDate(txn.date, equalTo: now, toGranularity: .month)
            }
            guard inPeriod else { return false }
            
            if budget.isOverall {
                return true
            } else if let cat = budget.category {
                return txn.categories.contains(cat)
            }
            return false
        }
        
        return matching.reduce(Decimal(0)) { $0 + $1.amount }
    }
    
    public func progress(for budget: Budget, spent: Decimal) -> Double {
        guard budget.limitAmount > 0 else { return 0.0 }
        let spentVal = NSDecimalNumber(decimal: spent).doubleValue
        let limitVal = NSDecimalNumber(decimal: budget.limitAmount).doubleValue
        return spentVal / limitVal
    }
    
    public func budgetStatus(progress: Double) -> BudgetStatus {
        if progress >= 1.0 { return .exceeded }
        if progress >= 0.9 { return .danger }
        if progress >= 0.75 { return .warning }
        return .safe
    }
}
