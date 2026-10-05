import SwiftUI

public struct TransactionIconView: View {
    public let type: TransactionType
    public let size: CGFloat
    
    public init(type: TransactionType, size: CGFloat = 40) {
        self.type = type
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.opacity(0.2))
                .frame(width: size, height: size)
            
            Image(systemName: iconName)
                .foregroundColor(backgroundColor)
                .font(.system(size: size * 0.5, weight: .semibold))
        }
    }
    
    private var iconName: String {
        switch type {
        case .income: return "arrow.down.left"
        case .expense: return "arrow.up.right"
        case .transfer: return "arrow.left.arrow.right"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loanGiven: return "person.badge.minus"
        case .loanReceived: return "person.badge.plus"
        case .cashback: return "gift"
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        case .investment: return .purple
        case .loanGiven: return .orange
        case .loanReceived: return .teal
        case .cashback: return .yellow
        }
    }
}
