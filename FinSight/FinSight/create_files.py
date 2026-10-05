import os

base_path = "/Users/gurudev122/Documents/AI Practise/FinSight/FinSight/Features"
dirs = [
    "Budget/ViewModels", "Budget/Views",
    "Tracking/ViewModels", "Tracking/Views",
    "Reminders/ViewModels", "Reminders/Views"
]

for d in dirs:
    os.makedirs(os.path.join(base_path, d), exist_ok=True)

files = {}

# 1. BudgetViewModel
files["Budget/ViewModels/BudgetViewModel.swift"] = """import SwiftUI

public enum BudgetStatus {
    case safe, warning, danger, exceeded
    
    var color: Color {
        switch self {
        case .safe: return Color.App.budgetSafe
        case .warning: return Color.App.budgetWarning
        case .danger: return Color.App.budgetDanger
        case .exceeded: return Color.App.budgetExceeded
        }
    }
}

public struct BudgetProgress: Identifiable {
    public let id: String
    public let budget: Budget
    public let spent: Decimal
    public let progress: Double
    public let status: BudgetStatus
    public let remaining: Decimal
    
    public init(budget: Budget, spent: Decimal) {
        self.id = budget.id
        self.budget = budget
        self.spent = spent
        
        let limit = budget.limitAmount > 0 ? budget.limitAmount : 1
        let dSpent = NSDecimalNumber(decimal: spent).doubleValue
        let dLimit = NSDecimalNumber(decimal: limit).doubleValue
        let rawProgress = dSpent / dLimit
        self.progress = max(0, min(rawProgress, 1.0)) // For progress bar
        
        self.remaining = max(0, budget.limitAmount - spent)
        
        if rawProgress >= 0.95 {
            self.status = .exceeded
        } else if rawProgress >= 0.80 {
            self.status = .danger
        } else if rawProgress >= 0.60 {
            self.status = .warning
        } else {
            self.status = .safe
        }
    }
}

@Observable
public class BudgetViewModel {
    public var budgets: [Budget] = []
    public var selectedPeriod: BudgetPeriod = .monthly
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var showAddBudget: Bool = false
    public var editingBudget: Budget? = nil
    
    private let dataService: DataServiceProtocol
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public var overallBudget: BudgetProgress? {
        guard let budget = budgets.first(where: { $0.isOverall && $0.period == selectedPeriod }) else { return nil }
        return computeSpending(for: budget, from: []) // Mock spent logic since we need transactions
    }
    
    public var categoryBudgets: [BudgetProgress] {
        budgets.filter { !$0.isOverall && $0.period == selectedPeriod }
               .map { computeSpending(for: $0, from: []) } // Mock spent logic
    }
    
    public func loadBudgets() async {
        isLoading = true
        do {
            budgets = try await dataService.getBudgets()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func addBudget(_ budget: Budget) {
        budgets.append(budget)
        Task { try? await dataService.saveBudget(budget) }
    }
    
    public func deleteBudget(id: String) {
        budgets.removeAll(where: { $0.id == id })
    }
    
    public func computeSpending(for budget: Budget, from transactions: [Transaction]) -> BudgetProgress {
        // In reality, we filter transactions matching budget criteria, here returning mock spent
        return BudgetProgress(budget: budget, spent: Decimal(Int.random(in: 100...20000)))
    }
}
"""

# 2. BudgetManagementView
files["Budget/Views/BudgetManagementView.swift"] = """import SwiftUI

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
                    Text("of \\(progress.budget.limitAmount.formattedAsCurrency())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            .padding()
            
            Text("\\(progress.remaining.formattedAsCurrency()) remaining")
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
                Text("\\(progress.spent.formattedAsCurrency()) / \\(progress.budget.limitAmount.formattedAsCompact)")
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
"""

# 3. BudgetFormView
files["Budget/Views/BudgetFormView.swift"] = """import SwiftUI

public struct BudgetFormView: View {
    @Environment(\\.dismiss) private var dismiss
    var viewModel: BudgetViewModel
    
    @State private var isOverall: Bool = false
    @State private var category: String = "Groceries"
    @State private var limitAmountText: String = ""
    @State private var period: BudgetPeriod = .monthly
    
    let categories = ["Groceries", "Dining", "Transport", "Entertainment", "Shopping"]
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Budget Type")) {
                    Toggle("Overall Budget", isOn: $isOverall)
                    
                    if !isOverall {
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \\.self) {
                                Text($0).tag($0)
                            }
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    TextField("Limit Amount", text: $limitAmountText)
                        .keyboardType(.decimalPad)
                    
                    Picker("Period", selection: $period) {
                        Text("Weekly").tag(BudgetPeriod.weekly)
                        Text("Monthly").tag(BudgetPeriod.monthly)
                    }
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(Decimal(string: limitAmountText) == nil || Decimal(string: limitAmountText)! <= 0)
                }
            }
        }
    }
    
    private func save() {
        let amount = Decimal(string: limitAmountText) ?? 0
        let newBudget = Budget(
            id: UUID().uuidString,
            period: period,
            category: isOverall ? nil : category,
            limitAmount: amount,
            isOverall: isOverall
        )
        viewModel.addBudget(newBudget)
        dismiss()
    }
}
"""

