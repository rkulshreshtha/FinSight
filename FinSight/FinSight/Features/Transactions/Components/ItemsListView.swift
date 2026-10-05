import SwiftUI

public struct ItemsListView: View {
    @Binding var items: [EditableLineItem]
    var totalAmount: Decimal
    var onAddItem: () -> Void
    var onRemoveItem: (Int) -> Void
    
    public init(items: Binding<[EditableLineItem]>, totalAmount: Decimal, onAddItem: @escaping () -> Void, onRemoveItem: @escaping (Int) -> Void) {
        self._items = items
        self.totalAmount = totalAmount
        self.onAddItem = onAddItem
        self.onRemoveItem = onRemoveItem
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, _ in
                VStack(spacing: 8) {
                    HStack {
                        if items[index].isAISuggested {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                        }
                        TextField("Item Name", text: $items[index].name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: { onRemoveItem(index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.App.danger)
                        }
                    }
                    HStack {
                        TextField("Qty", text: $items[index].quantityText)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("x")
                        TextField("Price", text: $items[index].unitPriceText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("=")
                        TextField("Total", text: $items[index].lineTotalText)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.bottom, 8)
                Divider()
            }
            
            Button(action: onAddItem) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Item")
                }
                .foregroundColor(.App.accentPrimary)
            }
            .padding(.top, 8)
            
            let currentTotal = items.reduce(0) { $0 + (Decimal(string: $1.lineTotalText) ?? 0) }
            HStack {
                Text("Subtotal:")
                    .font(.headline)
                Spacer()
                Text("₹\(NSDecimalNumber(decimal: currentTotal).stringValue)")
                    .font(.headline)
                    .foregroundColor(currentTotal == totalAmount ? .primary : .App.warning)
            }
            
            if currentTotal != totalAmount && totalAmount > 0 && !items.isEmpty {
                Text("Items subtotal doesn't match total amount")
                    .font(.caption)
                    .foregroundColor(.App.warning)
            }
        }
    }
}
