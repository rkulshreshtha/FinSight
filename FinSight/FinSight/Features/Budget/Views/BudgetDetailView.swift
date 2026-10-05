import SwiftUI

public struct BudgetDetailView: View {
    public let progress: BudgetProgress
    public var viewModel: BudgetViewModel
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(progress.progress))
                        .stroke(progress.status.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(progress.progress * 100))%")
                            .font(.system(size: 40, weight: .bold))
                        Text("Spent")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                .padding()
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Spent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(progress.spent.formattedAsCurrency())
                            .font(.title3.bold())
                    }
                    VStack {
                        Text("Limit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(progress.budget.limitAmount.formattedAsCurrency())
                            .font(.title3.bold())
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transactions")
                        .sectionHeader()
                    
                    Text("No transactions yet.")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle(progress.budget.category ?? "Overall Budget")
    }
}
