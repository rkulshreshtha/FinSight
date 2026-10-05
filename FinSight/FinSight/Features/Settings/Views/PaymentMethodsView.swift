import SwiftUI

public struct PaymentMethodsView: View {
    @State private var viewModel: PaymentMethodsViewModel
    
    public init(viewModel: PaymentMethodsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.groupedMethods.isEmpty {
                Text("No payment methods yet. Add your first one!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.groupedMethods, id: \.0) { type, methods in
                    Section(header: Text(type.displayName.uppercased())) {
                        ForEach(methods) { method in
                            PaymentMethodRow(method: method) {
                                viewModel.editingMethod = method
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deletePaymentMethod(method)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Payment Methods")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddForm) {
            NavigationStack {
                PaymentMethodFormView(
                    viewModel: viewModel,
                    editingMethod: nil,
                    onSave: { newMethod in
                        viewModel.paymentMethods.append(newMethod)
                        viewModel.groupMethods()
                    }
                )
            }
        }
        .sheet(item: $viewModel.editingMethod) { method in
            NavigationStack {
                PaymentMethodFormView(
                    viewModel: viewModel,
                    editingMethod: method,
                    onSave: { updatedMethod in
                        if let index = viewModel.paymentMethods.firstIndex(where: { $0.id == updatedMethod.id }) {
                            viewModel.paymentMethods[index] = updatedMethod
                        }
                        viewModel.groupMethods()
                    }
                )
            }
        }
        .task {
            await viewModel.loadPaymentMethods()
        }
    }
}

fileprivate struct PaymentMethodRow: View {
    let method: PaymentMethod
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack {
                Image(systemName: method.iconName)
                    .foregroundColor(.App.accentPrimary)
                    .font(.title2)
                    .frame(width: 32, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    if let bank = method.bankName, method.type == .creditCard || method.type == .debitCard || method.type == .bankTransfer {
                        Text(bank)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if method.isDefault {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
