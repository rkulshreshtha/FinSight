import Foundation
import SwiftUI

public enum SharedContent {
    case image(Data)
    case text(String)
    case url(URL)
}

@Observable
public class ShareExtensionViewModel {
    public var sharedContent: SharedContent? = nil
    
    public var isProcessing: Bool = false
    public var processingStatus: String = ""
    public var extractedAmount: String = ""
    public var extractedTitle: String = ""
    // We mock TransactionType here since we can't easily import the main app target without a framework
    // In reality, this model could be shared via a framework or linked directly
    public var extractedType: String = "expense"
    public var extractedDate: Date = Date()
    
    public var errorMessage: String? = nil
    public var isSaving: Bool = false
    
    public init() {}
    
    public func processSharedContent() async {
        guard let content = sharedContent else { return }
        
        await MainActor.run {
            isProcessing = true
            processingStatus = "Processing with AI..."
            errorMessage = nil
        }
        
        do {
            switch content {
            case .image(let data):
                try await processImage(data)
            case .text(let text):
                try await processText(text)
            case .url(let url):
                // Mock url processing
                await MainActor.run {
                    extractedTitle = "Purchase from Link"
                    extractedAmount = "0.00"
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Could not process automatically"
            }
        }
        
        await MainActor.run {
            isProcessing = false
        }
    }
    
    public func processImage(_ data: Data) async throws {
        // Mocking AI OCR processing delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            extractedTitle = "Extracted Receipt"
            extractedAmount = "150.00"
            extractedType = "expense"
        }
    }
    
    public func processText(_ text: String) async throws {
        // Mocking AI SMS processing delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            extractedTitle = "SMS Transaction"
            extractedAmount = "25.00"
            extractedType = text.lowercased().contains("credited") ? "income" : "expense"
        }
    }
    
    public func saveDraft() async -> Bool {
        await MainActor.run { isSaving = true }
        // Write to App Group shared container
        let success = saveToSharedContainer()
        await MainActor.run { isSaving = false }
        return success
    }
    
    public func saveAndClose() async -> Bool {
        return await saveDraft()
    }
    
    private func saveToSharedContainer() -> Bool {
        let appGroupId = "group.com.rkulshreshtha.finsight"
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            return false
        }
        
        let fileURL = containerURL.appendingPathComponent("shared_transactions.json")
        
        let draft: [String: Any] = [
            "id": UUID().uuidString,
            "title": extractedTitle,
            "amount": extractedAmount,
            "type": extractedType,
            "date": ISO8601DateFormatter().string(from: extractedDate),
            "source": "shareExtension"
        ]
        
        var currentDrafts: [[String: Any]] = []
        if let data = try? Data(contentsOf: fileURL),
           let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            currentDrafts = json
        }
        
        currentDrafts.append(draft)
        
        if let data = try? JSONSerialization.data(withJSONObject: currentDrafts) {
            try? data.write(to: fileURL)
            return true
        }
        return false
    }
}
