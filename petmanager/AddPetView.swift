//
//  AddPetView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI
import PhotosUI

struct AddPetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: PetViewModel

    let petToEdit: Pet?

    @State private var name = ""
    @State private var breed = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var gender = "Male"
    @State private var color = ""
    @State private var description = ""

    let commonColors = ["Black", "White", "Brown", "Golden", "Grey", "Tan", "Spotted", "Tricolor"]

    // Avatar selection
    let avatars = ["dog.circle.fill", "cat.circle.fill", "pawprint.circle.fill", "hare.fill", "tortoise.fill"]
    @State private var selectedAvatar = "pawprint.circle.fill"

    // Photo picker
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var customImage: UIImage?

    init(petToEdit: Pet? = nil) {
        self.petToEdit = petToEdit
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pet Info")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("", text: $name)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Species")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. Dog, Cat", text: $breed)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Age (years)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. 2", text: $age)
                            .keyboardType(.numberPad)
                            .onChange(of: age) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue {
                                    age = filtered
                                }
                            }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight (kg)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. 5", text: $weight)
                            .keyboardType(.decimalPad)
                            .onChange(of: weight) { newValue in
                                let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                let decimalCount = filtered.filter { $0 == "." }.count
                                if decimalCount > 1 || filtered != newValue {
                                    weight = String(filtered.prefix(while: { $0 != "." || decimalCount <= 1 }))
                                    if decimalCount > 1 {
                                        if let firstDecimal = filtered.firstIndex(of: ".") {
                                            let beforeDecimal = filtered[..<firstDecimal]
                                            let afterDecimal = filtered[filtered.index(after: firstDecimal)...].filter { $0 != "." }
                                            weight = String(beforeDecimal) + "." + String(afterDecimal)
                                        }
                                    } else {
                                        weight = filtered
                                    }
                                }
                            }
                    }

                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Color")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            TextField("e.g. Brown", text: $color)

                            Menu {
                                ForEach(commonColors, id: \.self) { colorOption in
                                    Button(colorOption) {
                                        self.color = colorOption
                                    }
                                }
                            } label: {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }

                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }

                Section(header: Text("Avatar")) {
                    // Current avatar preview
                    HStack {
                        Spacer()
                        if let image = customImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.purple, lineWidth: 3))
                        } else {
                            Image(systemName: selectedAvatar)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.purple)
                        }
                        Spacer()
                    }

                    // Photo picker
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .foregroundColor(.purple)
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        guard let item = newItem else { return }
                        Task {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                customImage = uiImage
                                selectedAvatar = "custom_photo"
                            }
                        }
                    }

                    // SF Symbol icons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(avatars, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                    customImage = nil
                                    selectedPhoto = nil
                                }) {
                                    Image(systemName: avatar)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(selectedAvatar == avatar ? .purple : .gray)
                                        .padding(4)
                                        .background(
                                            Circle()
                                                .stroke(selectedAvatar == avatar ? Color.purple : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .navigationTitle(petToEdit == nil ? "Add New Pet" : "Edit Pet")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        savePet()
                    }
                        .disabled(name.isEmpty || breed.isEmpty)
                )
                .onAppear {
                    if let pet = petToEdit {
                        name = pet.name
                        breed = pet.breed
                        age = "\(pet.age)"
                        weight = String(format: "%.1f", pet.weight)
                        gender = pet.gender
                        color = pet.color ?? ""
                        description = pet.description
                        selectedAvatar = pet.imageName
                        // Load existing custom photo if one was saved
                        if pet.imageName == "custom_photo" {
                            customImage = PetImageManager.shared.loadImage(for: pet.id)
                        }
                    }
                }
            }
        }
    }

    private func savePet() {
        // Convert age to Int, default to 0 if invalid
        let ageInt = Int(age) ?? 0

        // Convert weight string to Double, handling basic "5 kg" or just "5" format
        let weightCleaned = weight.replacingOccurrences(of: " kg", with: "").replacingOccurrences(of: "kg", with: "")
        let weightDouble = Double(weightCleaned) ?? 0.0

        if let pet = petToEdit {
            // Update existing pet
            viewModel.updatePet(
                pet,
                name: name,
                breed: breed,
                age: ageInt,
                description: description,
                weight: weightDouble,
                gender: gender,
                color: color,
                imageName: selectedAvatar,
                customImage: customImage
            )
        } else {
            // Add new pet
            viewModel.addPet(
                name: name,
                breed: breed,
                age: ageInt,
                description: description,
                weight: weightDouble,
                gender: gender,
                color: color,
                imageName: selectedAvatar,
                customImage: customImage
            )
        }
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddPetView()
        .environmentObject(PetViewModel())
}
