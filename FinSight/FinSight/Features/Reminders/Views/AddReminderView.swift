import SwiftUI

public struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
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
                        ForEach(notifyOptions, id: \.self) { day in
                            Text("\(day)")
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
