import SwiftUI

public struct TransactionTypeChips: View {
    @Binding var selectedType: TransactionType
    
    public init(selectedType: Binding<TransactionType>) {
        self._selectedType = selectedType
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionType.allCases) { type in
                    Button(action: {
                        withAnimation {
                            selectedType = type
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: iconName(for: type))
                            Text(type.displayName)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedType == type ? 
                            Color.App.accentPrimary : Color.clear
                        )
                        .foregroundColor(selectedType == type ? .white : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedType == type ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(20)
                    }
                    .accessibilityLabel("\(type.displayName) transaction type")
                    .accessibilityAddTraits(selectedType == type ? .isSelected : [])
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func iconName(for type: TransactionType) -> String {
        switch type {
        case .income: return "arrow.down.left"
        case .expense: return "arrow.up.right"
        case .transfer: return "arrow.left.arrow.right"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loanGiven: return "person.2"
        case .loanReceived: return "person.2"
        case .cashback: return "gift"
        }
    }
}
