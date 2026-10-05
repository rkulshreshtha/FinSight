import SwiftUI

public struct ShareExtensionView: View {
    @State private var viewModel = ShareExtensionViewModel()
    public var extensionContext: NSExtensionContext?
    
    public init(viewModel: ShareExtensionViewModel = ShareExtensionViewModel(), extensionContext: NSExtensionContext? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.extensionContext = extensionContext
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("FinSight")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            ScrollView {
                VStack(spacing: 16) {
                    // Content Preview
                    if let content = viewModel.sharedContent {
                        switch content {
                        case .image(let data):
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .cornerRadius(8)
                            }
                        case .text(let text):
                            Text(text)
                                .font(.caption)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        case .url(let url):
                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if viewModel.isProcessing {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text(viewModel.processingStatus)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.subheadline)
                            Text("Please enter details manually")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // Form
                    if !viewModel.isProcessing {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Amount")
                                Spacer()
                                TextField("0.00", text: $viewModel.extractedAmount)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                            }
                            Divider()
                            
                            HStack {
                                Text("Title")
                                Spacer()
                                TextField("Enter title", text: $viewModel.extractedTitle)
                                    .multilineTextAlignment(.trailing)
                            }
                            Divider()
                            
                            Picker("Type", selection: $viewModel.extractedType) {
                                Text("Expense").tag("expense")
                                Text("Income").tag("income")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            DatePicker("Date", selection: $viewModel.extractedDate, displayedComponents: [.date, .hourAndMinute])
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Actions
                    HStack(spacing: 16) {
                        Button(action: {
                            Task {
                                _ = await viewModel.saveDraft()
                            }
                        }) {
                            Text("Save Draft")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            Task {
                                let success = await viewModel.saveAndClose()
                                if success {
                                    extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                                }
                            }
                        }) {
                            if viewModel.isSaving {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text("Save & Close")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(viewModel.isSaving)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
    }
}
