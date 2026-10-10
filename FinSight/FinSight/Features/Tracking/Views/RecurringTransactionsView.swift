import SwiftUI

public struct RecurringTransactionsView: View {
    @State private var viewModel: RecurringViewModel
    
    @MainActor
    public init(viewModel: RecurringViewModel = RecurringViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        List {
            if !viewModel.aiSuggestions.isEmpty {
                Section(header: Text("AI Suggestions").foregroundColor(.App.aiSuggestion)) {
                    ForEach(viewModel.aiSuggestions) { rule in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.App.aiSuggestion)
                                Text(rule.title)
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(rule.confidence * 100))% Match")
                                    .font(.caption)
                                    .foregroundColor(.App.aiSuggestion)
                            }
                            
                            Text("Looks like you pay \(rule.amount.formattedAsCurrency()) \(rule.frequency.lowercased()).")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Button("Dismiss") {
                                    viewModel.dismissSuggestion(id: rule.id)
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button("Accept") {
                                    viewModel.acceptSuggestion(id: rule.id)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.App.aiSuggestion)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Section(header: Text("Active Rules")) {
                if viewModel.activeRules.isEmpty {
                    Text("No active recurring transactions.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.activeRules) { rule in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(rule.templateTitle)
                                    .font(.headline)
                                Text("Next: \(rule.nextOccurrence.relativeDateString)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(rule.templateAmount.formattedAsCurrency())
                                    .font(.subheadline.bold())
                                Text(rule.frequency.displayName)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteRule(id: rule.id)
                            }
                            Button("Pause") {
                                viewModel.pauseRule(id: rule.id)
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
        }
        .navigationTitle("Recurring")
        .task {
            await viewModel.loadRecurringRules()
        }
    }
}
