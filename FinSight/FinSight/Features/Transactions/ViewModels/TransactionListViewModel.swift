import Foundation
import Observation
import SwiftUI

public enum SortOrder: String, CaseIterable, Identifiable {
    case dateDesc = "Date ↓"
    case dateAsc = "Date ↑"
    case amountDesc = "Amount ↓"
    case amountAsc = "Amount ↑"
    
    public var id: String { rawValue }
}

@Observable
public class TransactionListViewModel {
    public var transactions: [Transaction] = []
    public var allTransactions: [Transaction] = []
    public var groupedTransactions: [(String, [Transaction])] = []
    
    public var searchText: String = "" {
        didSet { searchTransactions() }
    }
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var filter: TransactionFilter = TransactionFilter()
    public var showFilterSheet: Bool = false
    
    public var sortOrder: SortOrder = .dateDesc {
        didSet { applyFilter() }
    }
    
    private let dataService: DataServiceProtocol
    
    public init(dataService: DataServiceProtocol = FirestoreService()) {
        self.dataService = dataService
    }
    
    public var activeFilterCount: Int {
        var count = 0
        if filter.dateRange != nil { count += 1 }
        if let types = filter.types, !types.isEmpty { count += 1 }
        if let cats = filter.categories, !cats.isEmpty { count += 1 }
        if let methods = filter.paymentMethodIds, !methods.isEmpty { count += 1 }
        if filter.isFlagged == true { count += 1 }
        if filter.amountRange != nil { count += 1 }
        if let itemSearch = filter.itemSearchText, !itemSearch.isEmpty { count += 1 }
        return count
    }
    
    public var totalCredits: Decimal {
        transactions.filter { $0.isCredit }.reduce(0) { $0 + $1.amount }
    }
    
    public var totalDebits: Decimal {
        transactions.filter { !$0.isCredit }.reduce(0) { $0 + $1.amount }
    }
    
    public var netAmount: Decimal {
        totalCredits - totalDebits
    }
    
    public var transactionCount: Int {
        transactions.count
    }
    
    @MainActor
    public func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        do {
            allTransactions = try await dataService.getTransactions(filter: TransactionFilter())
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func applyFilter() {
        var result = allTransactions
        
        if let range = filter.dateRange {
            result = result.filter { range.contains($0.date) }
        }
        if let types = filter.types, !types.isEmpty {
            result = result.filter { types.contains($0.type.rawValue) }
        }
        if let cats = filter.categories, !cats.isEmpty {
            result = result.filter { !$0.categories.filter(cats.contains).isEmpty }
        }
        if let flagged = filter.isFlagged, flagged {
            result = result.filter { $0.isFlagged }
        }
        if let shared = filter.isShared, shared {
            result = result.filter { $0.isShared }
        }
        
        // Sorting
        switch sortOrder {
        case .dateDesc:
            result.sort { $0.date > $1.date }
        case .dateAsc:
            result.sort { $0.date < $1.date }
        case .amountDesc:
            result.sort { $0.amount > $1.amount }
        case .amountAsc:
            result.sort { $0.amount < $1.amount }
        }
        
        transactions = result
        searchTransactions()
    }
    
    public func searchTransactions() {
        var result = transactions
        
        if !searchText.isEmpty {
            let lowerText = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(lowerText) ||
                ($0.description?.lowercased().contains(lowerText) ?? false) ||
                ($0.ocrText?.lowercased().contains(lowerText) ?? false) ||
                $0.items.contains(where: { $0.name.lowercased().contains(lowerText) })
            }
        }
        
        groupTransactionsByDate(filtered: result)
    }
    
    public func clearFilters() {
        filter = TransactionFilter()
        sortOrder = .dateDesc
        searchText = ""
        applyFilter()
    }
    
    private func groupTransactionsByDate(filtered: [Transaction]) {
        let grouped = Dictionary(grouping: filtered) { transaction -> String in
            transaction.date.relativeDateString
        }
        
        groupedTransactions = grouped.map { ($0.key, $0.value) }.sorted {
            let date1 = $0.1.first?.date ?? Date.distantPast
            let date2 = $1.1.first?.date ?? Date.distantPast
            return sortOrder == .dateDesc ? date1 > date2 : date1 < date2
        }
    }
    
    @MainActor
    public func deleteTransaction(_ transaction: Transaction) async {
        do {
            try await dataService.deleteTransaction(id: transaction.id)
            allTransactions.removeAll { $0.id == transaction.id }
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    public func toggleFlag(_ transaction: Transaction) async {
        if let index = allTransactions.firstIndex(where: { $0.id == transaction.id }) {
            var updated = allTransactions[index]
            updated.isFlagged.toggle()
            allTransactions[index] = updated
            
            do {
                try await dataService.saveTransaction(updated)
                applyFilter()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
