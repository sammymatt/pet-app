//
//  ColorView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI

struct ColorView: View {
    @EnvironmentObject var viewModel: PetViewModel
    @Environment(\.dismiss) var dismiss
    let pet: Pet

    @State private var selectedColor: String
    @State private var customColor: String = ""
    @State private var showingCustomInput = false

    let commonColors: [(String, Color)] = [
        ("Black", Color.black),
        ("White", Color.white),
        ("Brown", Color.brown),
        ("Golden", Color(red: 0.85, green: 0.65, blue: 0.13)),
        ("Gray", Color.gray),
        ("Orange", Color.orange),
        ("Cream", Color(red: 1.0, green: 0.99, blue: 0.82)),
        ("Tan", Color(red: 0.82, green: 0.71, blue: 0.55))
    ]

    let patternColors: [(String, [Color])] = [
        ("Brindle", [Color.brown, Color.black]),
        ("Spotted", [Color.white, Color.black]),
        ("Tabby", [Color.orange, Color.brown]),
        ("Calico", [Color.orange, Color.black, Color.white]),
        ("Merle", [Color.gray, Color.black, Color.white]),
        ("Tricolor", [Color.brown, Color.black, Color.white])
    ]

    init(pet: Pet) {
        self.pet = pet
        _selectedColor = State(initialValue: pet.color ?? "")
    }

    var displayColor: Color {
        if let colorTuple = commonColors.first(where: { $0.0.lowercased() == selectedColor.lowercased() }) {
            return colorTuple.1
        }
        return Color.gray
    }

    var body: some View {
        ZStack {
            AppBackground(style: .profile)

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text("\(pet.name)'s Color")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Current Color Display
                    if !selectedColor.isEmpty {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(displayColor)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.5), lineWidth: 3)
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 10)

                                if displayColor == .white {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                        .frame(width: 100, height: 100)
                                }
                            }

                            Text(selectedColor)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 10)
                    }

                    // Solid Colors
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Solid Colors")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(commonColors, id: \.0) { colorName, colorValue in
                                ColorOptionButton(
                                    name: colorName,
                                    color: colorValue,
                                    isSelected: selectedColor.lowercased() == colorName.lowercased()
                                ) {
                                    selectedColor = colorName
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Pattern Colors
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Patterns")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(patternColors, id: \.0) { patternName, colors in
                                PatternOptionButton(
                                    name: patternName,
                                    colors: colors,
                                    isSelected: selectedColor.lowercased() == patternName.lowercased()
                                ) {
                                    selectedColor = patternName
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Custom Color
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        if showingCustomInput {
                            HStack {
                                TextField("Enter color", text: $customColor)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                Button("Add") {
                                    if !customColor.isEmpty {
                                        selectedColor = customColor
                                        showingCustomInput = false
                                        customColor = ""
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.5, green: 0.7, blue: 1.0))
                                .cornerRadius(8)
                            }
                        } else {
                            Button(action: {
                                showingCustomInput = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Custom Color")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    saveColor()
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
    }

    private func saveColor() {
        var updatedPet = pet
        updatedPet.color = selectedColor.isEmpty ? nil : selectedColor
        viewModel.updatePet(updatedPet)
    }
}

struct ColorOptionButton: View {
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.yellow : (color == .white ? Color.gray.opacity(0.3) : Color.clear), lineWidth: isSelected ? 3 : 1)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(color == .white || color == Color(red: 1.0, green: 0.99, blue: 0.82) ? .black : .white)
                    }
                }

                Text(name)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PatternOptionButton: View {
    let name: String
    let colors: [Color]
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: colors),
                                center: .center
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                    }
                }

                Text(name)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        ColorView(pet: Pet.willow)
            .environmentObject(PetViewModel())
    }
}
