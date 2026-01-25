//
//  ProfileView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: PetViewModel
    @State private var showingAddPet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.7, blue: 0.4),
                        Color(red: 0.9, green: 0.5, blue: 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
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
                                    Group {
                                        if UIImage(named: pet.imageName) != nil {
                                            Image(pet.imageName)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            // Fallback for system images or missing assets
                                            ZStack {
                                                Color.white.opacity(0.8)
                                                Image(systemName: pet.imageName.isEmpty ? "pawprint.circle.fill" : pet.imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding(30)
                                                    .foregroundColor(.purple)
                                            }
                                        }
                                    }
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
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
                                            DetailBox(
                                                icon: "calendar",
                                                label: "Age",
                                                value: "\(pet.age) years",
                                                color: Color(red: 0.5, green: 0.7, blue: 1.0)
                                            )
                                            
                                            DetailBox(
                                                icon: "scalemass.fill",
                                                label: "Weight",
                                                value: String(format: "%.1f kg", pet.weight),
                                                color: Color(red: 0.4, green: 0.8, blue: 0.6)
                                            )
                                        }
                                        
                                        HStack(spacing: 12) {
                                            DetailBox(
                                                icon: "pawprint.fill",
                                                label: "Gender",
                                                value: pet.gender,
                                                color: Color(red: 1.0, green: 0.6, blue: 0.8)
                                            )
                                            
                                            DetailBox(
                                                icon: "paintpalette.fill",
                                                label: "Color",
                                                value: pet.color ?? "N/A",
                                                color: Color(red: 1.0, green: 0.7, blue: 0.3)
                                            )
                                        }
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
        }
    }
}

struct PetAvatarButton: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Group {
                    if UIImage(named: pet.imageName) != nil {
                        Image(pet.imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color.white
                            Image(systemName: pet.imageName.isEmpty ? "pawprint.circle.fill" : pet.imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                                .foregroundColor(.purple)
                        }
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
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
