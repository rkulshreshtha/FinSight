import SwiftUI

public struct FilterChipsView: View {
    @Bindable var viewModel: TransactionListViewModel
    
    public init(viewModel: TransactionListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    viewModel.showFilterSheet = true
                } label: {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        if viewModel.activeFilterCount > 0 {
                            Text("\(viewModel.activeFilterCount)")
                                .font(.caption.weight(.bold))
                                .padding(4)
                                .background(Color.white)
                                .clipShape(Circle())
                                .foregroundColor(Color.App.accentPrimary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.activeFilterCount > 0 ? Color.App.accentPrimary : Color(.systemGray5))
                    .foregroundColor(viewModel.activeFilterCount > 0 ? .white : .primary)
                    .cornerRadius(16)
                }
                
                filterChip(label: "Date", isActive: viewModel.filter.dateRange != nil) {
                    viewModel.filter.dateRange = nil
                    viewModel.applyFilter()
                }
                
                filterChip(label: "Flagged", isActive: viewModel.filter.isFlagged == true) {
                    viewModel.filter.isFlagged = nil
                    viewModel.applyFilter()
                }
                
                filterChip(label: "Type", isActive: viewModel.filter.types?.isEmpty == false) {
                    viewModel.filter.types = nil
                    viewModel.applyFilter()
                }
                
                filterChip(label: "Sort: \(viewModel.sortOrder.rawValue)", isActive: viewModel.sortOrder != .dateDesc) {
                    viewModel.sortOrder = .dateDesc
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func filterChip(label: String, isActive: Bool, onClear: @escaping () -> Void) -> some View {
        Button {
            viewModel.showFilterSheet = true
        } label: {
            HStack {
                Text(label)
                if isActive {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .onTapGesture {
                            onClear()
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? Color.App.accentPrimary : Color.clear)
            .foregroundColor(isActive ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isActive ? Color.clear : Color(.systemGray3), lineWidth: 1)
            )
            .cornerRadius(16)
        }
    }
}
