import Foundation
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import Observation

public enum AuthError: LocalizedError {
    case notConfigured
    case invalidCredentials
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .notConfigured: return "Authentication is not configured properly."
        case .invalidCredentials: return "Invalid credentials provided."
        case .unknown: return "An unknown error occurred."
        }
    }
}

@Observable
public final class FirebaseAuthService: AuthServiceProtocol {
    public var currentUser: UserProfile?
    public var isAuthenticated: Bool { currentUser != nil }
    
    public init() {}
    
    public func signInWithEmail(email: String, password: String) async throws -> UserProfile {
        let profile = UserProfile(id: UUID().uuidString, email: email, displayName: nil)
        self.currentUser = profile
        return profile
    }
    
    public func signUpWithEmail(email: String, password: String, displayName: String) async throws -> UserProfile {
        let profile = UserProfile(id: UUID().uuidString, email: email, displayName: displayName)
        self.currentUser = profile
        return profile
    }
    
    public func signInWithApple() async throws -> UserProfile {
        throw AuthError.notConfigured
    }
    
    public func signInWithGoogle() async throws -> UserProfile {
        throw AuthError.notConfigured
    }
    
    public func signOut() throws {
        self.currentUser = nil
    }
    
    public func resetPassword(email: String) async throws {}
    
    public func deleteAccount() async throws {
        self.currentUser = nil
    }
}
