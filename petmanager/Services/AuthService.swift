//
//  AuthService.swift
//  petmanager
//

import Foundation
import Supabase

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws -> AuthSignUpResult
    func signOut() async throws
    func resetPasswordForEmail(_ email: String) async throws
    func signInWithApple(idToken: String, nonce: String) async throws
    func deleteAccount() async throws
    func resendVerificationEmail(email: String) async throws
}

struct AuthSignUpResult {
    let identities: [String]?
}

struct SupabaseAuthService: AuthServiceProtocol {
    func signIn(email: String, password: String) async throws {
        _ = try await SupabaseManager.shared.client.auth.signIn(
            email: email,
            password: password
        )
    }

    func signUp(email: String, password: String) async throws -> AuthSignUpResult {
        let response = try await SupabaseManager.shared.client.auth.signUp(
            email: email,
            password: password
        )
        return AuthSignUpResult(
            identities: response.user.identities?.map { $0.provider }
        )
    }

    func signOut() async throws {
        try await SupabaseManager.shared.client.auth.signOut()
    }

    func resetPasswordForEmail(_ email: String) async throws {
        try await SupabaseManager.shared.client.auth.resetPasswordForEmail(email)
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        _ = try await SupabaseManager.shared.client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
    }

    func deleteAccount() async throws {
        try await SupabaseManager.shared.client.rpc("delete_own_account").execute()
    }

    func resendVerificationEmail(email: String) async throws {
        try await SupabaseManager.shared.client.auth.resend(email: email, type: .signup)
    }
}
