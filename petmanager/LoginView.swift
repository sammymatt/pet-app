//
//  LoginView.swift
//  petmanager
//
//  Created by Sam Matthews on 08/02/2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showingGuestWarning = false
    @State private var showingForgotPassword = false
    @State private var isSubmitting = false
    @State private var validationError: String?
    @State private var showResendVerification = false
    @State private var lastEmail: String?

    var body: some View {
        ZStack {
            AppBackground(style: .login)

            VStack(spacing: 0) {
                Spacer()

                // Logo and Title
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }

                    Text("Pawfolio")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(spacing: 14) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .padding(14)
                        .background(.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .tint(.white)

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding(14)
                        .background(.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .tint(.white)

                    // Forgot password (only in sign-in mode)
                    if !isSignUp {
                        HStack {
                            Spacer()
                            Button {
                                showingForgotPassword = true
                            } label: {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }

                    // Error / success messages
                    if let error = validationError ?? authViewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))
                            .multilineTextAlignment(.center)
                    }

                    if let success = authViewModel.successMessage {
                        Text(success)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.7))
                            .multilineTextAlignment(.center)
                    }

                    if showResendVerification, let resendEmail = lastEmail {
                        Button {
                            Task {
                                await authViewModel.resendVerification(email: resendEmail)
                            }
                        } label: {
                            Text("Resend Verification Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .underline()
                        }
                    }

                    // Primary action button
                    Button {
                        handleSubmit()
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(Color(red: 0.5, green: 0.4, blue: 0.7))
                            }
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isSubmitting)
                    .opacity(isSubmitting ? 0.7 : 1)

                    // Toggle sign in / sign up
                    Button {
                        isSignUp.toggle()
                        clearMessages()
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Create one")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    HStack {
                        Rectangle().fill(.white.opacity(0.3)).frame(height: 1)
                        Text("or").font(.system(size: 14)).foregroundColor(.white.opacity(0.7)).padding(.horizontal, 12)
                        Rectangle().fill(.white.opacity(0.3)).frame(height: 1)
                    }
                    .padding(.vertical, 4)

                    Button {
                        Task {
                            await authViewModel.signInWithApple()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18))
                            Text("Sign in with Apple")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(14)
                    }

                    Button {
                        showingGuestWarning = true
                    } label: {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                            Text("Continue as Guest")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .alert("Continue as Guest?", isPresented: $showingGuestWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Continue") {
                authViewModel.isGuest = true
                authViewModel.isLoggedIn = true
                authViewModel.isLoading = false
            }
        } message: {
            Text("Your data will only be stored locally on this device and will not be synced to the cloud.")
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
                .environment(authViewModel)
        }
    }

    private func handleSubmit() {
        clearMessages()

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)

        guard !trimmedEmail.isEmpty else {
            validationError = "Please enter your email address."
            return
        }
        guard !trimmedPassword.isEmpty else {
            validationError = "Please enter your password."
            return
        }
        guard trimmedPassword.count >= 6 else {
            validationError = "Password must be at least 6 characters."
            return
        }

        isSubmitting = true
        lastEmail = trimmedEmail
        Task {
            if isSignUp {
                let needsConfirmation = await authViewModel.signUp(email: trimmedEmail, password: trimmedPassword)
                if needsConfirmation {
                    isSignUp = false
                    password = ""
                    showResendVerification = true
                }
            } else {
                await authViewModel.signIn(email: trimmedEmail, password: trimmedPassword)
                if authViewModel.errorMessage?.contains("confirm your account") == true {
                    showResendVerification = true
                }
            }
            isSubmitting = false
        }
    }

    private func clearMessages() {
        validationError = nil
        authViewModel.errorMessage = nil
        authViewModel.successMessage = nil
        showResendVerification = false
    }
}

// MARK: - Forgot Password

struct ForgotPasswordView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isSending = false
    @State private var validationError: String?

    var body: some View {
        NavigationView {
            ZStack {
                AppBackground(style: .login)

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    VStack(spacing: 8) {
                        Text("Reset Password")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Enter your email and we'll send you a link to reset your password.")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    VStack(spacing: 14) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .padding(14)
                            .background(.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .tint(.white)

                        if let error = validationError ?? authViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))
                                .multilineTextAlignment(.center)
                        }

                        if let success = authViewModel.successMessage {
                            Text(success)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.7))
                                .multilineTextAlignment(.center)
                        }

                        Button {
                            handleReset()
                        } label: {
                            HStack(spacing: 8) {
                                if isSending {
                                    ProgressView()
                                        .tint(Color(red: 0.5, green: 0.4, blue: 0.7))
                                }
                                Text("Send Reset Link")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white)
                            .cornerRadius(14)
                        }
                        .disabled(isSending)
                        .opacity(isSending ? 0.7 : 1)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func handleReset() {
        validationError = nil
        authViewModel.errorMessage = nil
        authViewModel.successMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else {
            validationError = "Please enter your email address."
            return
        }

        isSending = true
        Task {
            await authViewModel.resetPassword(email: trimmedEmail)
            isSending = false
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}
