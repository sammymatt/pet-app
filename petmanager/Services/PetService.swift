//
//  PetService.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import Foundation
import Combine

class PetService {
    static let shared = PetService()
    
    private let baseURL = URL(string: "http://localhost:8000")!
    
    // FETCH PET by ID
    func fetchPet(id: Int) -> AnyPublisher<Pet, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(id)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Pet.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // CREATE PET
    func createPet(petRequest: PetCreationRequest) -> AnyPublisher<Pet, Error> {
        let url = baseURL.appendingPathComponent("pets")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(petRequest)
            request.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Pet.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // FETCH PETS by USER ID
    func fetchPets(forUserId userId: Int) -> AnyPublisher<[Pet], Error> {
        let url = baseURL.appendingPathComponent("users").appendingPathComponent("\(userId)").appendingPathComponent("pets")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Pet].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
