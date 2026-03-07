//
//  SettingsView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var notificationsEnabled = true
    @State private var showingPrivacyNotice = false
    @State private var showingHelpSupport = false
    @State private var showingFeatureRequest = false
    @State private var showingLogoutConfirmation = false
    @State private var showingDeleteAccountConfirmation = false
    @State private var showingGuestSignUp = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                AppBackground(style: .settings)
                
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

                            // Theme Section
                            SettingsSection(title: "Theme") {
                                SettingsToggle(
                                    icon: "moon.fill",
                                    title: "Dark Mode",
                                    isOn: $isDarkMode,
                                    color: Color(red: 0.6, green: 0.5, blue: 1.0)
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
                                    showingHelpSupport = true
                                }

                                SettingsButton(
                                    icon: "lightbulb.fill",
                                    title: "Feature Requests",
                                    color: Color(red: 1.0, green: 0.8, blue: 0.3)
                                ) {
                                    showingFeatureRequest = true
                                }
                            }
                            
                            // Account Section
                            SettingsSection(title: "Account") {
                                if authViewModel.isGuest {
                                    SettingsButton(
                                        icon: "person.crop.circle.badge.plus",
                                        title: "Create Account",
                                        color: Color(red: 0.4, green: 0.7, blue: 1.0)
                                    ) {
                                        showingGuestSignUp = true
                                    }

                                    SettingsButton(
                                        icon: "arrow.right.square.fill",
                                        title: "Back to Login",
                                        color: Color(red: 1.0, green: 0.4, blue: 0.4)
                                    ) {
                                        showingLogoutConfirmation = true
                                    }
                                } else {
                                    SettingsButton(
                                        icon: "arrow.right.square.fill",
                                        title: "Log Out",
                                        color: Color(red: 1.0, green: 0.4, blue: 0.4)
                                    ) {
                                        showingLogoutConfirmation = true
                                    }

                                    SettingsButton(
                                        icon: "trash.fill",
                                        title: "Delete Account",
                                        color: Color(red: 1.0, green: 0.3, blue: 0.3)
                                    ) {
                                        showingDeleteAccountConfirmation = true
                                    }
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
            .sheet(isPresented: $showingHelpSupport) {
                HelpSupportView()
            }
            .sheet(isPresented: $showingFeatureRequest) {
                FeatureRequestView()
            }
            .alert(
                authViewModel.isGuest ? "Leave Guest Mode?" : "Log Out?",
                isPresented: $showingLogoutConfirmation
            ) {
                Button("Cancel", role: .cancel) { }
                Button(authViewModel.isGuest ? "Leave" : "Log Out", role: .destructive) {
                    if authViewModel.isGuest {
                        authViewModel.isGuest = false
                        authViewModel.isLoggedIn = false
                    } else {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                }
            } message: {
                Text(authViewModel.isGuest
                     ? "Any data stored locally will remain on this device. You'll return to the login screen."
                     : "Are you sure you want to log out?")
            }
            .alert("Delete Account?", isPresented: $showingDeleteAccountConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await authViewModel.deleteAccount()
                    }
                }
            } message: {
                Text("This will permanently delete your account and all associated data. This action cannot be undone.")
            }
            .sheet(isPresented: $showingGuestSignUp) {
                GuestSignUpView()
                    .environment(authViewModel)
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
                    
                    Text("Your privacy is important to us. This privacy notice explains how Pawfolio collects, uses, and protects your personal information.")
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

struct HelpSupportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var showingSubmitted = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Help & Support")
                            .font(.system(size: 28, weight: .bold))

                        Text("Have a question or need help? Check our FAQs below or send us a message.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }

                    // FAQs Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Frequently Asked Questions")
                            .font(.system(size: 20, weight: .semibold))

                        FAQItem(
                            question: "How do I add a new pet?",
                            answer: "Go to the Pets tab and tap the \"+\" button. Fill in your pet's details including name, species, breed, and birthday, then tap Save."
                        )

                        FAQItem(
                            question: "How do I schedule an appointment?",
                            answer: "Navigate to the Health tab, select Appointments, and tap \"Add Appointment\". Enter the vet name, date, and any notes for the visit."
                        )

                        FAQItem(
                            question: "Can I track my pet's weight over time?",
                            answer: "Yes! Go to the Health tab and select Weight Tracking. You can log weight entries and view your pet's weight history over time."
                        )

                        FAQItem(
                            question: "How do I update my pet's information?",
                            answer: "Go to the Pets tab, select your pet, and tap the edit button. You can update their name, breed, weight, and other details."
                        )

                        FAQItem(
                            question: "Is my data backed up?",
                            answer: "Your data is stored on our servers and synced whenever you use the app. Make sure you have an active internet connection for the latest updates."
                        )

                        FAQItem(
                            question: "How do I enable notifications?",
                            answer: "Go to Settings and toggle Notifications on. You'll receive reminders for upcoming appointments and health milestones."
                        )
                    }

                    Divider()
                        .padding(.vertical, 8)

                    // Contact Form Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Us")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Can't find what you're looking for? Send us a message and we'll get back to you.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        VStack(spacing: 14) {
                            FormField(label: "Name", text: $name, placeholder: "Your name")
                            FormField(label: "Email", text: $email, placeholder: "your@email.com", keyboardType: .emailAddress)
                            FormField(label: "Subject", text: $subject, placeholder: "What do you need help with?")

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Message")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)

                                TextEditor(text: $message)
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        }

                        Button(action: {
                            showingSubmitted = true
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Submit")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(formIsValid ? Color(red: 0.5, green: 0.4, blue: 0.9) : Color.gray.opacity(0.4))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(!formIsValid)
                    }
                }
                .padding(20)
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Message Sent", isPresented: $showingSubmitted) {
                Button("OK") {
                    name = ""
                    email = ""
                    subject = ""
                    message = ""
                }
            } message: {
                Text("Thanks for reaching out! We'll get back to you as soon as possible.")
            }
        }
    }

    private var formIsValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
            }

            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

