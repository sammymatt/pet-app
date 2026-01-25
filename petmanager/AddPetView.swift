//
//  AddPetView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct AddPetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: PetViewModel
    
    @State private var name = ""
    @State private var breed = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var gender = "Male"
    @State private var color = ""
    @State private var description = ""
    
    let commonColors = ["Black", "White", "Brown", "Golden", "Grey", "Tan", "Spotted", "Tricolor"]
    
    // Simple avatar selection for now
    let avatars = ["dog.circle.fill", "cat.circle.fill", "pawprint.circle.fill", "hare.fill", "tortoise.fill"]
    @State private var selectedAvatar = "pawprint.circle.fill"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pet Info")) {
                    TextField("Name", text: $name)
                    TextField("Breed", text: $breed)
                    TextField("Age (e.g. 2 years)", text: $age)
                    TextField("Weight (e.g. 5 kg)", text: $weight)
                    
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    
                    HStack {
                        TextField("Color", text: $color)
                        
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
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("App Icon")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(avatars, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
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
            }
            .navigationTitle("Add New Pet")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    savePet()
                }
                .disabled(name.isEmpty || breed.isEmpty)
            )
        }
    }
    
    private func savePet() {
        // Convert age to Int, default to 0 if invalid
        let ageInt = Int(age) ?? 0
        
        // Convert weight string to Double, handling basic "5 kg" or just "5" format
        let weightCleaned = weight.replacingOccurrences(of: " kg", with: "").replacingOccurrences(of: "kg", with: "")
        let weightDouble = Double(weightCleaned) ?? 0.0
        
        viewModel.addPet(
            name: name,
            breed: breed,
            age: ageInt,
            description: description,
            weight: weightDouble,
            gender: gender,
            color: color
        )
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddPetView()
        .environmentObject(PetViewModel())
}
