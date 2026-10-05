import SwiftUI

public struct BudgetManagementView: View {
    @State private var viewModel: BudgetViewModel
    
    public init(viewModel: BudgetViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    Text("Weekly").tag(BudgetPeriod.weekly)
                    Text("Monthly").tag(BudgetPeriod.monthly)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if let overall = viewModel.overallBudget {
                    overallBudgetCard(overall)
                } else {
                    Button(action: { viewModel.showAddBudget = true }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                            Text("Set Overall Budget")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cardStyle()
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Category Budgets")
                            .sectionHeader()
                        Spacer()
                        Button("+ Add") { viewModel.showAddBudget = true }
                    }
                    
                    if viewModel.categoryBudgets.isEmpty {
                        Text("No category budgets set.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(viewModel.categoryBudgets) { progress in
                            NavigationLink(destination: BudgetDetailView(progress: progress, viewModel: viewModel)) {
                                categoryBudgetRow(progress)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Budgets")
        .sheet(isPresented: $viewModel.showAddBudget) {
            BudgetFormView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadBudgets()
        }
    }
    
    @ViewBuilder
    private func overallBudgetCard(_ progress: BudgetProgress) -> some View {
        VStack {
            Text("Overall Spending")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress.progress))
                    .stroke(progress.status.color, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(progress.spent.formattedAsCurrency())
                        .font(.title2.bold())
                    Text("of \(progress.budget.limitAmount.formattedAsCurrency())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            .padding()
            
            Text("\(progress.remaining.formattedAsCurrency()) remaining")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func categoryBudgetRow(_ progress: BudgetProgress) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.App.accentPrimary)
                Text(progress.budget.category ?? "Unknown")
                    .font(.headline)
                Spacer()
                Text("\(progress.spent.formattedAsCurrency()) / \(progress.budget.limitAmount.formattedAsCompact)")
                    .font(.subheadline)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    Capsule()
                        .fill(progress.status.color)
                        .frame(width: max(0, geo.size.width * CGFloat(progress.progress)))
                }
            }
            .frame(height: 8)
        }
        .cardStyle()
    }
}
