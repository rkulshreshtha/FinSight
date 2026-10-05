import SwiftUI

public struct RemindersView: View {
    @State private var viewModel: RemindersViewModel
    
    public init(viewModel: RemindersViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mock Calendar View
                VStack(alignment: .leading) {
                    Text("Calendar")
                        .sectionHeader()
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        ForEach(1...30, id: \.self) { day in
                            Text("\(day)")
                                .frame(width: 30, height: 30)
                                .background(day % 7 == 0 ? Color.App.accentPrimary.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    .cardStyle()
                }
                .padding(.horizontal)
                
                if !viewModel.overdueReminders.isEmpty {
                    reminderSection(title: "Overdue", reminders: viewModel.overdueReminders, color: .App.danger)
                }
                
                reminderSection(title: "Upcoming", reminders: viewModel.upcomingReminders, color: .App.accentPrimary)
            }
            .padding(.vertical)
        }
        .navigationTitle("Payment Reminders")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.showAddReminder = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Reminder")
            }
        }
        .sheet(isPresented: $viewModel.showAddReminder) {
            AddReminderView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadReminders()
        }
    }
    
    @ViewBuilder
    private func reminderSection(title: String, reminders: [Reminder], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            if reminders.isEmpty {
                Text("No reminders.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(reminders) { reminder in
                    reminderRow(reminder)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func reminderRow(_ reminder: Reminder) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                HStack {
                    Text("Due \(reminder.dueDate.relativeDateString)")
                        .font(.caption)
                    if let recurrence = reminder.recurrence {
                        Text(recurrence.displayName)
                            .font(.caption2)
                            .padding(4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(reminder.amount.formattedAsCurrency())
                    .font(.subheadline.bold())
                Button("Mark Paid") {
                    Task { await viewModel.markAsPaid(id: reminder.id) }
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
            }
        }
        .cardStyle()
        .contextMenu {
            Button("Snooze (1 Day)") { viewModel.snooze(id: reminder.id, days: 1) }
            Button("Delete", role: .destructive) { viewModel.delete(id: reminder.id) }
        }
    }
}
