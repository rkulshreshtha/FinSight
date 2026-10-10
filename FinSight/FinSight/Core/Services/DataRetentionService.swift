import Foundation

public struct RetentionSummary {
    public let oldestDate: Date
    public let newestDate: Date
    public let totalCount: Int
    public let expiringCount: Int
    public let daysUntilFirstExpiry: Int
}

@Observable
@MainActor
public class DataRetentionService {
    public var oldestTransactionDate: Date? = nil
    public var daysUntilPurge: Int = 365
    public var shouldShowExportWarning: Bool = false
    public var lastPurgeDate: Date? = nil
    
    private let dataService: DataServiceProtocol
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func checkRetentionStatus() async {
        do {
            let filter = TransactionFilter()
            let transactions = try await dataService.getTransactions(filter: filter)
            let sorted = transactions.sorted { $0.date < $1.date }
            
            if let oldest = sorted.first {
                self.oldestTransactionDate = oldest.date
                let daysOld = Calendar.current.dateComponents([.day], from: oldest.date, to: Date()).day ?? 0
                self.daysUntilPurge = max(0, 365 - daysOld)
                self.shouldShowExportWarning = self.daysUntilPurge <= 30
            }
        } catch {
            print("Error checking retention status: \(error)")
        }
    }
    
    public func purgeExpiredData() async throws -> Int {
        let filter = TransactionFilter()
        let transactions = try await dataService.getTransactions(filter: filter)
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date()
        let expired = transactions.filter { $0.date < cutoffDate }
        
        var count = 0
        for tx in expired {
            try await dataService.deleteTransaction(id: tx.id)
            count += 1
        }
        
        self.lastPurgeDate = Date()
        await checkRetentionStatus()
        return count
    }
    
    public func getExpiringTransactions(withinDays days: Int) async -> [Transaction] {
        do {
            let filter = TransactionFilter()
            let transactions = try await dataService.getTransactions(filter: filter)
            
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -(365 - days), to: Date()) ?? Date()
            let oldDate = Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date()
            
            return transactions.filter { $0.date >= oldDate && $0.date <= cutoffDate }
        } catch {
            return []
        }
    }
    
    public func scheduleExportReminder() {
        // Here you would use UNUserNotificationCenter to schedule a local notification
        // For example:
        // if shouldShowExportWarning {
        //     let content = UNMutableNotificationContent()
        //     content.title = "Data Expiring Soon"
        //     content.body = "Some of your transactions will be deleted soon. Export them now."
        //     ...
        // }
    }
    
    public func getRetentionSummary() async -> RetentionSummary {
        do {
            let filter = TransactionFilter()
            let transactions = try await dataService.getTransactions(filter: filter)
            
            let sorted = transactions.sorted { $0.date < $1.date }
            let oldest = sorted.first?.date ?? Date()
            let newest = sorted.last?.date ?? Date()
            
            let expiring = await getExpiringTransactions(withinDays: 30)
            
            let daysOld = Calendar.current.dateComponents([.day], from: oldest, to: Date()).day ?? 0
            let daysUntilFirstExpiry = max(0, 365 - daysOld)
            
            return RetentionSummary(
                oldestDate: oldest,
                newestDate: newest,
                totalCount: transactions.count,
                expiringCount: expiring.count,
                daysUntilFirstExpiry: daysUntilFirstExpiry
            )
        } catch {
            return RetentionSummary(oldestDate: Date(), newestDate: Date(), totalCount: 0, expiringCount: 0, daysUntilFirstExpiry: 365)
        }
    }
}
