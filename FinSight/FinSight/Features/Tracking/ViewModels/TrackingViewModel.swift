import SwiftUI

@Observable
public class TrackingViewModel {
    public var expectedTransactions: [ExpectedTransaction] = []
    public var flaggedTransactions: [Transaction] = [] // For Flagged items
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var showAddExpected: Bool = false
    
    public init() {}
    
    public var pendingExpected: [ExpectedTransaction] {
        expectedTransactions.filter { $0.status == .pending }
    }
    
    public var completedExpected: [ExpectedTransaction] {
        expectedTransactions.filter { $0.status == .completed }
    }
    
    public var overdueCount: Int {
        pendingExpected.filter { $0.isOverdue }.count
    }
    
    public var pendingCount: Int {
        pendingExpected.count
    }
    
    public func loadExpectedTransactions() async {
        isLoading = true
        // Mock load
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    public func addExpected(_ transaction: ExpectedTransaction) {
        expectedTransactions.append(transaction)
    }
    
    public func markAsCompleted(id: String, matchedTransactionId: String) {
        if let idx = expectedTransactions.firstIndex(where: { $0.id == id }) {
            expectedTransactions[idx].status = .completed
            expectedTransactions[idx].matchedTransactionId = matchedTransactionId
        }
    }
    
    public func cancel(id: String) {
        if let idx = expectedTransactions.firstIndex(where: { $0.id == id }) {
            expectedTransactions[idx].status = .cancelled
        }
    }
    
    public func delete(id: String) {
        expectedTransactions.removeAll(where: { $0.id == id })
    }
    
    public func resolveFlag(id: String) {
        flaggedTransactions.removeAll(where: { $0.id == id })
    }
}
