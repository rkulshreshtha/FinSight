import SwiftUI

public struct SplitPaymentView: View {
    @Binding var splits: [EditablePaymentSplit]
    var availableMethods: [PaymentMethod]
    var totalAmount: Decimal
    var onAddSplit: () -> Void
    var onRemoveSplit: (Int) -> Void
    
    public init(splits: Binding<[EditablePaymentSplit]>, availableMethods: [PaymentMethod], totalAmount: Decimal, onAddSplit: @escaping () -> Void, onRemoveSplit: @escaping (Int) -> Void) {
        self._splits = splits
        self.availableMethods = availableMethods
        self.totalAmount = totalAmount
        self.onAddSplit = onAddSplit
        self.onRemoveSplit = onRemoveSplit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(splits.enumerated()), id: \.element.id) { index, _ in
                HStack {
                    Picker("Method", selection: $splits[index].methodId) {
                        ForEach(availableMethods) { method in
                            Text(method.displayName).tag(method.id)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                    
                    TextField("Amount", text: $splits[index].amountText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: { onRemoveSplit(index) }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.App.danger)
                    }
                }
            }
            
            Button(action: onAddSplit) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add another")
                }
                .foregroundColor(.App.accentPrimary)
            }
            
            let currentTotal = splits.reduce(0) { $0 + (Decimal(string: $1.amountText) ?? 0) }
            HStack {
                Text("Total:")
                Spacer()
                Text("\(NSDecimalNumber(decimal: currentTotal).stringValue)")
                    .foregroundColor(currentTotal == totalAmount ? .primary : .App.danger)
            }
            .font(.headline)
            
            if currentTotal != totalAmount && totalAmount > 0 {
                Text("Split total must equal transaction amount (\(NSDecimalNumber(decimal: totalAmount).stringValue))")
                    .font(.caption)
                    .foregroundColor(.App.danger)
            }
        }
    }
}
