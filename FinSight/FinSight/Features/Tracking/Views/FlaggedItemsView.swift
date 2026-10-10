import SwiftUI

public struct FlaggedItemsView: View {
    @State private var viewModel: TrackingViewModel
    
    @MainActor
    public init(viewModel: TrackingViewModel = TrackingViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        List {
            if viewModel.flaggedTransactions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("No flagged items. You're all clear! ✅")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.flaggedTransactions) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.App.flagged)
                                Text(transaction.title)
                                    .font(.headline)
                            }
                            Text(transaction.flagNote ?? "Flagged item")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(transaction.amount.formattedAsCurrency())
                                .font(.subheadline.bold())
                            Button("Resolve") {
                                viewModel.resolveFlag(id: transaction.id)
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Unflag") {
                            viewModel.resolveFlag(id: transaction.id)
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .navigationTitle("Flagged Items")
    }
}
