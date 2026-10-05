import Foundation

@Observable
public class DashboardViewModel {
    public var currentMonth: Date = Date()
    public var monthlyIncome: Decimal = 0
    public var monthlyExpense: Decimal = 0
    public var netBalance: Decimal = 0
    
    public var recentTransactions: [Transaction] = []
    public var topBudgets: [(budget: Budget, spent: Decimal)] = []
    
    public var flaggedCount: Int = 0
    public var expectedCount: Int = 0
    public var reminderCount: Int = 0
    public var isLoading: Bool = false
    
    // Injected Repositories
    // private let transactionRepo: TransactionRepositoryProtocol
    // private let budgetRepo: BudgetRepositoryProtocol
    
    public init() {
        // Load initial data
    }
    
    public func loadDashboardData() async {
        isLoading = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Populate dummy data
        monthlyIncome = 5000.0
        monthlyExpense = 3200.0
        netBalance = monthlyIncome - monthlyExpense
        
        flaggedCount = 2
        expectedCount = 4
        reminderCount = 1
        
        isLoading = false
    }
    
    public func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
            Task {
                await loadDashboardData()
            }
        }
    }
    
    public var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    public var formattedIncome: String {
        formatCurrency(monthlyIncome)
    }
    
    public var formattedExpense: String {
        formatCurrency(monthlyExpense)
    }
    
    public var formattedNet: String {
        formatCurrency(netBalance)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
