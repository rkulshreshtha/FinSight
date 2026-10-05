import SwiftUI

public struct AggregateSummaryBar: View {
    let viewModel: TransactionListViewModel
    
    public init(viewModel: TransactionListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Credits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(viewModel.totalCredits.formattedAsCurrency())
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.App.income)
            }
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("Debits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(viewModel.totalDebits.formattedAsCurrency())
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.App.expense)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Net (\(viewModel.transactionCount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                let net = viewModel.netAmount
                Text(net.formattedAsCurrency())
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(net >= 0 ? Color.App.income : Color.App.expense)
            }
        }
        .padding()
        .background(Color.App.sectionBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}
