import SwiftUI

public struct AddExpectedTransactionView: View {
    @Environment(\.dismiss) private var dismiss
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
                
                Section(header: Text("Amount Tolerance: \(Int(tolerance * 100))%")) {
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
