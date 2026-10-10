import Foundation
import Observation

@Observable
@MainActor
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
    
    private let dataService: DataServiceProtocol
    private let budgetRepo: BudgetRepository
    
    public init(dataService: DataServiceProtocol = FirestoreService()) {
        self.dataService = dataService
        self.budgetRepo = BudgetRepository(dataService: dataService)
    }
    
    public func loadDashboardData() async {
        isLoading = true
        do {
            let allTransactions = try await dataService.getTransactions(filter: TransactionFilter())
            
            // Calculate totals for current selected month
            let calendar = Calendar.current
            let monthTransactions = allTransactions.filter {
                calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month)
            }
            
            self.monthlyIncome = monthTransactions
                .filter { $0.isCredit }
                .reduce(Decimal(0)) { $0 + $1.amount }
                
            self.monthlyExpense = monthTransactions
                .filter { !$0.isCredit }
                .reduce(Decimal(0)) { $0 + $1.amount }
                
            self.netBalance = monthlyIncome - monthlyExpense
            
            // Top recent transactions
            self.recentTransactions = Array(allTransactions.prefix(5))
            
            // Flagged count
            self.flaggedCount = allTransactions.filter { $0.isFlagged }.count
            
            // Top budgets calculation
            let budgets = try await dataService.getBudgets()
            let budgetSpents: [(budget: Budget, spent: Decimal)] = budgets.map { budget in
                let spent = budgetRepo.computeSpent(for: budget, transactions: allTransactions)
                return (budget: budget, spent: spent)
            }
            self.topBudgets = Array(budgetSpents.prefix(3))
        } catch {
            print("Error loading dashboard data: \(error)")
        }
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
        formatter.currencySymbol = "₹"
        return formatter.string(from: value as NSDecimalNumber) ?? "₹0.00"
    }
}
