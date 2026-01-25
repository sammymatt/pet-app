//
//  Pet.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import Foundation

struct Pet: Identifiable, Codable, Equatable {
    var id: Int
    var name: String
    var breed: String // Maps to 'species' in API
    var age: Int
    var description: String
    var weight: Double
    var gender: String
    var color: String?
    
    // Local-only fields
    var imageName: String = "pawprint.circle.fill"
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breed = "species"
        case age
        case description
        case weight
        case gender
        case color
        // imageName ignored
    }
    
    // Initializer for local creation (testing or previews)
    init(id: Int, name: String, breed: String, age: Int, description: String, weight: Double, gender: String, color: String? = nil, imageName: String = "pawprint.circle.fill") {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.description = description
        self.weight = weight
        self.gender = gender
        self.color = color
        self.imageName = imageName
    }
    
    // Helper to get a default pet (Willow)
    static var willow: Pet {
        Pet(
            id: 22,
            name: "Willow",
            breed: "Cocker Spaniel",
            age: 3,
            description: "Willow is a sweet and energetic cocker spaniel with beautiful golden-brown fur. She loves long walks, playing fetch, and cuddling on the couch. Her favorite treats are peanut butter biscuits!",
            weight: 12.5,
            gender: "Female",
            color: "Golden",
            imageName: "willow"
        )
    }
}

struct PetCreationRequest: Codable {
    var id: Int
    var name: String
    var species: String
    var age: Int
    var description: String
    var weight: Double
    var gender: String
    var color: String?
}
