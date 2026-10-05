import SwiftUI

public struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(greeting)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Here's your summary")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 16) {
                            Image(systemName: "bell.fill")
                                .font(.title3)
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Month Selector
                    HStack {
                        Button {
                            viewModel.changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        Spacer()
                        Text(viewModel.formattedMonth)
                            .font(.headline)
                        Spacer()
                        Button {
                            viewModel.changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Summary Cards Row
                    HStack(spacing: 16) {
                        SummaryCardView(title: "Income", amount: viewModel.formattedIncome, icon: "arrow.down.left", color: .green)
                        SummaryCardView(title: "Expense", amount: viewModel.formattedExpense, icon: "arrow.up.right", color: .red)
                        SummaryCardView(title: "Net", amount: viewModel.formattedNet, icon: "equal", color: .blue)
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    QuickActionsView(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    // Budget Snapshot
                    BudgetSnapshotView(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    // Recent Transactions
                    RecentTransactionsView(viewModel: viewModel)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.loadDashboardData()
            }
            .overlay(
                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Add action
                        }) {
                            Image(systemName: "plus")
                                .font(.title.weight(.semibold))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4, x: 0, y: 4)
                        }
                        .padding()
                    }
                }
            )
            .task {
                await viewModel.loadDashboardData()
            }
            .navigationBarHidden(true)
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
}
