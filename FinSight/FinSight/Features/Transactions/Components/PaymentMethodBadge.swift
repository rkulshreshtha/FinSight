import SwiftUI

public struct PaymentMethodBadge: View {
    public let method: PaymentMethod
    
    public init(method: PaymentMethod) {
        self.method = method
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: method.iconName)
                .font(.caption2)
            
            Text(shortName)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.15))
        .cornerRadius(8)
        .foregroundColor(.primary)
    }
    
    private var shortName: String {
        switch method.type {
        case .creditCard, .debitCard:
            if let bank = method.bankName, let last4 = method.last4 {
                return "\(bank) ····\(last4)"
            }
            return method.displayName
        case .wallet:
            return method.walletName ?? method.displayName
        case .upi:
            return method.upiId ?? method.displayName
        case .bankTransfer:
            return method.bankName ?? method.displayName
        case .cash:
            return "Cash"
        }
    }
}
