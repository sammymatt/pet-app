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
        
        PetService.shared.createPet(petRequest: request)
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
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets.remove(at: index)
            if selectedPet?.id == pet.id {
                selectedPet = pets.first
            }
        }
    }
}
