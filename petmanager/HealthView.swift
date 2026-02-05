//
//  HealthView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct HealthView: View {
    @EnvironmentObject var viewModel: PetViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.8, blue: 0.6),
                        Color(red: 0.3, green: 0.6, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Pet Selector
                    if !viewModel.pets.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.pets) { pet in
                                    PetSelectorChip(
                                        pet: pet,
                                        isSelected: viewModel.selectedPet?.id == pet.id
                                    ) {
                                        withAnimation {
                                            viewModel.selectPet(pet)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .background(Color.black.opacity(0.1))
                    }

                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 12) {
                                Image(systemName: "cross.case.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                                Text("Pet Health")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                if let pet = viewModel.selectedPet {
                                    Text("Managing \(pet.name)'s care")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                } else {
                                    Text("Select a pet to manage")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            .padding(.top, 20)
                        
                        // Widgets Grid
                        LazyVGrid(columns: columns, spacing: 20) {
                            // Vaccines Widget
                            NavigationLink(destination: VaccinesView()) {
                                HealthWidgetContent(
                                    title: "Vaccines",
                                    icon: "syringe.fill",
                                    color: Color(red: 1.0, green: 0.6, blue: 0.4),
                                    subtitle: "Up to date"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // Appointments Widget
                            NavigationLink(destination: AppointmentsView(petId: viewModel.selectedPet?.id ?? 0)) {
                                HealthWidgetContent(
                                    title: "Appointments",
                                    icon: "calendar.badge.clock",
                                    color: Color(red: 0.9, green: 0.5, blue: 0.7),
                                    subtitle: "1 upcoming"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // Tablets Widget
                            NavigationLink(destination: TabletsView()) {
                                HealthWidgetContent(
                                    title: "Tablets",
                                    icon: "pills.fill",
                                    color: Color(red: 0.5, green: 0.7, blue: 1.0),
                                    subtitle: "Daily meds"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // Medical Records
                            NavigationLink(destination: RecordsView()) {
                                HealthWidgetContent(
                                    title: "Records",
                                    icon: "doc.text.fill",
                                    color: Color(red: 0.8, green: 0.8, blue: 0.4),
                                    subtitle: "History"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                            .padding(20)
                            .opacity(viewModel.selectedPet == nil ? 0.5 : 1.0)
                            .disabled(viewModel.selectedPet == nil)

                            // No pet selected message
                            if viewModel.selectedPet == nil && !viewModel.pets.isEmpty {
                                Text("Tap a pet above to view their health info")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.bottom, 20)
                            }

                            // No pets message
                            if viewModel.pets.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "pawprint.circle")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("No pets added yet")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Add a pet from the Pets tab to manage their health")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 40)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Pet Selector Chip

struct PetSelectorChip: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Pet avatar
                Group {
                    if UIImage(named: pet.imageName) != nil {
                        Image(pet.imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color.white
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.purple)
                        }
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())

                Text(pet.name)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct HealthWidgetContent: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(height: 140)
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

struct HealthWidget: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        Button(action: {
            // Action placeholder
        }) {
            HealthWidgetContent(
                title: title,
                icon: icon,
                color: color,
                subtitle: subtitle
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    HealthView()
        .environmentObject(PetViewModel())
}
