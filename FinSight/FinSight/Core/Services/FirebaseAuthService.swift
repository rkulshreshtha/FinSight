import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Observation
#if os(iOS)
import UIKit
#endif

public enum AuthError: LocalizedError {
    case notConfigured
    case invalidCredentials(String)
    case cancelled
    case noRootViewController
    case networkError(String)
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Authentication is not configured properly."
        case .invalidCredentials(let message):
            return message.isEmpty ? "Invalid credentials provided." : message
        case .cancelled:
            return "Sign-in was cancelled."
        case .noRootViewController:
            return "Unable to find the presenting window scene."
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown(let message):
            return message.isEmpty ? "An unknown authentication error occurred." : message
        }
    }
}

@Observable
public final class FirebaseAuthService: AuthServiceProtocol {
    public var currentUser: UserProfile?
    public var isAuthenticated: Bool { currentUser != nil }
    
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    
    public init() {
        // Restore existing Firebase session if available
        if let user = Auth.auth().currentUser {
            self.currentUser = UserProfile(
                id: user.uid,
                email: user.email ?? "",
                displayName: user.displayName
            )
        }
        
        // Listen to auth state changes
        self.authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.currentUser = UserProfile(
                    id: user.uid,
                    email: user.email ?? "",
                    displayName: user.displayName
                )
            } else {
                self.currentUser = nil
            }
        }
    }
    
    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    public func signInWithEmail(email: String, password: String) async throws -> UserProfile {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let profile = UserProfile(
                id: result.user.uid,
                email: result.user.email ?? email,
                displayName: result.user.displayName
            )
            self.currentUser = profile
            return profile
        } catch let err as NSError {
            throw AuthError.invalidCredentials(err.localizedDescription)
        }
    }
    
    public func signUpWithEmail(email: String, password: String, displayName: String) async throws -> UserProfile {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            if !displayName.isEmpty {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
            let profile = UserProfile(
                id: result.user.uid,
                email: result.user.email ?? email,
                displayName: displayName.isEmpty ? nil : displayName
            )
            self.currentUser = profile
            return profile
        } catch let err as NSError {
            throw AuthError.invalidCredentials(err.localizedDescription)
        }
    }
    
    @MainActor
    public func signInWithGoogle() async throws -> UserProfile {
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        do {
            if GIDSignIn.sharedInstance.configuration == nil {
                let clientID = FirebaseApp.app()?.options.clientID ?? "135503220017-ot4dn83df77efg6mp8nha4kje42fap7u.apps.googleusercontent.com"
                GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            }
            
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            guard let idToken = signInResult.user.idToken?.tokenString else {
                throw AuthError.unknown("Missing Google ID Token")
            }
            let accessToken = signInResult.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let authResult = try await Auth.auth().signIn(with: credential)
            let profile = UserProfile(
                id: authResult.user.uid,
                email: authResult.user.email ?? (signInResult.user.profile?.email ?? ""),
                displayName: authResult.user.displayName ?? signInResult.user.profile?.name
            )
            self.currentUser = profile
            return profile
        } catch let err as NSError {
            if err.domain == kGIDSignInErrorDomain && err.code == -5 {
                throw AuthError.cancelled
            }
            throw AuthError.unknown(err.localizedDescription)
        }
        #else
        throw AuthError.notConfigured
        #endif
    }
    
    public func signOut() throws {
        try Auth.auth().signOut()
        #if os(iOS)
        GIDSignIn.sharedInstance.signOut()
        #endif
        self.currentUser = nil
    }
    
    public func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    public func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
        self.currentUser = nil
    }
}
