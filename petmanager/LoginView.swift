//
//  LoginView.swift
//  petmanager
//
//  Created by Sam Matthews on 08/02/2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var showingGuestWarning = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.4, blue: 0.8),
                    Color(red: 0.4, green: 0.6, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo and Title
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 140, height: 140)

                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)

                    VStack(spacing: 8) {
                        Text("Pet Pal")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Care for your furry friends")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                // Buttons
                VStack(spacing: 16) {
                    // Sign In Button
                    Button(action: {
                        // TODO: Implement sign in
                    }) {
                        Text("Sign In")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }

                    // Sign Up Button
                    Button(action: {
                        // TODO: Implement sign up
                    }) {
                        Text("Create Account")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.25))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.5), lineWidth: 1)
                            )
                    }

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 16)
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)

                    // Continue as Guest Button
                    Button(action: {
                        showingGuestWarning = true
                    }) {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                            Text("Continue as Guest")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .alert("Continue as Guest?", isPresented: $showingGuestWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Continue") {
                isLoggedIn = true
            }
        } message: {
            Text("Your data will only be stored locally on this device and will not be synced to the cloud. You can create an account later to enable cloud backup.")
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