struct FeatureRequestView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var featureTitle = ""
    @State private var featureDescription = ""
    @State private var selectedCategory = "General"
    @State private var showingSubmitted = false
    @State private var featureRequests: [FeatureRequest] = []
    @State private var isLoading = true
    @State private var isSubmitting = false
    @State private var cancellables = Set<AnyCancellable>()

    let categories = ["General", "Pet Profiles", "Health Tracking", "Appointments", "Notifications", "UI/Design"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feature Requests")
                            .font(.system(size: 28, weight: .bold))

                        Text("Have an idea to make Pawfolio better? We'd love to hear it!")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }

                    // Popular Requests Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Popular Requests")
                            .font(.system(size: 20, weight: .semibold))

                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding(.vertical, 20)
                                Spacer()
                            }
                        } else if featureRequests.isEmpty {
                            Text("No feature requests yet. Be the first to submit one!")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(featureRequests) { request in
                                FeatureRequestCard(featureRequest: request, onVoted: {
                                    loadFeatureRequests()
                                })
                            }
                        }
                    }

                    Divider()
                        .padding(.vertical, 8)

                    // Submit a Request Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Submit a Request")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Don't see your idea above? Submit a new feature request.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        VStack(spacing: 14) {
                            FormField(label: "Feature Title", text: $featureTitle, placeholder: "A short title for your idea")

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Category")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(categories, id: \.self) { category in
                                            Button(action: {
                                                selectedCategory = category
                                            }) {
                                                Text(category)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        Capsule()
                                                            .fill(selectedCategory == category
                                                                  ? Color(red: 0.5, green: 0.4, blue: 0.9)
                                                                  : Color(.systemGray5))
                                                    )
                                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                            }
                                        }
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Description")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)

                                TextEditor(text: $featureDescription)
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        }

                        Button(action: {
                            submitRequest()
                        }) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text("Submit Request")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(requestFormIsValid && !isSubmitting ? Color(red: 0.5, green: 0.4, blue: 0.9) : Color.gray.opacity(0.4))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(!requestFormIsValid || isSubmitting)
                    }
                }
                .padding(20)
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Request Submitted", isPresented: $showingSubmitted) {
                Button("OK") {
                    featureTitle = ""
                    featureDescription = ""
                    selectedCategory = "General"
                }
            } message: {
                Text("Thanks for your suggestion! We review every request and use your feedback to shape future updates.")
            }
            .onAppear {
                loadFeatureRequests()
            }
        }
    }

    private var requestFormIsValid: Bool {
        !featureTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !featureDescription.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func loadFeatureRequests() {
        isLoading = true
        PetService.shared.fetchFeatureRequests()
            .sink(receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    print("Failed to fetch feature requests: \(error)")
                }
            }, receiveValue: { requests in
                featureRequests = requests
            })
            .store(in: &cancellables)
    }

    private func submitRequest() {
        let createRequest = FeatureRequestCreate(
            title: featureTitle.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            description: featureDescription.trimmingCharacters(in: .whitespaces)
        )
        isSubmitting = true
        PetService.shared.createFeatureRequest(request: createRequest)
            .sink(receiveCompletion: { completion in
                isSubmitting = false
                if case .failure(let error) = completion {
                    print("Failed to submit feature request: \(error)")
                } else {
                    showingSubmitted = true
                    loadFeatureRequests()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

struct FeatureRequestCard: View {
    let featureRequest: FeatureRequest
    var onVoted: (() -> Void)?
    @State private var hasVoted = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(featureRequest.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                if featureRequest.isImplemented {
                    Text("Implemented")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.green.opacity(0.15)))
                        .foregroundColor(.green)
                }

                Text(featureRequest.category)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.15)))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.9))
            }

            if let description = featureRequest.description {
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Button(action: {
                    guard !hasVoted else { return }
                    hasVoted = true
                    PetService.shared.voteFeatureRequest(id: featureRequest.id)
                        .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                hasVoted = false
                                print("Failed to vote: \(error)")
                            } else {
                                onVoted?()
                            }
                        }, receiveValue: { _ in })
                        .store(in: &cancellables)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: hasVoted ? "arrow.up.circle.fill" : "arrow.up.circle")
                            .font(.system(size: 16))
                        Text("\(featureRequest.votes + (hasVoted ? 1 : 0))")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(hasVoted ? Color(red: 0.5, green: 0.4, blue: 0.9) : .gray)
                }
                .disabled(hasVoted)

                Spacer()
            }
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Guest Sign Up

struct GuestSignUpView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isSending = false
    @State private var validationError: String?

    var body: some View {
        NavigationView {
            ZStack {
                AppBackground(style: .settings)

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "icloud.and.arrow.up.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Sign up to back up your data to the cloud and sync across devices.")
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

                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
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
                            handleSignUp()
                        } label: {
                            HStack(spacing: 8) {
                                if isSending {
                                    ProgressView()
                                        .tint(Color(red: 0.5, green: 0.4, blue: 0.7))
                                }
                                Text("Create Account & Sync")
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

    private func handleSignUp() {
        validationError = nil
        authViewModel.errorMessage = nil
        authViewModel.successMessage = nil

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

        isSending = true
        Task {
            let needsConfirmation = await authViewModel.signUp(email: trimmedEmail, password: trimmedPassword)
            if needsConfirmation {
                password = ""
            }
            isSending = false
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthViewModel())
}
