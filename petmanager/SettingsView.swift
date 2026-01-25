//
//  SettingsView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var showingPrivacyNotice = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.5, green: 0.4, blue: 0.9),
                        Color(red: 0.7, green: 0.5, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text("Settings")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        // Settings Sections
                        VStack(spacing: 20) {
                            // Preferences Section
                            SettingsSection(title: "Preferences") {
                                SettingsToggle(
                                    icon: "bell.fill",
                                    title: "Notifications",
                                    isOn: $notificationsEnabled,
                                    color: Color(red: 1.0, green: 0.6, blue: 0.4)
                                )
                            }
                            
                            // Information Section
                            SettingsSection(title: "Information") {
                                SettingsButton(
                                    icon: "shield.fill",
                                    title: "Privacy Notice",
                                    color: Color(red: 0.5, green: 0.7, blue: 1.0)
                                ) {
                                    showingPrivacyNotice = true
                                }
                                
                                SettingsButton(
                                    icon: "doc.text.fill",
                                    title: "Terms of Service",
                                    color: Color(red: 0.4, green: 0.8, blue: 0.6)
                                ) {
                                    // TODO: Show terms of service
                                }
                                
                                SettingsButton(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & Support",
                                    color: Color(red: 0.9, green: 0.7, blue: 0.4)
                                ) {
                                    // TODO: Show help
                                }
                            }
                            
                            // Account Section
                            SettingsSection(title: "Account") {
                                SettingsButton(
                                    icon: "arrow.right.square.fill",
                                    title: "Log Out",
                                    color: Color(red: 1.0, green: 0.4, blue: 0.4)
                                ) {
                                    // TODO: Implement logout
                                }
                            }
                            
                            // Version Info
                            Text("Version \(appVersion)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPrivacyNotice) {
                PrivacyNoticeView()
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 20)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct PrivacyNoticeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Notice")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom, 8)
                    
                    Text("Last updated: January 25, 2026")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Your privacy is important to us. This privacy notice explains how Pet Pal collects, uses, and protects your personal information.")
                        .font(.system(size: 16))
                        .padding(.top, 8)
                    
                    Text("Information We Collect")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 16)
                    
                    Text("We collect information about your pets including their name, species, age, weight, and health records to provide you with personalized pet care management.")
                        .font(.system(size: 16))
                    
                    Text("How We Use Your Information")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 16)
                    
                    Text("Your information is used solely to provide and improve our pet management services. We do not share your personal information with third parties without your consent.")
                        .font(.system(size: 16))
                    
                    Text("Data Security")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 16)
                    
                    Text("We implement appropriate security measures to protect your information from unauthorized access, alteration, or disclosure.")
                        .font(.system(size: 16))
                }
                .padding(20)
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    SettingsView()
}
