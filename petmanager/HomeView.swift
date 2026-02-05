//
//  HomeView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: PetViewModel
    @State private var currentPetIndex = 0
    @State private var timer: Timer?

    var currentPet: Pet? {
        guard !viewModel.pets.isEmpty else { return nil }
        return viewModel.pets[currentPetIndex % viewModel.pets.count]
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.6, blue: 0.95),
                        Color(red: 0.6, green: 0.4, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text("Pet Pal")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Keep your furry friends healthy & happy")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Quick Stats Cards
                        VStack(spacing: 16) {
                            // Upcoming Reminders Card
                            QuickStatCard(
                                icon: "bell.fill",
                                title: "Upcoming Reminders",
                                value: "3",
                                subtitle: "Next: Vaccine on Feb 15",
                                color: Color(red: 1.0, green: 0.6, blue: 0.4)
                            )
                            
                            // Weight Tracking Card - cycles through pets
                            if let pet = currentPet {
                                QuickStatCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "\(pet.name)'s Weight",
                                    value: String(format: "%.1f kg", pet.weight),
                                    subtitle: viewModel.pets.count > 1 ? "Showing \(currentPetIndex % viewModel.pets.count + 1) of \(viewModel.pets.count) pets" : pet.breed,
                                    color: Color(red: 0.4, green: 0.8, blue: 0.6)
                                )
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.8)),
                                    removal: .opacity.animation(.easeInOut(duration: 0.8))
                                ))
                                .id(pet.id)
                            } else {
                                QuickStatCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Weight Tracking",
                                    value: "-- kg",
                                    subtitle: "No pets added yet",
                                    color: Color(red: 0.4, green: 0.8, blue: 0.6)
                                )
                            }
                            
                            // Reminders Card - cycles through pets
                            if let pet = currentPet {
                                NavigationLink(destination: AppointmentsView(petId: pet.id)) {
                                    QuickStatCard(
                                        icon: "calendar.badge.clock",
                                        title: "\(pet.name)'s Reminders",
                                        value: "View",
                                        subtitle: viewModel.pets.count > 1 ? "Tap to see appointments" : "Tap to see \(pet.name)'s appointments",
                                        color: Color(red: 0.9, green: 0.5, blue: 0.7)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.8)),
                                    removal: .opacity.animation(.easeInOut(duration: 0.8))
                                ))
                                .id("reminder-\(pet.id)")
                            } else {
                                QuickStatCard(
                                    icon: "calendar.badge.clock",
                                    title: "Reminders",
                                    value: "--",
                                    subtitle: "No pets added yet",
                                    color: Color(red: 0.9, green: 0.5, blue: 0.7)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Version Number
                        Text("v1.0.0")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.bottom, 10)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Fetch pets if not already loaded
                if viewModel.pets.isEmpty {
                    viewModel.fetchPets(forUserId: 1)
                }
                // Start cycling timer if multiple pets
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .onChange(of: viewModel.pets.count) { _, newCount in
                if newCount > 1 {
                    startTimer()
                } else {
                    stopTimer()
                }
            }
        }
    }

    private func startTimer() {
        stopTimer()
        guard viewModel.pets.count > 1 else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                currentPetIndex += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(PetViewModel())
}
