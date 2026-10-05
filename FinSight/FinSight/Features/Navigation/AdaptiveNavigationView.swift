import SwiftUI

public struct AdaptiveNavigationView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public init() {}
    
    public var body: some View {
        if horizontalSizeClass == .compact {
            MainTabView()
        } else {
            SidebarNavigationView()
        }
    }
}
