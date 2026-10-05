import Foundation

public struct LineItem: Codable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var nameTranslated: String?
    public var quantity: Decimal
    public var unit: String?
    public var unitPrice: Decimal?
    public var lineTotal: Decimal
    public var source: ItemSource
    
    public init(id: UUID = UUID(), name: String, nameTranslated: String? = nil, quantity: Decimal = 1, unit: String? = nil, unitPrice: Decimal? = nil, lineTotal: Decimal, source: ItemSource) {
        self.id = id
        self.name = name
        self.nameTranslated = nameTranslated
        self.quantity = quantity
        self.unit = unit
        self.unitPrice = unitPrice
        self.lineTotal = lineTotal
        self.source = source
    }
    
    public var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR" // Fallback, normally injected based on locale
        return formatter.string(from: lineTotal as NSDecimalNumber) ?? "₹0.00"
    }
}