# 4. BudgetDetailView
files["Budget/Views/BudgetDetailView.swift"] = """import SwiftUI

public struct BudgetDetailView: View {
    public let progress: BudgetProgress
    public var viewModel: BudgetViewModel
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(progress.progress))
                        .stroke(progress.status.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\\(Int(progress.progress * 100))%")
                            .font(.system(size: 40, weight: .bold))
                        Text("Spent")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                .padding()
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Spent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(progress.spent.formattedAsCurrency())
                            .font(.title3.bold())
                    }
                    VStack {
                        Text("Limit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(progress.budget.limitAmount.formattedAsCurrency())
                            .font(.title3.bold())
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transactions")
                        .sectionHeader()
                    
                    Text("No transactions yet.")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle(progress.budget.category ?? "Overall Budget")
    }
}
"""

# 5. TrackingViewModel
files["Tracking/ViewModels/TrackingViewModel.swift"] = """import SwiftUI

@Observable
public class TrackingViewModel {
    public var expectedTransactions: [ExpectedTransaction] = []
    public var flaggedTransactions: [Transaction] = [] // For Flagged items
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var showAddExpected: Bool = false
    
    public init() {}
    
    public var pendingExpected: [ExpectedTransaction] {
        expectedTransactions.filter { $0.status == .pending }
    }
    
    public var completedExpected: [ExpectedTransaction] {
        expectedTransactions.filter { $0.status == .completed }
    }
    
    public var overdueCount: Int {
        pendingExpected.filter { $0.isOverdue }.count
    }
    
    public var pendingCount: Int {
        pendingExpected.count
    }
    
    public func loadExpectedTransactions() async {
        isLoading = true
        // Mock load
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    public func addExpected(_ transaction: ExpectedTransaction) {
        expectedTransactions.append(transaction)
    }
    
    public func markAsCompleted(id: String, matchedTransactionId: String) {
        if let idx = expectedTransactions.firstIndex(where: { $0.id == id }) {
            expectedTransactions[idx].status = .completed
            expectedTransactions[idx].matchedTransactionId = matchedTransactionId
        }
    }
    
    public func cancel(id: String) {
        if let idx = expectedTransactions.firstIndex(where: { $0.id == id }) {
            expectedTransactions[idx].status = .cancelled
        }
    }
    
    public func delete(id: String) {
        expectedTransactions.removeAll(where: { $0.id == id })
    }
    
    public func resolveFlag(id: String) {
        flaggedTransactions.removeAll(where: { $0.id == id })
    }
}
"""

# 6. ExpectedTransactionsView
files["Tracking/Views/ExpectedTransactionsView.swift"] = """import SwiftUI

public struct ExpectedTransactionsView: View {
    @State private var viewModel: TrackingViewModel
    
    public init(viewModel: TrackingViewModel) {
        self.viewModel = viewModel
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
                                Text("Expected by \\(expected.expectedBy.relativeDateString)")
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
"""

# 7. AddExpectedTransactionView
files["Tracking/Views/AddExpectedTransactionView.swift"] = """import SwiftUI

public struct AddExpectedTransactionView: View {
    @Environment(\\.dismiss) private var dismiss
    var viewModel: TrackingViewModel
    
    @State private var source: String = ""
    @State private var amountText: String = ""
    @State private var expectedBy: Date = Date().addingTimeInterval(86400 * 7)
    @State private var tolerance: Double = 0.05
    @State private var notes: String = ""
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Who/What are you expecting money from?", text: $source)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Expected by", selection: $expectedBy, displayedComponents: .date)
                }
                
                Section(header: Text("Amount Tolerance: \\(Int(tolerance * 100))%")) {
                    Slider(value: $tolerance, in: 0...0.20, step: 0.01)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Track New Expected")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(source.isEmpty || Decimal(string: amountText) == nil)
                }
            }
        }
    }
    
    private func save() {
        let amount = Decimal(string: amountText) ?? 0
        let newExpected = ExpectedTransaction(
            source: source,
            expectedAmount: amount,
            amountTolerance: tolerance,
            expectedBy: expectedBy,
            notes: notes.isEmpty ? nil : notes
        )
        viewModel.addExpected(newExpected)
        dismiss()
    }
}
"""

