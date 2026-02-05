//
//  PetModelTests.swift
//  petmanagerTests
//
//  Created by Sam Matthews on 25/01/2026.
//

import Testing
import Foundation
@testable import petmanager

struct PetModelTests {

    // MARK: - Initialization Tests

    @Test func initializesWithAllProperties() {
        let birthday = Date()
        let pet = Pet(
            id: 1,
            name: "Buddy",
            breed: "Golden Retriever",
            age: 5,
            description: "A friendly dog",
            weight: 30.5,
            gender: "Male",
            color: "Golden",
            imageName: "buddy_photo",
            birthday: birthday
        )

        #expect(pet.id == 1)
        #expect(pet.name == "Buddy")
        #expect(pet.breed == "Golden Retriever")
        #expect(pet.age == 5)
        #expect(pet.description == "A friendly dog")
        #expect(pet.weight == 30.5)
        #expect(pet.gender == "Male")
        #expect(pet.color == "Golden")
        #expect(pet.imageName == "buddy_photo")
        #expect(pet.birthday == birthday)
    }

    @Test func initializesWithDefaultValues() {
        let pet = Pet(
            id: 1,
            name: "Test",
            breed: "Dog",
            age: 1,
            description: "Test pet",
            weight: 10.0,
            gender: "Male"
        )

        #expect(pet.imageName == "pawprint.circle.fill")
        #expect(pet.birthday == nil)
        #expect(pet.color == nil)
    }

    @Test func willowStaticPropertyReturnsValidPet() {
        let willow = Pet.willow

        #expect(willow.id == 22)
        #expect(willow.name == "Willow")
        #expect(willow.breed == "Cocker Spaniel")
        #expect(willow.age == 3)
        #expect(willow.weight == 12.5)
        #expect(willow.gender == "Female")
        #expect(willow.color == "Golden")
        #expect(willow.imageName == "willow")
    }

    // MARK: - Codable Tests

    @Test func decodesFromJSONWithSpeciesField() throws {
        let json = """
        {
            "id": 1,
            "name": "Max",
            "species": "Labrador",
            "age": 4,
            "description": "A playful dog",
            "weight": 25.0,
            "gender": "Male"
        }
        """.data(using: .utf8)!

        let pet = try JSONDecoder().decode(Pet.self, from: json)

        #expect(pet.id == 1)
        #expect(pet.name == "Max")
        #expect(pet.breed == "Labrador") // 'species' in JSON maps to 'breed'
        #expect(pet.age == 4)
        #expect(pet.weight == 25.0)
        #expect(pet.gender == "Male")
    }

    @Test func encodesToJSONWithSpeciesField() throws {
        let pet = Pet(
            id: 1,
            name: "Max",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male"
        )

        let data = try JSONEncoder().encode(pet)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["species"] as? String == "Labrador") // 'breed' encodes as 'species'
        #expect(json["breed"] == nil) // 'breed' should not exist in JSON
    }

    @Test func imageNameIsExcludedFromEncoding() throws {
        let pet = Pet(
            id: 1,
            name: "Max",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male",
            imageName: "custom_image"
        )

        let data = try JSONEncoder().encode(pet)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["imageName"] == nil) // imageName should not be encoded
    }

    @Test func decodesOptionalColorWhenPresent() throws {
        let json = """
        {
            "id": 1,
            "name": "Max",
            "species": "Labrador",
            "age": 4,
            "description": "A playful dog",
            "weight": 25.0,
            "gender": "Male",
            "color": "Black"
        }
        """.data(using: .utf8)!

        let pet = try JSONDecoder().decode(Pet.self, from: json)

        #expect(pet.color == "Black")
    }

    @Test func decodesOptionalColorWhenAbsent() throws {
        let json = """
        {
            "id": 1,
            "name": "Max",
            "species": "Labrador",
            "age": 4,
            "description": "A playful dog",
            "weight": 25.0,
            "gender": "Male"
        }
        """.data(using: .utf8)!

        let pet = try JSONDecoder().decode(Pet.self, from: json)

        #expect(pet.color == nil)
    }

    @Test func decodesAndEncodesDateWithFormatter() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let json = """
        {
            "id": 1,
            "name": "Max",
            "species": "Labrador",
            "age": 4,
            "description": "A playful dog",
            "weight": 25.0,
            "gender": "Male",
            "birthday": "2020-06-15"
        }
        """.data(using: .utf8)!

        let pet = try decoder.decode(Pet.self, from: json)

        #expect(pet.birthday != nil)

        // Verify round-trip
        let encoded = try encoder.encode(pet)
        let jsonDict = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        #expect(jsonDict["birthday"] as? String == "2020-06-15")
    }

    // MARK: - Equatable Tests

    @Test func petsWithSamePropertiesAreEqual() {
        let pet1 = Pet(
            id: 1,
            name: "Max",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male"
        )

        let pet2 = Pet(
            id: 1,
            name: "Max",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male"
        )

        #expect(pet1 == pet2)
    }

    @Test func petsWithDifferentIdsAreNotEqual() {
        let pet1 = Pet(
            id: 1,
            name: "Max",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male"
        )

        let pet2 = Pet(
            id: 2,
            name: "Max",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male"
        )

        #expect(pet1 != pet2)
    }

    @Test func petsWithDifferentNamesAreNotEqual() {
        let pet1 = Pet(
            id: 1,
            name: "Max",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male"
        )

        let pet2 = Pet(
            id: 1,
            name: "Buddy",
            breed: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male"
        )

        #expect(pet1 != pet2)
    }
}
