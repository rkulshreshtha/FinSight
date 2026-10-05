import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isAddTransactionPresented = false
    
    @State private var trackingViewModel = TrackingViewModel()
    @State private var remindersViewModel = RemindersViewModel()
    
    public init() {}
    
    private var trackingBadgeCount: Int {
        trackingViewModel.flaggedTransactions.count + 
        trackingViewModel.pendingCount + 
        remindersViewModel.overdueCount
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            NavigationStack {
                TransactionListView()
            }
            .tabItem {
                Label("Transactions", systemImage: "list.bullet.rectangle.portrait")
            }
            .tag(1)
            
            // Add Tab (prominent center) - handled by onChange to not navigate away
            Text("")
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            NavigationStack {
                TrackingHubView()
            }
            .tabItem {
                Label("Track", systemImage: "chart.line.uptrend.xyaxis")
            }
            .badge(trackingBadgeCount > 0 ? trackingBadgeCount : 0)
            .tag(3)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle.fill")
            }
            .tag(4)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                isAddTransactionPresented = true
                selectedTab = oldValue
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
        .onAppear {
            Task {
                await trackingViewModel.loadExpectedTransactions()
                await remindersViewModel.loadReminders()
            }
        }
    }
}
