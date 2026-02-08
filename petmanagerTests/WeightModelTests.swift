//
//  WeightModelTests.swift
//  petmanagerTests
//
//  Created by Sam Matthews on 08/02/2026.
//

import Testing
import Foundation
@testable import petmanager

struct WeightModelTests {

    // MARK: - Initialization Tests

    @Test func initializesWithAllProperties() {
        let recordedAt = Date()
        let weight = Weight(
            id: 1,
            weight: 25.5,
            recordedAt: recordedAt,
            notes: "After breakfast",
            petId: 22
        )

        #expect(weight.id == 1)
        #expect(weight.weight == 25.5)
        #expect(weight.recordedAt == recordedAt)
        #expect(weight.notes == "After breakfast")
        #expect(weight.petId == 22)
    }

    @Test func initializesWithNilNotes() {
        let recordedAt = Date()
        let weight = Weight(
            id: 1,
            weight: 25.5,
            recordedAt: recordedAt,
            notes: nil,
            petId: 22
        )

        #expect(weight.notes == nil)
    }

    // MARK: - Codable Tests

    @Test func decodesFromJSONWithSnakeCaseKeys() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date")
        }

        let json = """
        {
            "id": 1,
            "weight": 25.5,
            "recorded_at": "2026-02-08T10:30:00Z",
            "notes": "Morning weigh-in",
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let weight = try decoder.decode(Weight.self, from: json)

        #expect(weight.id == 1)
        #expect(weight.weight == 25.5)
        #expect(weight.notes == "Morning weigh-in")
        #expect(weight.petId == 22)
    }

    @Test func decodesFromJSONWithNullNotes() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date")
        }

        let json = """
        {
            "id": 1,
            "weight": 25.5,
            "recorded_at": "2026-02-08T10:30:00Z",
            "notes": null,
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let weight = try decoder.decode(Weight.self, from: json)

        #expect(weight.notes == nil)
    }

    @Test func encodesToJSONWithSnakeCaseKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let weight = Weight(
            id: 1,
            weight: 25.5,
            recordedAt: Date(),
            notes: "Test note",
            petId: 22
        )

        let data = try encoder.encode(weight)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["id"] as? Int == 1)
        #expect(json["weight"] as? Double == 25.5)
        #expect(json["recorded_at"] != nil)
        #expect(json["notes"] as? String == "Test note")
        #expect(json["pet_id"] as? Int == 22)
        // Verify camelCase keys are not present
        #expect(json["recordedAt"] == nil)
        #expect(json["petId"] == nil)
    }

    // MARK: - WeightCreateRequest Tests

    @Test func weightCreateRequestEncodesCorrectly() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let request = WeightCreateRequest(
            weight: 26.0,
            notes: "After walk",
            recordedAt: Date()
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["weight"] as? Double == 26.0)
        #expect(json["notes"] as? String == "After walk")
        #expect(json["recorded_at"] != nil)
    }

    @Test func weightCreateRequestEncodesWithNilOptionals() throws {
        let encoder = JSONEncoder()

        let request = WeightCreateRequest(
            weight: 26.0,
            notes: nil,
            recordedAt: nil
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["weight"] as? Double == 26.0)
    }

    @Test func weightCreateRequestUsesSnakeCaseKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let request = WeightCreateRequest(
            weight: 26.0,
            notes: "Test",
            recordedAt: Date()
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Verify snake_case keys
        #expect(json["recorded_at"] != nil)
        // Verify camelCase NOT present
        #expect(json["recordedAt"] == nil)
    }

    // MARK: - WeightUpdateRequest Tests

    @Test func weightUpdateRequestEncodesAllFields() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        var request = WeightUpdateRequest()
        request.weight = 27.0
        request.notes = "Updated note"
        request.recordedAt = Date()

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["weight"] as? Double == 27.0)
        #expect(json["notes"] as? String == "Updated note")
        #expect(json["recorded_at"] != nil)
    }

    @Test func weightUpdateRequestEncodesPartialUpdate() throws {
        let encoder = JSONEncoder()

        var request = WeightUpdateRequest()
        request.weight = 28.0

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["weight"] as? Double == 28.0)
    }

    @Test func weightUpdateRequestUsesSnakeCaseKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        var request = WeightUpdateRequest()
        request.recordedAt = Date()

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Verify snake_case keys
        #expect(json["recorded_at"] != nil)
        // Verify camelCase NOT present
        #expect(json["recordedAt"] == nil)
    }

    // MARK: - Equatable Tests

    @Test func weightsWithSamePropertiesAreEqual() {
        let date = Date()
        let weight1 = Weight(
            id: 1,
            weight: 25.5,
            recordedAt: date,
            notes: "Note",
            petId: 22
        )
        let weight2 = Weight(
            id: 1,
            weight: 25.5,
            recordedAt: date,
            notes: "Note",
            petId: 22
        )

        #expect(weight1 == weight2)
    }

    @Test func weightsWithDifferentIdsAreNotEqual() {
        let date = Date()
        let weight1 = Weight(
            id: 1,
            weight: 25.5,
            recordedAt: date,
            notes: "Note",
            petId: 22
        )
        let weight2 = Weight(
            id: 2,
            weight: 25.5,
            recordedAt: date,
            notes: "Note",
            petId: 22
        )

        #expect(weight1 != weight2)
    }
}
