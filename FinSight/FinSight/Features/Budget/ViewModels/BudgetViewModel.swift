import SwiftUI

public enum BudgetStatus {
    case safe, warning, danger, exceeded
    
    var color: Color {
        switch self {
        case .safe: return Color.App.budgetSafe
        case .warning: return Color.App.budgetWarning
        case .danger: return Color.App.budgetDanger
        case .exceeded: return Color.App.budgetExceeded
        }
    }
}

public struct BudgetProgress: Identifiable {
    public let id: String
    public let budget: Budget
    public let spent: Decimal
    public let progress: Double
    public let status: BudgetStatus
    public let remaining: Decimal
    
    public init(budget: Budget, spent: Decimal) {
        self.id = budget.id
        self.budget = budget
        self.spent = spent
        
        let limit = budget.limitAmount > 0 ? budget.limitAmount : 1
        let dSpent = NSDecimalNumber(decimal: spent).doubleValue
        let dLimit = NSDecimalNumber(decimal: limit).doubleValue
        let rawProgress = dSpent / dLimit
        self.progress = max(0, min(rawProgress, 1.0)) // For progress bar
        
        self.remaining = max(0, budget.limitAmount - spent)
        
        if rawProgress >= 0.95 {
            self.status = .exceeded
        } else if rawProgress >= 0.80 {
            self.status = .danger
        } else if rawProgress >= 0.60 {
            self.status = .warning
        } else {
            self.status = .safe
        }
    }
}

@Observable
@MainActor
public class BudgetViewModel {
    public var budgets: [Budget] = []
    public var transactions: [Transaction] = []
    public var selectedPeriod: BudgetPeriod = .monthly
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var showAddBudget: Bool = false
    public var editingBudget: Budget? = nil
    
    private let dataService: DataServiceProtocol
    private let budgetRepo: BudgetRepository
    
    public init(dataService: DataServiceProtocol = FirestoreService()) {
        self.dataService = dataService
        self.budgetRepo = BudgetRepository(dataService: dataService)
    }
    
    public var overallBudget: BudgetProgress? {
        guard let budget = budgets.first(where: { $0.isOverall && $0.period == selectedPeriod }) else { return nil }
        return computeSpending(for: budget, from: transactions)
    }
    
    public var categoryBudgets: [BudgetProgress] {
        budgets.filter { !$0.isOverall && $0.period == selectedPeriod }
               .map { computeSpending(for: $0, from: transactions) }
    }
    
    public func loadBudgets() async {
        isLoading = true
        do {
            async let fetchedBudgets = dataService.getBudgets()
            async let fetchedTransactions = dataService.getTransactions(filter: TransactionFilter())
            
            self.budgets = try await fetchedBudgets
            self.transactions = try await fetchedTransactions
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func addBudget(_ budget: Budget) {
        budgets.append(budget)
        Task { try? await dataService.saveBudget(budget) }
    }
    
    public func deleteBudget(id: String) {
        budgets.removeAll(where: { $0.id == id })
        Task { try? await dataService.deleteBudget(id: id) }
    }
    
    public func computeSpending(for budget: Budget, from transactions: [Transaction]) -> BudgetProgress {
        let spent = budgetRepo.computeSpent(for: budget, transactions: transactions)
        return BudgetProgress(budget: budget, spent: spent)
    }
}
