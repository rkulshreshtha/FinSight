import Foundation

public struct CategoryCorrection: Codable, Hashable, Identifiable {
    public let id: String
    public var originalSuggestion: [String]
    public var correctedTo: [String]
    public var transactionTitle: String
    public var ocrContext: String?
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, originalSuggestion: [String], correctedTo: [String], transactionTitle: String, ocrContext: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.originalSuggestion = originalSuggestion
        self.correctedTo = correctedTo
        self.transactionTitle = transactionTitle
        self.ocrContext = ocrContext
        self.createdAt = createdAt
    }
}
