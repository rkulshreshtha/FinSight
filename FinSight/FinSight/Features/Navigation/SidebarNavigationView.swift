import SwiftUI

public struct SidebarNavigationView: View {
    @State private var selectedItem: NavigationItem? = .dashboard
    @State private var isAddTransactionPresented = false
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                Section("Main") {
                    NavigationLink(value: NavigationItem.dashboard) {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                    NavigationLink(value: NavigationItem.transactions) {
                        Label("Transactions", systemImage: "list.bullet.rectangle.portrait")
                    }
                }
                
                Section("Tracking") {
                    NavigationLink(value: NavigationItem.expected) {
                        Label("Expected", systemImage: "calendar")
                    }
                    NavigationLink(value: NavigationItem.reminders) {
                        Label("Reminders", systemImage: "bell.fill")
                    }
                    NavigationLink(value: NavigationItem.recurring) {
                        Label("Recurring", systemImage: "arrow.2.squarepath")
                    }
                    NavigationLink(value: NavigationItem.flagged) {
                        Label("Flagged", systemImage: "flag.fill")
                    }
                }
                
                Section("Manage") {
                    NavigationLink(value: NavigationItem.budgets) {
                        Label("Budgets", systemImage: "chart.pie.fill")
                    }
                    NavigationLink(value: NavigationItem.paymentMethods) {
                        Label("Payment Methods", systemImage: "creditcard.fill")
                    }
                }
                
                Section("Account") {
                    NavigationLink(value: NavigationItem.settings) {
                        Label("Settings", systemImage: "gear")
                    }
                    NavigationLink(value: NavigationItem.export) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("FinSight")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isAddTransactionPresented = true }) {
                        Label("New Transaction", systemImage: "plus")
                    }
                }
            }
        } detail: {
            NavigationStack {
                switch selectedItem {
                case .dashboard:
                    DashboardView()
                case .transactions:
                    TransactionListView()
                case .expected:
                    ExpectedTransactionsView()
                case .reminders:
                    RemindersView()
                case .recurring:
                    RecurringTransactionsView()
                case .flagged:
                    FlaggedItemsView()
                case .budgets:
                    BudgetManagementView()
                case .paymentMethods:
                    PaymentMethodsView()
                case .settings:
                    SettingsView()
                case .export:
                    ExportView()
                case .none:
                    Text("Select an item to view")
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $isAddTransactionPresented) {
            NavigationStack {
                AddTransactionView()
                    .navigationTitle("New Transaction")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isAddTransactionPresented = false
                            }
                        }
                    }
            }
        }
    }
}

public enum NavigationItem: Hashable {
    case dashboard, transactions, expected, reminders, recurring, flagged, budgets, paymentMethods, settings, export
}
