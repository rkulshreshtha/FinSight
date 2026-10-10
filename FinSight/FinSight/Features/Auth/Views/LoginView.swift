import SwiftUI

public struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.text.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("FinSight")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        
                        Text("Your AI-Powered Finance Companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        Button {
                            Task { await authViewModel.signInWithGoogle() }
                        } label: {
                            HStack {
                                // Placeholder for Google logo
                                Image(systemName: "g.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Sign in with Google")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        NavigationLink(destination: EmailAuthView()) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Sign in with Email")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
                
                if authViewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
            }
            .alert("Error", isPresented: .constant(authViewModel.errorMessage != nil), presenting: authViewModel.errorMessage) { _ in
                Button("OK") {
                    authViewModel.errorMessage = nil
                }
            } message: { errorMsg in
                Text(errorMsg)
            }
        }
    }
}
