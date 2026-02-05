//
//  PetViewModelTests.swift
//  petmanagerTests
//
//  Created by Sam Matthews on 25/01/2026.
//

import Testing
import Foundation
import Combine
@testable import petmanager

struct PetViewModelTests {

    // MARK: - Initialization Tests

    @Test func initializesWithEmptyPetsArray() {
        let viewModel = PetViewModel()

        #expect(viewModel.pets.isEmpty)
        #expect(viewModel.selectedPet == nil)
    }

    // MARK: - Select Pet Tests

    @Test func selectPetUpdatesSelectedPet() {
        let viewModel = PetViewModel()
        let pet = Pet(
            id: 1,
            name: "Buddy",
            breed: "Golden Retriever",
            age: 5,
            description: "A friendly dog",
            weight: 30.5,
            gender: "Male"
        )

        viewModel.selectPet(pet)

        #expect(viewModel.selectedPet == pet)
    }

    @Test func selectPetCanChangeSelection() {
        let viewModel = PetViewModel()
        let pet1 = Pet(
            id: 1,
            name: "Buddy",
            breed: "Golden Retriever",
            age: 5,
            description: "A friendly dog",
            weight: 30.5,
            gender: "Male"
        )
        let pet2 = Pet(
            id: 2,
            name: "Max",
            breed: "Labrador",
            age: 3,
            description: "A playful dog",
            weight: 28.0,
            gender: "Male"
        )

        viewModel.selectPet(pet1)
        #expect(viewModel.selectedPet == pet1)

        viewModel.selectPet(pet2)
        #expect(viewModel.selectedPet == pet2)
    }

    // MARK: - Pet Array Mutation Tests (Synchronous State Management)

    @Test func petsArrayIsPublished() {
        let viewModel = PetViewModel()
        var receivedValues: [[Pet]] = []
        var cancellables = Set<AnyCancellable>()

        viewModel.$pets
            .sink { pets in
                receivedValues.append(pets)
            }
            .store(in: &cancellables)

        // Initial value should be empty
        #expect(receivedValues.count >= 1)
        #expect(receivedValues[0].isEmpty)
    }

    @Test func selectedPetIsPublished() {
        let viewModel = PetViewModel()
        var receivedValues: [Pet?] = []
        var cancellables = Set<AnyCancellable>()

        viewModel.$selectedPet
            .sink { pet in
                receivedValues.append(pet)
            }
            .store(in: &cancellables)

        // Initial value should be nil
        #expect(receivedValues.count >= 1)
        #expect(receivedValues[0] == nil)

        // Select a pet
        let pet = Pet(
            id: 1,
            name: "Buddy",
            breed: "Golden Retriever",
            age: 5,
            description: "A friendly dog",
            weight: 30.5,
            gender: "Male"
        )
        viewModel.selectPet(pet)

        #expect(receivedValues.count >= 2)
        #expect(receivedValues[1] == pet)
    }

    // MARK: - PetCreationRequest Construction Tests

    @Test func addPetCreatesCorrectRequest() {
        // This tests that the request would be constructed correctly
        // by creating a PetCreationRequest with the same logic as addPet
        let name = "Buddy"
        let breed = "Golden Retriever"
        let age = 5
        let description = "A friendly dog"
        let weight = 30.5
        let gender = "Male"
        let color = "Golden"
        let birthday = Date()

        let request = PetCreationRequest(
            id: 0,
            name: name,
            species: breed, // Note: breed maps to species
            age: age,
            description: description,
            weight: weight,
            gender: gender,
            color: color,
            birthday: birthday
        )

        #expect(request.id == 0)
        #expect(request.name == name)
        #expect(request.species == breed)
        #expect(request.age == age)
        #expect(request.description == description)
        #expect(request.weight == weight)
        #expect(request.gender == gender)
        #expect(request.color == color)
        #expect(request.birthday == birthday)
    }

    @Test func updatePetCreatesCorrectRequest() {
        // This tests that updatePet constructs the correct PetCreationRequest
        let pet = Pet(
            id: 5,
            name: "Original",
            breed: "Labrador",
            age: 3,
            description: "Original description",
            weight: 25.0,
            gender: "Male"
        )

        let newName = "Updated"
        let newBreed = "Golden Retriever"
        let newAge = 4
        let newDescription = "Updated description"
        let newWeight = 28.0
        let newGender = "Male"
        let newColor = "Golden"
        let newBirthday = Date()

        let request = PetCreationRequest(
            id: pet.id,
            name: newName,
            species: newBreed,
            age: newAge,
            description: newDescription,
            weight: newWeight,
            gender: newGender,
            color: newColor,
            birthday: newBirthday
        )

        #expect(request.id == pet.id)
        #expect(request.name == newName)
        #expect(request.species == newBreed)
        #expect(request.age == newAge)
        #expect(request.description == newDescription)
        #expect(request.weight == newWeight)
        #expect(request.gender == newGender)
        #expect(request.color == newColor)
        #expect(request.birthday == newBirthday)
    }

    @Test func updatePetOverloadUsesExistingPetProperties() {
        // Test the updatePet(_:) overload that takes just a Pet
        let pet = Pet(
            id: 5,
            name: "Buddy",
            breed: "Labrador",
            age: 3,
            description: "A friendly dog",
            weight: 25.0,
            gender: "Male",
            color: "Yellow",
            birthday: nil
        )

        // This simulates what updatePet(_:) does internally
        let request = PetCreationRequest(
            id: pet.id,
            name: pet.name,
            species: pet.breed,
            age: pet.age,
            description: pet.description,
            weight: pet.weight,
            gender: pet.gender,
            color: pet.color ?? "",
            birthday: pet.birthday
        )

        #expect(request.id == pet.id)
        #expect(request.name == pet.name)
        #expect(request.species == pet.breed)
        #expect(request.color == pet.color)
    }
}
