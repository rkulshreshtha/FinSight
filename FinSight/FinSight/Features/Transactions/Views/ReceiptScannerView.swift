import SwiftUI

public struct ReceiptScannerView: View {
    let imageData: Data
    let onAccept: (ReceiptExtractionResult) -> Void
    let onCancel: () -> Void
    
    @State private var isProcessing = true
    @State private var result: ReceiptExtractionResult?
    @State private var errorMessage: String?
    
    private let aiService = GeminiAIService()
    
    public init(imageData: Data, onAccept: @escaping (ReceiptExtractionResult) -> Void, onCancel: @escaping () -> Void) {
        self.imageData = imageData
        self.onAccept = onAccept
        self.onCancel = onCancel
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                if isProcessing {
                    ProgressView("Analyzing receipt with AI...")
                        .padding()
                } else if let err = errorMessage {
                    Text("Error: \(err)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        Task { await process() }
                    }
                    .padding()
                } else if let res = result {
                    Form {
                        Section(header: Text("Details")) {
                            Text("Merchant: \(res.merchant)")
                            Text("Amount: \(res.amount)")
                            Text("Date: \(res.date, style: .date)")
                            if res.detectedLanguage != "en" {
                                Text("Language: \(res.detectedLanguage) (Translated to English)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Items")) {
                            ForEach(res.items, id: \.name) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text(item.displayPrice)
                                }
                            }
                        }
                    }
                    
                    Button("Accept") {
                        onAccept(res)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .navigationTitle("Receipt Scanner")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
            .task {
                await process()
            }
        }
    }
    
    private func process() async {
        isProcessing = true
        errorMessage = nil
        do {
            let res = try await aiService.extractReceiptData(from: imageData)
            result = res
        } catch {
            errorMessage = error.localizedDescription
        }
        isProcessing = false
    }
}
