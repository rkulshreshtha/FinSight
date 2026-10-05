import SwiftUI
import UniformTypeIdentifiers

public struct ExportView: View {
    @State private var viewModel: ExportViewModel
    @State private var showShareSheet = false
    
    public init(viewModel: ExportViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Date Range")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            PresetButton(title: "This Month", action: { viewModel.setPreset(months: 0) })
                            PresetButton(title: "Last Month", action: { viewModel.setPreset(months: 1) })
                            PresetButton(title: "Last 3 Months", action: { viewModel.setPreset(months: 3) })
                            PresetButton(title: "Last 6 Months", action: { viewModel.setPreset(months: 6) })
                            PresetButton(title: "Last 12 Months", action: { viewModel.setPreset(months: 12) })
                        }
                        .padding(.vertical, 4)
                    }
                    
                    DatePicker("From", selection: $viewModel.startDate, displayedComponents: .date)
                        .onChange(of: viewModel.startDate) { _ in Task { await viewModel.calculatePreview() } }
                    DatePicker("To", selection: $viewModel.endDate, displayedComponents: .date)
                        .onChange(of: viewModel.endDate) { _ in Task { await viewModel.calculatePreview() } }
                }
                
                Section(header: Text("Format")) {
                    ForEach(ExportViewModel.ExportFormat.allCases) { format in
                        Button(action: {
                            viewModel.selectedFormat = format
                            Task { await viewModel.calculatePreview() }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(format.title)
                                        .font(.headline)
                                        .foregroundColor(format == .json ? .blue : .primary)
                                    Text(format.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if viewModel.selectedFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section(header: Text("Options")) {
                    if viewModel.selectedFormat == .pdf {
                        Toggle("Include receipt images", isOn: $viewModel.includeImages)
                            .onChange(of: viewModel.includeImages) { _ in Task { await viewModel.calculatePreview() } }
                    }
                    Toggle("Include OCR text", isOn: $viewModel.includeOCRText)
                    Toggle("Include category corrections", isOn: $viewModel.includeCorrections)
                }
                
                Section(header: Text("Preview")) {
                    HStack {
                        Text("Transactions")
                        Spacer()
                        Text("\(viewModel.transactionCount)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Estimated Size")
                        Spacer()
                        Text("\(viewModel.estimatedSizeKB) KB")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.export()
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Exporting (\(Int(viewModel.exportProgress * 100))%)")
                                    .padding(.leading, 8)
                            } else {
                                Text("Export")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isExporting || viewModel.transactionCount == 0)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await viewModel.calculatePreview()
                }
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Export Error"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = nil
                    }
                )
            }
            .sheet(isPresented: .constant(viewModel.exportedFileURL != nil)) {
                if let url = viewModel.exportedFileURL {
                    ShareSheet(activityItems: [url])
                        .onDisappear {
                            viewModel.exportedFileURL = nil
                        }
                }
            }
        }
    }
}

struct PresetButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(16)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
