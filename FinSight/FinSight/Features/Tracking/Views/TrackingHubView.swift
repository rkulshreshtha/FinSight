import SwiftUI

public struct TrackingHubView: View {
    @State private var trackingViewModel = TrackingViewModel()
    @State private var remindersViewModel = RemindersViewModel()
    @State private var recurringViewModel = RecurringViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    NavigationLink(destination: ExpectedTransactionsView(viewModel: trackingViewModel)) {
                        hubCard(
                            title: "Expected Transactions",
                            icon: "clock.arrow.circlepath",
                            color: .blue,
                            badgeCount: trackingViewModel.pendingCount,
                            subtitle: trackingViewModel.pendingCount > 0 ? "\(trackingViewModel.pendingCount) pending items" : "No pending items"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: RemindersView(viewModel: remindersViewModel)) {
                        hubCard(
                            title: "Payment Reminders",
                            icon: "bell.badge.fill",
                            color: .orange,
                            badgeCount: remindersViewModel.overdueCount,
                            subtitle: remindersViewModel.overdueCount > 0 ? "\(remindersViewModel.overdueCount) overdue reminders" : "Up to date"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: RecurringTransactionsView(viewModel: recurringViewModel)) {
                        hubCard(
                            title: "Recurring Transactions",
                            icon: "repeat.circle.fill",
                            color: .purple,
                            badgeCount: recurringViewModel.aiSuggestions.count,
                            subtitle: "\(recurringViewModel.activeRules.count) active rules"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: FlaggedItemsView(viewModel: trackingViewModel)) {
                        hubCard(
                            title: "Flagged Items",
                            icon: "flag.fill",
                            color: .App.flagged,
                            badgeCount: trackingViewModel.flaggedTransactions.count,
                            subtitle: "Needs your attention"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Tracking")
            .task {
                await trackingViewModel.loadExpectedTransactions()
                await remindersViewModel.loadReminders()
                await recurringViewModel.loadRecurringRules()
            }
        }
    }
    
    @ViewBuilder
    private func hubCard(title: String, icon: String, color: Color, badgeCount: Int, subtitle: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .badgeOverlay(count: badgeCount)
        }
        .cardStyle()
    }
}
