import Foundation
import SwiftUI

@Observable
public class ExportViewModel {
    public var startDate: Date
    public var endDate: Date
    public var selectedFormat: ExportFormat = .json
    public var includeImages: Bool = false
    public var includeOCRText: Bool = true
    public var includeCorrections: Bool = true
    
    public var transactionCount: Int = 0
    public var estimatedSizeKB: Int = 0
    
    public var isExporting: Bool = false
    public var exportProgress: Double = 0.0
    public var errorMessage: String? = nil
    public var exportedFileURL: URL? = nil
    
    private let dataService: DataServiceProtocol
    private let exportService: ExportService
    
    public init(dataService: DataServiceProtocol, exportService: ExportService = ExportService()) {
        self.dataService = dataService
        self.exportService = exportService
        
        let now = Date()
        self.endDate = now
        // Default to last 3 months
        self.startDate = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
    }
    
    public enum ExportFormat: String, CaseIterable, Identifiable {
        case csv, excel, json, pdf
        
        public var id: String { rawValue }
        
        public var title: String {
            switch self {
            case .csv: return "CSV (.csv)"
            case .excel: return "Excel (.xlsx)"
            case .json: return "JSON (.json)"
            case .pdf: return "PDF (.pdf)"
            }
        }
        
        public var description: String {
            switch self {
            case .csv: return "Spreadsheet-compatible flat file"
            case .excel: return "Rich formatting with multiple sheets"
            case .json: return "Structured data, best for AI analysis"
            case .pdf: return "Human-readable report with receipt images"
            }
        }
        
        public var fileExtension: String {
            switch self {
            case .csv: return "csv"
            case .excel: return "xlsx" // using csv under the hood
            case .json: return "json"
            case .pdf: return "pdf"
            }
        }
        
        public var mimeType: String {
            switch self {
            case .csv: return "text/csv"
            case .excel: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            case .json: return "application/json"
            case .pdf: return "application/pdf"
            }
        }
    }
    
    public func setPreset(months: Int) {
        let now = Date()
        endDate = now
        if months == 0 {
            // This month
            let comp = Calendar.current.dateComponents([.year, .month], from: now)
            startDate = Calendar.current.date(from: comp) ?? now
        } else {
            startDate = Calendar.current.date(byAdding: .month, value: -months, to: now) ?? now
        }
        Task {
            await calculatePreview()
        }
    }
    
    public func calculatePreview() async {
        do {
            var filter = TransactionFilter()
            filter.dateRange = startDate...endDate
            
            let (_, _, _, count) = try await dataService.getTotals(filter: filter)
            await MainActor.run {
                self.transactionCount = count
                // rough estimation: ~500 bytes per transaction for JSON, more for PDF with images
                var sizePerTx = 500
                if selectedFormat == .pdf && includeImages {
                    sizePerTx = 100000 // assume ~100KB per image
                }
                self.estimatedSizeKB = (count * sizePerTx) / 1024
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func export() async {
        await MainActor.run {
            self.isExporting = true
            self.exportProgress = 0.1
            self.errorMessage = nil
            self.exportedFileURL = nil
        }
        
        do {
            var filter = TransactionFilter()
            filter.dateRange = startDate...endDate
            
            let transactions = try await dataService.getTransactions(filter: filter)
            
            await MainActor.run { self.exportProgress = 0.5 }
            
            let url: URL
            switch selectedFormat {
            case .csv:
                url = try exportService.exportCSV(transactions: transactions)
            case .excel:
                url = try exportService.exportExcel(transactions: transactions)
            case .json:
                url = try exportService.exportJSON(transactions: transactions)
            case .pdf:
                url = try await exportService.exportPDF(transactions: transactions, includeImages: includeImages)
            }
            
            await MainActor.run {
                self.exportProgress = 1.0
                self.exportedFileURL = url
                self.isExporting = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isExporting = false
            }
        }
    }
    
    public func shareFile(url: URL) {
        // UIActivityViewController presentation is typically handled in View via UIViewControllerRepresentable or ShareLink
    }
}
