//
//  PetViewModel.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI
import Combine

class PetViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var selectedPet: Pet?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Start with empty or fetch initial data if needed
    }
    
    func fetchPet(id: Int) {
        PetService.shared.fetchPet(id: id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching pet: \(error)")
                }
            }, receiveValue: { [weak self] pet in
                self?.pets.append(pet)
                self?.selectedPet = pet
            })
            .store(in: &cancellables)
    }
    
    func fetchPets(forUserId userId: Int) {
        PetService.shared.fetchPets(forUserId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching pets for user: \(error)")
                }
            }, receiveValue: { [weak self] pets in
                self?.pets = pets
                if self?.selectedPet == nil {
                    self?.selectedPet = pets.first
                }
            })
            .store(in: &cancellables)
    }
    
    func addPet(name: String, breed: String, age: Int, description: String, weight: Double, gender: String, color: String) {
        let request = PetCreationRequest(
            id: 0,
            name: name,
            species: breed,
            age: age,
            description: description,
            weight: weight,
            gender: gender,
            color: color
        )
        
        #if DEBUG
        let userId: Int? = 1
        #else
        let userId: Int? = nil
        #endif
        
        PetService.shared.createPet(petRequest: request, userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error creating pet: \(error)")
                }
            }, receiveValue: { [weak self] newPet in
                self?.pets.append(newPet)
                self?.selectedPet = newPet
            })
            .store(in: &cancellables)
    }
    
    func selectPet(_ pet: Pet) {
        selectedPet = pet
    }
    
    func deletePet(_ pet: Pet) {
        PetService.shared.deletePet(id: pet.id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error deleting pet: \(error)")
                }
            }, receiveValue: { [weak self] _ in
                // Remove from local state after successful deletion
                if let index = self?.pets.firstIndex(where: { $0.id == pet.id }) {
                    self?.pets.remove(at: index)
                    if self?.selectedPet?.id == pet.id {
                        self?.selectedPet = self?.pets.first
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func updatePet(_ pet: Pet, name: String, breed: String, age: Int, description: String, weight: Double, gender: String, color: String) {
        let request = PetCreationRequest(
            id: pet.id,
            name: name,
            species: breed,
            age: age,
            description: description,
            weight: weight,
            gender: gender,
            color: color
        )
        
        PetService.shared.updatePet(id: pet.id, petRequest: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error updating pet: \(error)")
                }
            }, receiveValue: { [weak self] updatedPet in
                // Update in local state
                if let index = self?.pets.firstIndex(where: { $0.id == pet.id }) {
                    self?.pets[index] = updatedPet
                    if self?.selectedPet?.id == pet.id {
                        self?.selectedPet = updatedPet
                    }
                }
            })
            .store(in: &cancellables)
    }
}
