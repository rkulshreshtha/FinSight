import Foundation

public struct PaymentSplit: Codable, Hashable, Identifiable {
    public let methodId: String
    public var amount: Decimal
    
    public var id: String { methodId }
    
    public init(methodId: String, amount: Decimal) {
        self.methodId = methodId
        self.amount = amount
    }
}
