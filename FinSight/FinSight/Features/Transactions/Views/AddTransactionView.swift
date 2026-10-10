import SwiftUI

public struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddTransactionViewModel
    
    public init(viewModel: AddTransactionViewModel = AddTransactionViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.App.sectionBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Transaction Type
                        TransactionTypeChips(selectedType: $viewModel.transactionType)
                            .padding(.top, 16)
                        
                        // Amount Section
                        AmountInputView(
                            amountText: $viewModel.amountText,
                            currency: $viewModel.currency,
                            exchangeRate: viewModel.exchangeRate,
                            onCurrencyTapped: { viewModel.showCurrencyPicker = true },
                            onEditExchangeRateTapped: nil
                        )
                        .padding(.horizontal)
                        
                        // Basic Info Section
                        VStack(spacing: 16) {
                            TextField("Title", text: $viewModel.title)
                                .font(.headline)
                                .padding()
                                .background(Color.App.cardBackground)
                                .cornerRadius(12)
                            
                            TextField("Description (Optional)", text: $viewModel.description, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.App.cardBackground)
                                .cornerRadius(12)
                            
                            DatePicker("Date & Time", selection: $viewModel.date)
                                .padding()
                                .background(Color.App.cardBackground)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Categories
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categories").sectionHeader()
                            
                            CategoryTagCloud(
                                selectedCategories: $viewModel.selectedCategories,
                                availableCategories: viewModel.availableCategories,
                                aiSuggestedCategories: viewModel.aiSuggestedCategories,
                                onAddTapped: {
                                    viewModel.addCategory("New Category")
                                },
                                onRemoveTapped: { cat in
                                    viewModel.removeCategory(cat)
                                }
                            )
                        }
                        .padding(.horizontal)
                        .cardStyle()
                        
                        // Payment Method / Split
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Payment Method").sectionHeader()
                                Spacer()
                                Toggle("Split", isOn: $viewModel.isSplitPayment)
                                    .labelsHidden()
                            }
                            
                            if viewModel.isSplitPayment {
                                SplitPaymentView(
                                    splits: $viewModel.paymentSplits,
                                    availableMethods: viewModel.availablePaymentMethods,
                                    totalAmount: viewModel.amount,
                                    onAddSplit: { viewModel.addPaymentSplit() },
                                    onRemoveSplit: { viewModel.removePaymentSplit(at: $0) }
                                )
                            } else {
                                Picker("Select Method", selection: $viewModel.selectedPaymentMethodId) {
                                    Text("Select Method").tag(String?.none)
                                    ForEach(viewModel.availablePaymentMethods) { method in
                                        Text(method.displayName).tag(String?.some(method.id))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .cardStyle()
                        
                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note").sectionHeader()
                            TextField("Add a note to remember...", text: $viewModel.note, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .cardStyle()
                        
                        // Location
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location").sectionHeader()
                            Button(action: { viewModel.showLocationPicker = true }) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text(viewModel.location?.placeName ?? "Add Location")
                                    Spacer()
                                    if viewModel.location != nil {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .foregroundColor(viewModel.location != nil ? .primary : .App.accentPrimary)
                        }
                        .padding(.horizontal)
                        .cardStyle()
                        
                        // Attachments
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Attachments").sectionHeader()
                            ImageAttachmentView(
                                attachments: $viewModel.attachedImages,
                                onCameraTapped: { viewModel.showCamera = true },
                                onGalleryTapped: { viewModel.showGallery = true },
                                onFilesTapped: { }
                            )
                        }
                        .padding(.horizontal)
                        .cardStyle()
                        
                        // Line Items
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Line Items").sectionHeader()
                            ItemsListView(
                                items: $viewModel.items,
                                totalAmount: viewModel.amount,
                                onAddItem: { viewModel.addItem() },
                                onRemoveItem: { viewModel.removeItem(at: $0) }
                            )
                        }
                        .padding(.horizontal)
                        .cardStyle()
                        
                        // Additional Options
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Additional Options").sectionHeader()
                            
                            Toggle("Recurring", isOn: $viewModel.isRecurring)
                            if viewModel.isRecurring {
                                Picker("Frequency", selection: $viewModel.recurringFrequency) {
                                    ForEach(RecurringFrequency.allCases) { freq in
                                        Text(freq.displayName).tag(freq)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            Toggle("Flag for review", isOn: $viewModel.isFlagged)
                            Toggle("Shared transaction", isOn: $viewModel.isShared)
                            Toggle("Expected transaction", isOn: $viewModel.isExpected)
                        }
                        .padding(.horizontal)
                        .cardStyle()
                        
                        Spacer().frame(height: 80)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                
                if viewModel.showAISuggestion {
                    VStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("✨ AI categorized as: \(viewModel.aiSuggestedCategories.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Button("Dismiss") { viewModel.showAISuggestion = false }
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Button("Accept") { viewModel.acceptAISuggestion() }
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.App.aiSuggestion)
                        .cornerRadius(12)
                        .padding()
                        .shadow(radius: 5)
                        .transition(.move(edge: .bottom))
                    }
                }
                
                if viewModel.isLoading || viewModel.isSaving {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .padding()
                        .background(Color.App.cardBackground)
                        .cornerRadius(8)
                }
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            do {
                                try await viewModel.save()
                                dismiss()
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .task {
                await viewModel.loadPaymentMethods()
                await viewModel.loadCategories()
            }
        }
    }
    
    private var navTitle: String {
        if case .edit = viewModel.mode {
            return "Edit Transaction"
        }
        return "New Transaction"
    }
}
