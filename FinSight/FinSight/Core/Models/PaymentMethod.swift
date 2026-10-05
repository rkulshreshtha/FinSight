import Foundation

public struct PaymentMethod: Codable, Hashable, Identifiable {
    public let id: String
    public var type: PaymentMethodType
    public var bankName: String?
    public var last4: String?
    public var cardNetwork: CardNetwork?
    public var walletName: String?
    public var upiId: String?
    public var nickname: String
    public var isDefault: Bool
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, type: PaymentMethodType, bankName: String? = nil, last4: String? = nil, cardNetwork: CardNetwork? = nil, walletName: String? = nil, upiId: String? = nil, nickname: String, isDefault: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.bankName = bankName
        self.last4 = last4
        self.cardNetwork = cardNetwork
        self.walletName = walletName
        self.upiId = upiId
        self.nickname = nickname
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
    
    public var displayName: String {
        switch type {
        case .creditCard, .debitCard:
            let bank = bankName ?? "Card"
            let network = cardNetwork?.rawValue.capitalized ?? ""
            let ending = last4 != nil ? " ····\(last4!)" : ""
            return "\(bank) \(network)\(ending)".trimmingCharacters(in: .whitespaces)
        case .wallet:
            return walletName ?? nickname
        case .upi:
            return upiId ?? nickname
        case .bankTransfer:
            return bankName ?? nickname
        case .cash:
            return "Cash"
        }
    }
    
    public var iconName: String {
        return type.iconName
    }
}
