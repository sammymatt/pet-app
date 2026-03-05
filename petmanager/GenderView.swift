//
//  GenderView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI

struct GenderView: View {
    @EnvironmentObject var viewModel: PetViewModel
    @Environment(\.dismiss) var dismiss
    let pet: Pet

    @State private var selectedGender: String

    let genderOptions = ["Male", "Female"]

    init(pet: Pet) {
        self.pet = pet
        _selectedGender = State(initialValue: pet.gender)
    }

    var genderIcon: String {
        switch selectedGender.lowercased() {
        case "male":
            return "circle.and.line.horizontal"
        case "female":
            return "circle.and.line.horizontal.fill"
        default:
            return "questionmark.circle"
        }
    }

    var genderColor: Color {
        switch selectedGender.lowercased() {
        case "male":
            return Color(red: 0.4, green: 0.6, blue: 1.0)
        case "female":
            return Color(red: 1.0, green: 0.5, blue: 0.7)
        default:
            return Color.gray
        }
    }

    var body: some View {
        ZStack {
            AppBackground(style: .profile)

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text("\(pet.name)'s Gender")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Current Gender Display
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(genderColor.opacity(0.3))
                                .frame(width: 120, height: 120)

                            Image(systemName: selectedGender.lowercased() == "male" ? "figure.stand" : "figure.stand.dress")
                                .font(.system(size: 60))
                                .foregroundColor(genderColor)
                        }

                        Text(selectedGender)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 20)

                    // Gender Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Gender")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 16) {
                            ForEach(genderOptions, id: \.self) { gender in
                                GenderOptionCard(
                                    gender: gender,
                                    isSelected: selectedGender == gender
                                ) {
                                    withAnimation {
                                        selectedGender = gender
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Color(red: 0.5, green: 0.7, blue: 1.0))

                            Text("About Gender")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text("Knowing your pet's gender helps with healthcare planning, behavior understanding, and connecting with appropriate services.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.15))
                    )
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    saveGender()
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
    }

    private func saveGender() {
        var updatedPet = pet
        updatedPet.gender = selectedGender
        viewModel.updatePet(updatedPet)
    }
}

struct GenderOptionCard: View {
    let gender: String
    let isSelected: Bool
    let action: () -> Void

    var icon: String {
        gender.lowercased() == "male" ? "figure.stand" : "figure.stand.dress"
    }

    var color: Color {
        gender.lowercased() == "male" ? Color(red: 0.4, green: 0.6, blue: 1.0) : Color(red: 1.0, green: 0.5, blue: 0.7)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.4) : .white.opacity(0.1))
                        .frame(width: 70, height: 70)

                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(isSelected ? color : .white.opacity(0.6))
                }

                Text(gender)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color.opacity(0.2) : .white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : .white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    NavigationView {
        GenderView(pet: Pet.willow)
            .environmentObject(PetViewModel())
    }
}
