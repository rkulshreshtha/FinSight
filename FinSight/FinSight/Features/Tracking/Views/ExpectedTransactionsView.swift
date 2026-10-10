import SwiftUI

public struct ExpectedTransactionsView: View {
    @State private var viewModel: TrackingViewModel
    
    @MainActor
    public init(viewModel: TrackingViewModel = TrackingViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        List {
            Section(header: Text("Pending")) {
                if viewModel.pendingExpected.isEmpty {
                    Text("No pending expected transactions.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.pendingExpected) { expected in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expected.source)
                                    .font(.headline)
                                Text("Expected by \(expected.expectedBy.relativeDateString)")
                                    .font(.caption)
                                    .foregroundColor(expected.isOverdue ? .App.danger : .secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(expected.expectedAmount.formattedAsCurrency())
                                    .font(.subheadline.bold())
                                if expected.isOverdue {
                                    Text("Overdue 🔴")
                                        .font(.caption)
                                } else {
                                    Text("On track ⏳")
                                        .font(.caption)
                                }
                            }
                        }
                        .swipeActions {
                            Button("Mark Done") {
                                viewModel.markAsCompleted(id: expected.id, matchedTransactionId: "mock")
                            }
                            .tint(.green)
                            Button("Delete", role: .destructive) {
                                viewModel.delete(id: expected.id)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Completed")) {
                if viewModel.completedExpected.isEmpty {
                    Text("No completed transactions.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.completedExpected) { expected in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expected.source)
                                    .font(.headline)
                            }
                            Spacer()
                            Text(expected.expectedAmount.formattedAsCurrency())
                                .foregroundColor(.secondary)
                                .strikethrough()
                        }
                    }
                }
            }
        }
        .navigationTitle("Expected Transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.showAddExpected = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Track New")
            }
        }
        .sheet(isPresented: $viewModel.showAddExpected) {
            AddExpectedTransactionView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadExpectedTransactions()
        }
    }
}
