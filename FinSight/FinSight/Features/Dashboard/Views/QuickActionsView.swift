import SwiftUI

public struct QuickActionsView: View {
    var viewModel: DashboardViewModel
    
    public var body: some View {
        HStack {
            QuickActionButton(icon: "flag.fill", label: "Flagged", badge: viewModel.flaggedCount, color: .orange)
            Spacer()
            QuickActionButton(icon: "calendar", label: "Expected", badge: viewModel.expectedCount, color: .blue)
            Spacer()
            QuickActionButton(icon: "bell.fill", label: "Reminders", badge: viewModel.reminderCount, color: .purple)
            Spacer()
            QuickActionButton(icon: "square.and.arrow.up", label: "Export", badge: 0, color: .gray)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let badge: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 5, y: -5)
                }
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
