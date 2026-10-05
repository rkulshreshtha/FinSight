import SwiftUI

public struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    public init() {}
    
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Skip") {
                    hasCompletedOnboarding = true
                }
                .padding()
                .foregroundColor(.blue)
            }
            
            TabView(selection: $currentPage) {
                OnboardingPage(
                    imageName: "doc.text.viewfinder",
                    title: "Smart Receipt Scanning",
                    description: "Easily scan and digitize your receipts using AI to extract transaction details."
                )
                .tag(0)
                
                OnboardingPage(
                    imageName: "cloud.offline",
                    title: "Works Offline",
                    description: "Log your expenses anytime, anywhere. Data syncs automatically when you're back online."
                )
                .tag(1)
                
                OnboardingPage(
                    imageName: "externaldrive.fill.badge.icloud",
                    title: "Your Data, Your Drive",
                    description: "Keep your receipts safe and accessible by linking to Google Drive."
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            if currentPage == 2 {
                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .transition(.opacity)
            } else {
                Spacer().frame(height: 80) // To keep layout stable
            }
        }
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
    }
}
