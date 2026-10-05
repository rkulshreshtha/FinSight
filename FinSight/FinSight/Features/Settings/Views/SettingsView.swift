import SwiftUI

public struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                // ACCOUNT
                Section(header: Text("ACCOUNT")) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.userProfile?.displayName ?? "Guest")
                                .font(.headline)
                            Text(viewModel.userProfile?.email ?? "Not signed in")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button(role: .destructive) {
                        viewModel.showSignOutConfirmation = true
                    } label: {
                        Text("Sign Out")
                    }
                }
                
                // GOOGLE DRIVE
                Section(header: Text("GOOGLE DRIVE")) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Circle()
                                    .fill(viewModel.isDriveConnected ? Color.App.income : Color.App.danger)
                                    .frame(width: 8, height: 8)
                                Text(viewModel.isDriveConnected ? "Connected" : "Not Connected")
                                    .font(.body)
                            }
                            if let email = viewModel.driveEmail {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            Task {
                                if viewModel.isDriveConnected {
                                    await viewModel.disconnectGoogleDrive()
                                } else {
                                    await viewModel.connectGoogleDrive()
                                }
                            }
                        } label: {
                            Text(viewModel.isDriveConnected ? "Disconnect" : "Connect")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // APPEARANCE
                Section(header: Text("APPEARANCE")) {
                    Picker("Theme", selection: $viewModel.selectedTheme) {
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                        Text("System").tag(AppTheme.system)
                    }
                    .pickerStyle(.segmented)
                }
                
                // NOTIFICATIONS
                Section(header: Text("NOTIFICATIONS")) {
                    Toggle("Daily Summary", isOn: $viewModel.dailySummary)
                    Toggle("Budget Alerts", isOn: $viewModel.budgetAlerts)
                    Toggle("Flag Reminders", isOn: $viewModel.flagReminders)
                    Toggle("Due Date Reminders", isOn: $viewModel.dueDateReminders)
                    Toggle("Inactivity Alerts", isOn: $viewModel.inactivityAlerts)
                    Toggle("Export Warnings", isOn: $viewModel.exportWarnings)
                }
                
                // DATA MANAGEMENT
                Section(header: Text("DATA MANAGEMENT"), footer: Text("Data retention: 12-month rolling window")) {
                    NavigationLink {
                        Text("Export Data View")
                            .navigationTitle("Export Data")
                    } label: {
                        Text("Export Data")
                    }
                    
                    Button(role: .destructive) {
                        viewModel.showClearCacheConfirmation = true
                    } label: {
                        Text("Clear Local Cache")
                    }
                }
                
                // AI SETTINGS
                Section(header: Text("AI SETTINGS")) {
                    Toggle("AI Suggestions", isOn: $viewModel.aiSuggestions)
                        .onChange(of: viewModel.aiSuggestions) { _, newValue in
                            viewModel.toggleAISuggestions(newValue)
                        }
                    
                    NavigationLink {
                        Text("Category Corrections History")
                            .navigationTitle("Corrections History")
                    } label: {
                        HStack {
                            Text("Category Corrections History")
                            Spacer()
                            Text("\(viewModel.correctionCount)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // PAYMENT METHODS
                Section(header: Text("PAYMENT METHODS")) {
                    NavigationLink {
                        PaymentMethodsView(viewModel: PaymentMethodsViewModel(repository: PaymentMethodRepository(dataService: DummyDataService())))
                    } label: {
                        HStack {
                            Text("Manage Payment Methods")
                            Spacer()
                            Text("\(viewModel.paymentMethodCount)")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // ABOUT
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $viewModel.showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    try? viewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Clear Cache", isPresented: $viewModel.showClearCacheConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    Task {
                        await viewModel.clearLocalCache()
                    }
                }
            } message: {
                Text("This will clear downloaded data but won't delete data from the server. Are you sure?")
            }
        }
    }
}

fileprivate class DummyDataService: DataServiceProtocol {
    func getTransactions(filter: TransactionFilter) async throws -> [Any] { [] }
    func searchTransactions(query: String) async throws -> [Any] { [] }
    func getTotals(filter: TransactionFilter) async throws -> (credits: Decimal, debits: Decimal, net: Decimal, count: Int) { (0,0,0,0) }
    func saveTransaction(_ transaction: Any) async throws {}
    func deleteTransaction(id: String) async throws {}
    func getPaymentMethods() async throws -> [PaymentMethod] { [] }
    func savePaymentMethod(_ method: PaymentMethod) async throws {}
    func getBudgets() async throws -> [Budget] { [] }
    func saveBudget(_ budget: Budget) async throws {}
}
