//
//  PetCreationRequestTests.swift
//  petmanagerTests
//
//  Created by Sam Matthews on 25/01/2026.
//

import Testing
import Foundation
@testable import petmanager

struct PetCreationRequestTests {

    // MARK: - Initialization Tests

    @Test func initializesWithAllProperties() {
        let birthday = Date()
        let request = PetCreationRequest(
            id: 0,
            name: "Buddy",
            species: "Golden Retriever",
            age: 5,
            description: "A friendly dog",
            weight: 30.5,
            gender: "Male",
            color: "Golden",
            birthday: birthday
        )

        #expect(request.id == 0)
        #expect(request.name == "Buddy")
        #expect(request.species == "Golden Retriever")
        #expect(request.age == 5)
        #expect(request.description == "A friendly dog")
        #expect(request.weight == 30.5)
        #expect(request.gender == "Male")
        #expect(request.color == "Golden")
        #expect(request.birthday == birthday)
    }

    @Test func initializesWithNilOptionalFields() {
        let request = PetCreationRequest(
            id: 0,
            name: "Buddy",
            species: "Golden Retriever",
            age: 5,
            description: "A friendly dog",
            weight: 30.5,
            gender: "Male",
            color: nil,
            birthday: nil
        )

        #expect(request.color == nil)
        #expect(request.birthday == nil)
    }

    // MARK: - Encoding Tests

    @Test func encodesToJSONWithSpeciesField() throws {
        let request = PetCreationRequest(
            id: 0,
            name: "Max",
            species: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male",
            color: nil,
            birthday: nil
        )

        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["id"] as? Int == 0)
        #expect(json["name"] as? String == "Max")
        #expect(json["species"] as? String == "Labrador")
        #expect(json["age"] as? Int == 4)
        #expect(json["description"] as? String == "A playful dog")
        #expect(json["weight"] as? Double == 25.0)
        #expect(json["gender"] as? String == "Male")
    }

    @Test func encodesColorWhenPresent() throws {
        let request = PetCreationRequest(
            id: 0,
            name: "Max",
            species: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male",
            color: "Black",
            birthday: nil
        )

        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["color"] as? String == "Black")
    }

    @Test func encodesBirthdayWithDateFormatter() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let birthday = dateFormatter.date(from: "2020-03-15")!

        let request = PetCreationRequest(
            id: 0,
            name: "Max",
            species: "Labrador",
            age: 4,
            description: "A playful dog",
            weight: 25.0,
            gender: "Male",
            color: nil,
            birthday: birthday
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["birthday"] as? String == "2020-03-15")
    }

    // MARK: - Decoding Tests

    @Test func decodesFromJSON() throws {
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

        let request = try JSONDecoder().decode(PetCreationRequest.self, from: json)

        #expect(request.id == 1)
        #expect(request.name == "Max")
        #expect(request.species == "Labrador")
        #expect(request.age == 4)
        #expect(request.description == "A playful dog")
        #expect(request.weight == 25.0)
        #expect(request.gender == "Male")
        #expect(request.color == nil)
        #expect(request.birthday == nil)
    }

    @Test func decodesFromJSONWithOptionalFields() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let json = """
        {
            "id": 1,
            "name": "Max",
            "species": "Labrador",
            "age": 4,
            "description": "A playful dog",
            "weight": 25.0,
            "gender": "Male",
            "color": "Yellow",
            "birthday": "2020-03-15"
        }
        """.data(using: .utf8)!

        let request = try decoder.decode(PetCreationRequest.self, from: json)

        #expect(request.color == "Yellow")
        #expect(request.birthday != nil)
        #expect(dateFormatter.string(from: request.birthday!) == "2020-03-15")
    }
}
