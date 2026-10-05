import SwiftUI

public struct RecentTransactionsView: View {
    var viewModel: DashboardViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent")
                    .font(.headline)
                Spacer()
                Button("See All →") {
                    // Navigate to transactions
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
            
            if viewModel.recentTransactions.isEmpty {
                Text("No recent transactions.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                ForEach(viewModel.recentTransactions) { transaction in
                    HStack(spacing: 12) {
                        Image(systemName: "cart.fill") // Placeholder category icon
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Date & Method")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(transaction.isExpense ? "-" : "+")$\(transaction.amount)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(transaction.isExpense ? .red : .green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
