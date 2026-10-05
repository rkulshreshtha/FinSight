import SwiftUI

public extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.App.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func sectionHeader() -> some View {
        self
            .font(.App.headline)
            .foregroundColor(.secondary)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func shimmer() -> some View {
        self
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .white.opacity(0.3), .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
            )
            .mask(self)
    }
    
    func badgeOverlay(count: Int) -> some View {
        self.overlay(
            ZStack {
                if count > 0 {
                    Circle()
                        .fill(Color.App.danger)
                        .frame(width: 20, height: 20)
                    Text("\(count)")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                }
            }
            .offset(x: 10, y: -10),
            alignment: .topTrailing
        )
    }
    
    @ViewBuilder
    func adaptiveNavigation() -> some View {
        #if os(macOS)
        NavigationSplitView {
            self
        } detail: {
            Text("Select an item")
        }
        #else
        NavigationStack {
            self
        }
        #endif
    }
    
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}
