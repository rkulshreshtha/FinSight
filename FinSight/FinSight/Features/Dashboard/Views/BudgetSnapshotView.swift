import SwiftUI

public struct BudgetSnapshotView: View {
    var viewModel: DashboardViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Budgets")
                    .font(.headline)
                Spacer()
                Button("See All →") {
                    // Navigate to budgets
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
            
            if viewModel.topBudgets.isEmpty {
                Text("No active budgets.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.topBudgets, id: \.budget.id) { item in
                    let displayName = item.budget.isOverall ? "Overall" : (item.budget.category ?? "General")
                    BudgetProgressRow(name: displayName, spent: item.spent, limit: item.budget.limitAmount)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct BudgetProgressRow: View {
    let name: String
    let spent: Decimal
    let limit: Decimal
    
    var progress: Double {
        let s = NSDecimalNumber(decimal: spent).doubleValue
        let l = NSDecimalNumber(decimal: limit).doubleValue
        return l > 0 ? min(s / l, 1.0) : 0
    }
    
    var progressColor: Color {
        if progress < 0.6 { return .green }
        if progress < 0.8 { return .yellow }
        if progress < 0.95 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text("$\(spent) / $\(limit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
