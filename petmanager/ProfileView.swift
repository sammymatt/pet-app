//
//  ProfileView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var viewModel: PetViewModel
    @State private var showingAddPet = false
    @State private var showingDeleteAlert = false
    @State private var petToDelete: Pet?
    @State private var showingEditPet = false
    @State private var showingWeightTracking = false
    @State private var showingAgeView = false
    @State private var showingGenderView = false
    @State private var showingColorView = false
    @State private var latestWeight: Double?
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                AppBackground(style: .profile)
                
                VStack(spacing: 0) {
                    // Pet Switcher Header
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.pets) { pet in
                                PetAvatarButton(pet: pet, isSelected: viewModel.selectedPet?.id == pet.id) {
                                    withAnimation {
                                        viewModel.selectPet(pet)
                                    }
                                }
                            }
                            
                            // Add Pet Button
                            Button(action: {
                                showingAddPet = true
                            }) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "plus")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Add")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .background(Color.black.opacity(0.1))
                    
                    if let pet = viewModel.selectedPet {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Profile Header
                                VStack(spacing: 16) {
                                    // Profile Image
                                    PetAvatarView(pet: pet, size: 140)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.white, .white.opacity(0.6)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 4
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                                    
                                    // Pet Name
                                    Text(pet.name)
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    // Breed
                                    Text(pet.breed)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(.top, 20)
                                
                                // Info Cards
                                VStack(spacing: 16) {
                                    // Description Card
                                    if !pet.description.isEmpty {
                                        InfoCard(
                                            title: "About",
                                            content: pet.description,
                                            icon: "heart.fill",
                                            iconColor: Color(red: 1.0, green: 0.4, blue: 0.5)
                                        )
                                    }
                                    
                                    // Details Grid
                                    VStack(spacing: 12) {
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                showingAgeView = true
                                            }) {
                                                DetailBox(
                                                    icon: "calendar",
                                                    label: "Age",
                                                    value: "\(pet.age) years",
                                                    color: Color(red: 0.5, green: 0.7, blue: 1.0)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())

                                            Button(action: {
                                                showingWeightTracking = true
                                            }) {
                                                DetailBox(
                                                    icon: "scalemass.fill",
                                                    label: "Weight",
                                                    value: latestWeight.map { String(format: "%.1f kg", $0) } ?? "--",
                                                    color: Color(red: 0.4, green: 0.8, blue: 0.6)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }

                                        HStack(spacing: 12) {
                                            Button(action: {
                                                showingGenderView = true
                                            }) {
                                                DetailBox(
                                                    icon: "pawprint.fill",
                                                    label: "Gender",
                                                    value: pet.gender,
                                                    color: Color(red: 1.0, green: 0.6, blue: 0.8)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())

                                            Button(action: {
                                                showingColorView = true
                                            }) {
                                                DetailBox(
                                                    icon: "paintpalette.fill",
                                                    label: "Color",
                                                    value: pet.color ?? "N/A",
                                                    color: Color(red: 1.0, green: 0.7, blue: 0.3)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Edit and Delete Buttons
                                HStack(spacing: 12) {
                                    Button(action: {
                                        showingEditPet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "pencil")
                                            Text("Edit")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.8))
                                        )
                                    }
                                    
                                    Button(action: {
                                        petToDelete = pet
                                        showingDeleteAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Delete")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.8))
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            Text("No pets added yet")
                                .foregroundColor(.white)
                                .font(.title2)
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
            .sheet(isPresented: $showingEditPet) {
                if let pet = viewModel.selectedPet {
                    AddPetView(petToEdit: pet)
                }
            }
            .sheet(isPresented: $showingWeightTracking, onDismiss: {
                if let pet = viewModel.selectedPet {
                    fetchLatestWeight(for: pet)
                }
            }) {
                if let pet = viewModel.selectedPet {
                    WeightTrackingView(pet: pet)
                }
            }
            .sheet(isPresented: $showingAgeView) {
                if let pet = viewModel.selectedPet {
                    NavigationView {
                        AgeView(pet: pet)
                            .environmentObject(viewModel)
                    }
                }
            }
            .sheet(isPresented: $showingGenderView) {
                if let pet = viewModel.selectedPet {
                    NavigationView {
                        GenderView(pet: pet)
                            .environmentObject(viewModel)
                    }
                }
            }
            .sheet(isPresented: $showingColorView) {
                if let pet = viewModel.selectedPet {
                    NavigationView {
                        ColorView(pet: pet)
                            .environmentObject(viewModel)
                    }
                }
            }
            .alert("Delete Pet", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let pet = petToDelete {
                        viewModel.deletePet(pet)
                    }
                }
            } message: {
                Text("Are you sure you want to remove this pet?")
            }
        }
        .onAppear {
            #if DEBUG
            // Temporarily fetch pets for user ID 1
            if viewModel.pets.isEmpty {
                viewModel.fetchPets(forUserId: 1)
            }
            #endif
            if let pet = viewModel.selectedPet {
                fetchLatestWeight(for: pet)
            }
        }
        .onChange(of: viewModel.selectedPet) { _, newPet in
            if let pet = newPet {
                fetchLatestWeight(for: pet)
            } else {
                latestWeight = nil
            }
        }
    }

    private func fetchLatestWeight(for pet: Pet) {
        PetService.shared.fetchWeights(forPetId: pet.id)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { weights in
                    latestWeight = weights.first?.weight
                }
            )
            .store(in: &cancellables)
    }
}

struct PetAvatarButton: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                PetAvatarView(pet: pet, size: 60)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1)
                )
                .shadow(radius: isSelected ? 4 : 0)
                
                Text(pet.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
    }
}

struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

struct DetailBox: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView()
}
