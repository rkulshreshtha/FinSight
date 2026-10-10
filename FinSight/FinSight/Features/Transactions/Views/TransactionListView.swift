import SwiftUI

public struct TransactionListView: View {
    @State private var viewModel: TransactionListViewModel
    
    public init(viewModel: TransactionListViewModel = TransactionListViewModel()) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search transactions...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Filter Chips
                FilterChipsView(viewModel: viewModel)
                    .padding(.bottom, 8)
                
                // Aggregate Summary Bar
                AggregateSummaryBar(viewModel: viewModel)
                
                // List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.groupedTransactions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No transactions found")
                            .font(.App.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.groupedTransactions, id: \.0) { dateLabel, transactions in
                            Section(header: Text(dateLabel).font(.App.headline)) {
                                ForEach(transactions) { transaction in
                                    NavigationLink(value: transaction) {
                                        TransactionRowView(transaction: transaction)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task { await viewModel.deleteTransaction(transaction) }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            Task { await viewModel.toggleFlag(transaction) }
                                        } label: {
                                            Label(transaction.isFlagged ? "Unflag" : "Flag", systemImage: transaction.isFlagged ? "flag.slash" : "flag")
                                        }
                                        .tint(.App.flagged)
                                    }
                                    .contextMenu {
                                        Button {
                                            // Action for edit
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        Button {
                                            Task { await viewModel.toggleFlag(transaction) }
                                        } label: {
                                            Label(transaction.isFlagged ? "Unflag" : "Flag", systemImage: transaction.isFlagged ? "flag.slash" : "flag")
                                        }
                                        Button(role: .destructive) {
                                            Task { await viewModel.deleteTransaction(transaction) }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.loadTransactions()
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction, viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                TransactionFilterSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadTransactions()
            }
        }
    }
}