# 8. RemindersViewModel
files["Reminders/ViewModels/RemindersViewModel.swift"] = """import SwiftUI

@Observable
public class RemindersViewModel {
    public var reminders: [Reminder] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var showAddReminder: Bool = false
    
    public init() {}
    
    public var upcomingReminders: [Reminder] {
        reminders.filter { $0.status == .upcoming || $0.status == .dueToday }
    }
    
    public var overdueReminders: [Reminder] {
        reminders.filter { $0.status == .overdue }
    }
    
    public var completedReminders: [Reminder] {
        reminders.filter { $0.status == .completed }
    }
    
    public var overdueCount: Int {
        overdueReminders.count
    }
    
    public var upcomingCount: Int {
        upcomingReminders.count
    }
    
    public func loadReminders() async {
        isLoading = true
        // Mock API call
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    public func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
    
    public func markAsPaid(id: String) async {
        if let idx = reminders.firstIndex(where: { $0.id == id }) {
            reminders[idx].status = .completed
            // In a real app, create a transaction here via Repository
        }
    }
    
    public func snooze(id: String, days: Int) {
        if let idx = reminders.firstIndex(where: { $0.id == id }) {
            reminders[idx].dueDate = Calendar.current.date(byAdding: .day, value: days, to: reminders[idx].dueDate) ?? Date()
            reminders[idx].status = .upcoming
        }
    }
    
    public func delete(id: String) {
        reminders.removeAll(where: { $0.id == id })
    }
}
"""

# 9. RemindersView
files["Reminders/Views/RemindersView.swift"] = """import SwiftUI

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
                        ForEach(1...30, id: \\.self) { day in
                            Text("\\(day)")
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
                    Text("Due \\(reminder.dueDate.relativeDateString)")
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
"""

# 10. AddReminderView
files["Reminders/Views/AddReminderView.swift"] = """import SwiftUI

public struct AddReminderView: View {
    @Environment(\\.dismiss) private var dismiss
    var viewModel: RemindersViewModel
    
    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var dueDate: Date = Date().addingTimeInterval(86400 * 3)
    @State private var isRecurring: Bool = false
    @State private var recurrence: RecurringFrequency = .monthly
    @State private var notes: String = ""
    @State private var notifyDays: Set<Int> = [3, 1]
    
    let notifyOptions = [7, 3, 1, 0]
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title (e.g., LIC Premium)", text: $title)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section(header: Text("Recurrence")) {
                    Toggle("Repeat", isOn: $isRecurring)
                    if isRecurring {
                        Picker("Frequency", selection: $recurrence) {
                            ForEach(RecurringFrequency.allCases) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                    }
                }
                
                Section(header: Text("Notify me (Days before)")) {
                    HStack {
                        ForEach(notifyOptions, id: \\.self) { day in
                            Text("\\(day)")
                                .padding()
                                .background(notifyDays.contains(day) ? Color.App.accentPrimary : Color.gray.opacity(0.2))
                                .foregroundColor(notifyDays.contains(day) ? .white : .primary)
                                .clipShape(Circle())
                                .onTapGesture {
                                    if notifyDays.contains(day) {
                                        notifyDays.remove(day)
                                    } else {
                                        notifyDays.insert(day)
                                    }
                                }
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.isEmpty || Decimal(string: amountText) == nil)
                }
            }
        }
    }
    
    private func save() {
        let amount = Decimal(string: amountText) ?? 0
        let newReminder = Reminder(
            title: title,
            amount: amount,
            dueDate: dueDate,
            recurrence: isRecurring ? recurrence : nil,
            notes: notes.isEmpty ? nil : notes,
            notifyDaysBefore: Array(notifyDays)
        )
        viewModel.addReminder(newReminder)
        dismiss()
    }
}
"""

# 11. FlaggedItemsView
files["Tracking/Views/FlaggedItemsView.swift"] = """import SwiftUI

public struct FlaggedItemsView: View {
    @State private var viewModel: TrackingViewModel
    
    public init(viewModel: TrackingViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List {
            if viewModel.flaggedTransactions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("No flagged items. You're all clear! ✅")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.flaggedTransactions) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.App.flagged)
                                Text(transaction.title)
                                    .font(.headline)
                            }
                            Text(transaction.flagNote ?? "Flagged item")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(transaction.amount.formattedAsCurrency())
                                .font(.subheadline.bold())
                            Button("Resolve") {
                                viewModel.resolveFlag(id: transaction.id)
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Unflag") {
                            viewModel.resolveFlag(id: transaction.id)
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .navigationTitle("Flagged Items")
    }
}
"""

