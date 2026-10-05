import SwiftUI

public struct BudgetFormView: View {
    @Environment(\.dismiss) private var dismiss
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
                            ForEach(categories, id: \.self) {
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
