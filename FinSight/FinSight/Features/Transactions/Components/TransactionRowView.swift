import SwiftUI

public struct TransactionRowView: View {
    let transaction: Transaction
    
    public init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Leading Icon
            Circle()
                .fill(transaction.isCredit ? Color.App.income.opacity(0.2) : Color.App.expense.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: iconForType(transaction.type))
                        .foregroundColor(transaction.isCredit ? Color.App.income : Color.App.expense)
                        .font(.system(size: 20))
                )
            
            // Center Content
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.App.body.weight(.bold))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(transaction.date.relativeDateString)
                    Text("·")
                    // If we had a direct property for payment method name, we'd use it here.
                    // Fallback to "Card" or similar if we can't extract it simply
                    Text("Method") // Placeholder for method string
                }
                .font(.App.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                
                if !transaction.categories.isEmpty {
                    HStack {
                        ForEach(transaction.categories.prefix(2), id: \.self) { cat in
                            Text(cat)
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                        if transaction.categories.count > 2 {
                            Text("+\(transaction.categories.count - 2)")
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Trailing Content
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.App.body.weight(.semibold))
                    .foregroundColor(transaction.isCredit ? Color.App.income : Color.App.expense)
                
                if transaction.isFlagged {
                    Image(systemName: "flag.fill")
                        .foregroundColor(Color.App.flagged)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func iconForType(_ type: TransactionType) -> String {
        switch type {
        case .income: return "arrow.down.left"
        case .expense: return "arrow.up.right"
        case .transfer: return "arrow.left.arrow.right"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loanGiven: return "hand.point.right"
        case .loanReceived: return "hand.point.left"
        case .cashback: return "dollarsign.arrow.circlepath"
        }
    }
}
