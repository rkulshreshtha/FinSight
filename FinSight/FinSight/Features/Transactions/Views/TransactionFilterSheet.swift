import SwiftUI

public struct TransactionFilterSheet: View {
    @Bindable var viewModel: TransactionListViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var tempFilter: TransactionFilter
    @State private var tempSort: SortOrder
    
    public init(viewModel: TransactionListViewModel) {
        self.viewModel = viewModel
        self._tempFilter = State(initialValue: viewModel.filter)
        self._tempSort = State(initialValue: viewModel.sortOrder)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Sort By") {
                    Picker("Sort", selection: $tempSort) {
                        ForEach(SortOrder.allCases) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Date Range") {
                    // Placeholder for actual Date Pickers
                    Text("Date Range Picker here")
                }
                
                Section("Status") {
                    Toggle("Flagged Only", isOn: Binding(
                        get: { tempFilter.isFlagged ?? false },
                        set: { tempFilter.isFlagged = $0 ? true : nil }
                    ))
                    
                    Toggle("Shared Only", isOn: Binding(
                        get: { tempFilter.isShared ?? false },
                        set: { tempFilter.isShared = $0 ? true : nil }
                    ))
                }
                
                Section("Search Line Items") {
                    TextField("Product/Item name", text: Binding(
                        get: { tempFilter.itemSearchText ?? "" },
                        set: { tempFilter.itemSearchText = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                // Other filter sections...
                
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") {
                        tempFilter = TransactionFilter()
                        tempSort = .dateDesc
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.filter = tempFilter
                        viewModel.sortOrder = tempSort
                        viewModel.applyFilter()
                        dismiss()
                    }
                }
            }
        }
    }
}