# 12. RecurringTransactionsView
files["Tracking/Views/RecurringTransactionsView.swift"] = """import SwiftUI

public struct RecurringTransactionsView: View {
    @State private var viewModel: RecurringViewModel
    
    public init(viewModel: RecurringViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List {
            if !viewModel.aiSuggestions.isEmpty {
                Section(header: Text("AI Suggestions").foregroundColor(.App.aiSuggestion)) {
                    ForEach(viewModel.aiSuggestions) { rule in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.App.aiSuggestion)
                                Text(rule.templateTitle)
                                    .font(.headline)
                                Spacer()
                                if let score = rule.confidenceScore {
                                    Text("\\(Int(score * 100))% Match")
                                        .font(.caption)
                                        .foregroundColor(.App.aiSuggestion)
                                }
                            }
                            
                            Text("Looks like you pay \\(rule.templateAmount.formattedAsCurrency()) \\(rule.frequency.displayName.lowercased()).")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Button("Dismiss") {
                                    viewModel.dismissSuggestion(id: rule.id)
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button("Accept") {
                                    viewModel.acceptSuggestion(id: rule.id)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.App.aiSuggestion)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Section(header: Text("Active Rules")) {
                if viewModel.activeRules.isEmpty {
                    Text("No active recurring transactions.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.activeRules) { rule in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(rule.templateTitle)
                                    .font(.headline)
                                Text("Next: \\(rule.nextOccurrence.relativeDateString)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(rule.templateAmount.formattedAsCurrency())
                                    .font(.subheadline.bold())
                                Text(rule.frequency.displayName)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteRule(id: rule.id)
                            }
                            Button("Pause") {
                                viewModel.pauseRule(id: rule.id)
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
        }
        .navigationTitle("Recurring")
        .task {
            await viewModel.loadRecurringRules()
        }
    }
}
"""

# 13. RecurringViewModel
files["Tracking/ViewModels/RecurringViewModel.swift"] = """import SwiftUI

@Observable
public class RecurringViewModel {
    public var aiSuggestions: [RecurringRule] = []
    public var activeRules: [RecurringRule] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public init() {}
    
    public func loadRecurringRules() async {
        isLoading = true
        // Mock data for UI
        if aiSuggestions.isEmpty && activeRules.isEmpty {
            let mockSuggestion = RecurringRule(
                templateTitle: "Netflix Subscription",
                templateType: .expense,
                templateAmount: 499.0,
                frequency: .monthly,
                startDate: Date(),
                nextOccurrence: Date().addingTimeInterval(86400 * 5),
                isActive: false,
                isAIDetected: true,
                confidenceScore: 0.95
            )
            aiSuggestions.append(mockSuggestion)
            
            let mockActive = RecurringRule(
                templateTitle: "Internet Bill",
                templateType: .expense,
                templateAmount: 999.0,
                frequency: .monthly,
                startDate: Date(),
                nextOccurrence: Date().addingTimeInterval(86400 * 10),
                isActive: true
            )
            activeRules.append(mockActive)
        }
        isLoading = false
    }
    
    public func acceptSuggestion(id: String) {
        if let idx = aiSuggestions.firstIndex(where: { $0.id == id }) {
            var rule = aiSuggestions.remove(at: idx)
            rule.isActive = true
            rule.isAIDetected = false // Accepted by user
            activeRules.append(rule)
        }
    }
    
    public func dismissSuggestion(id: String) {
        aiSuggestions.removeAll(where: { $0.id == id })
    }
    
    public func pauseRule(id: String) {
        if let idx = activeRules.firstIndex(where: { $0.id == id }) {
            activeRules[idx].isActive = false
        }
    }
    
    public func deleteRule(id: String) {
        activeRules.removeAll(where: { $0.id == id })
    }
    
    public func editRule(id: String) {
        // Implementation for editing rule
    }
}
"""

# 14. TrackingHubView
files["Tracking/Views/TrackingHubView.swift"] = """import SwiftUI

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
                            subtitle: trackingViewModel.pendingCount > 0 ? "\\(trackingViewModel.pendingCount) pending items" : "No pending items"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: RemindersView(viewModel: remindersViewModel)) {
                        hubCard(
                            title: "Payment Reminders",
                            icon: "bell.badge.fill",
                            color: .orange,
                            badgeCount: remindersViewModel.overdueCount,
                            subtitle: remindersViewModel.overdueCount > 0 ? "\\(remindersViewModel.overdueCount) overdue reminders" : "Up to date"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: RecurringTransactionsView(viewModel: recurringViewModel)) {
                        hubCard(
                            title: "Recurring Transactions",
                            icon: "repeat.circle.fill",
                            color: .purple,
                            badgeCount: recurringViewModel.aiSuggestions.count,
                            subtitle: "\\(recurringViewModel.activeRules.count) active rules"
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
"""

for path, content in files.items():
    full_path = os.path.join(base_path, path)
    with open(full_path, "w") as f:
        f.write(content)

print("All files created successfully.")
