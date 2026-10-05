import SwiftUI

public struct EmailAuthView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var isSignUp = false
    
    public init() {}
    
    public var body: some View {
        Form {
            Section(header: Text(isSignUp ? "Sign Up" : "Sign In")) {
                if isSignUp {
                    TextField("Display Name", text: Bindable(authViewModel).displayName)
                        .textContentType(.name)
                }
                
                TextField("Email", text: Bindable(authViewModel).email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                
                SecureField("Password", text: Bindable(authViewModel).password)
                    .textContentType(isSignUp ? .newPassword : .password)
            }
            
            Section {
                Button {
                    Task {
                        if isSignUp {
                            await authViewModel.signUpWithEmail()
                        } else {
                            await authViewModel.signInWithEmail()
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if authViewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
                .disabled(authViewModel.isLoading)
            }
            
            if !isSignUp {
                Section {
                    Button("Forgot Password?") {
                        Task {
                            await authViewModel.resetPassword()
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Section {
                Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                    isSignUp.toggle()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}
