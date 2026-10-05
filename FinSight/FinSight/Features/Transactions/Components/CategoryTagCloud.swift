import SwiftUI

public struct CategoryTagCloud: View {
    @Binding var selectedCategories: [String]
    var availableCategories: [String]
    var aiSuggestedCategories: [String]
    var onAddTapped: () -> Void
    var onRemoveTapped: (String) -> Void
    
    public init(selectedCategories: Binding<[String]>, availableCategories: [String], aiSuggestedCategories: [String], onAddTapped: @escaping () -> Void, onRemoveTapped: @escaping (String) -> Void) {
        self._selectedCategories = selectedCategories
        self.availableCategories = availableCategories
        self.aiSuggestedCategories = aiSuggestedCategories
        self.onAddTapped = onAddTapped
        self.onRemoveTapped = onRemoveTapped
    }
    
    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8, alignment: .leading) {
            
            ForEach(selectedCategories, id: \.self) { category in
                HStack {
                    Text(category)
                    Button(action: { onRemoveTapped(category) }) {
                        Image(systemName: "xmark")
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.App.accentPrimary)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            
            ForEach(aiSuggestedCategories.filter { !selectedCategories.contains($0) }, id: \.self) { category in
                Button(action: { selectedCategories.append(category) }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text(category)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.App.aiSuggestion.opacity(0.1))
                    .foregroundColor(Color.App.aiSuggestion)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.App.aiSuggestion, lineWidth: 1))
                }
            }
            
            ForEach(availableCategories.filter { !selectedCategories.contains($0) && !aiSuggestedCategories.contains($0) }, id: \.self) { category in
                Button(action: { selectedCategories.append(category) }) {
                    Text(category)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(.primary)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.5), lineWidth: 1))
                }
            }
            
            Button(action: onAddTapped) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(Color.App.accentPrimary)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.App.accentPrimary, style: StrokeStyle(dash: [4])))
            }
        }
    }
}
