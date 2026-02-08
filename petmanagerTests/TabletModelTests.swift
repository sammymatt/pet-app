//
//  TabletModelTests.swift
//  petmanagerTests
//
//  Created by Sam Matthews on 08/02/2026.
//

import Testing
import Foundation
@testable import petmanager

struct TabletModelTests {

    // MARK: - Initialization Tests

    @Test func initializesWithAllProperties() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 3, to: startDate)!
        let tablet = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: "50mg",
            frequency: "Monthly",
            startDate: startDate,
            endDate: endDate,
            notes: "Give with food",
            petId: 22
        )

        #expect(tablet.id == 1)
        #expect(tablet.name == "Heartgard")
        #expect(tablet.dosage == "50mg")
        #expect(tablet.frequency == "Monthly")
        #expect(tablet.startDate == startDate)
        #expect(tablet.endDate == endDate)
        #expect(tablet.notes == "Give with food")
        #expect(tablet.petId == 22)
    }

    @Test func initializesWithNilOptionalFields() {
        let startDate = Date()
        let tablet = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: nil,
            frequency: nil,
            startDate: startDate,
            endDate: nil,
            notes: nil,
            petId: 22
        )

        #expect(tablet.dosage == nil)
        #expect(tablet.frequency == nil)
        #expect(tablet.endDate == nil)
        #expect(tablet.notes == nil)
    }

    // MARK: - isActive Computed Property Tests

    @Test func isActiveReturnsTrueWhenEndDateIsNil() {
        let tablet = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: nil,
            frequency: nil,
            startDate: Date(),
            endDate: nil,
            notes: nil,
            petId: 22
        )

        #expect(tablet.isActive == true)
    }

    @Test func isActiveReturnsTrueWhenEndDateIsInFuture() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let tablet = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: nil,
            frequency: nil,
            startDate: Date(),
            endDate: futureDate,
            notes: nil,
            petId: 22
        )

        #expect(tablet.isActive == true)
    }

    @Test func isActiveReturnsTrueWhenEndDateIsToday() {
        let calendar = Calendar.current
        let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        let tablet = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: nil,
            frequency: nil,
            startDate: Date(),
            endDate: endOfToday,
            notes: nil,
            petId: 22
        )

        #expect(tablet.isActive == true)
    }

    @Test func isActiveReturnsFalseWhenEndDateIsInPast() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tablet = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: nil,
            frequency: nil,
            startDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            endDate: pastDate,
            notes: nil,
            petId: 22
        )

        #expect(tablet.isActive == false)
    }

    // MARK: - Codable Tests

    @Test func decodesFromJSONWithSnakeCaseKeys() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let json = """
        {
            "id": 1,
            "name": "Heartgard",
            "dosage": "50mg",
            "frequency": "Monthly",
            "start_date": "2026-01-01",
            "end_date": "2026-06-01",
            "notes": "Give with food",
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let tablet = try decoder.decode(Tablet.self, from: json)

        #expect(tablet.id == 1)
        #expect(tablet.name == "Heartgard")
        #expect(tablet.dosage == "50mg")
        #expect(tablet.frequency == "Monthly")
        #expect(tablet.notes == "Give with food")
        #expect(tablet.petId == 22)
    }

    @Test func decodesFromJSONWithNullOptionalFields() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let json = """
        {
            "id": 1,
            "name": "Heartgard",
            "dosage": null,
            "frequency": null,
            "start_date": "2026-01-01",
            "end_date": null,
            "notes": null,
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let tablet = try decoder.decode(Tablet.self, from: json)

        #expect(tablet.dosage == nil)
        #expect(tablet.frequency == nil)
        #expect(tablet.endDate == nil)
        #expect(tablet.notes == nil)
    }

    @Test func encodesToJSONWithSnakeCaseKeys() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let tablet = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: "50mg",
            frequency: "Monthly",
            startDate: Date(),
            endDate: nil,
            notes: "Test",
            petId: 22
        )

        let data = try encoder.encode(tablet)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["id"] as? Int == 1)
        #expect(json["name"] as? String == "Heartgard")
        #expect(json["dosage"] as? String == "50mg")
        #expect(json["frequency"] as? String == "Monthly")
        #expect(json["start_date"] != nil)
        #expect(json["notes"] as? String == "Test")
        #expect(json["pet_id"] as? Int == 22)
        // Verify camelCase keys are not present
        #expect(json["startDate"] == nil)
        #expect(json["endDate"] == nil)
        #expect(json["petId"] == nil)
    }

    // MARK: - TabletCreateRequest Tests

    @Test func tabletCreateRequestEncodesCorrectly() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let request = TabletCreateRequest(
            name: "Heartgard",
            dosage: "50mg",
            frequency: "Monthly",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
            notes: "Give with food"
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "Heartgard")
        #expect(json["dosage"] as? String == "50mg")
        #expect(json["frequency"] as? String == "Monthly")
        #expect(json["start_date"] != nil)
        #expect(json["end_date"] != nil)
        #expect(json["notes"] as? String == "Give with food")
    }

    @Test func tabletCreateRequestEncodesWithNilOptionals() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let request = TabletCreateRequest(
            name: "Heartgard",
            dosage: nil,
            frequency: nil,
            startDate: Date(),
            endDate: nil,
            notes: nil
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "Heartgard")
        #expect(json["start_date"] != nil)
    }

    // MARK: - TabletUpdateRequest Tests

    @Test func tabletUpdateRequestEncodesAllFields() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        var request = TabletUpdateRequest()
        request.name = "Updated Name"
        request.dosage = "100mg"
        request.frequency = "Daily"
        request.startDate = Date()
        request.endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        request.notes = "Updated notes"

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "Updated Name")
        #expect(json["dosage"] as? String == "100mg")
        #expect(json["frequency"] as? String == "Daily")
        #expect(json["start_date"] != nil)
        #expect(json["end_date"] != nil)
        #expect(json["notes"] as? String == "Updated notes")
    }

    @Test func tabletUpdateRequestEncodesPartialUpdate() throws {
        let encoder = JSONEncoder()

        var request = TabletUpdateRequest()
        request.name = "New Name"

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "New Name")
    }

    @Test func tabletUpdateRequestUsesSnakeCaseKeys() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        var request = TabletUpdateRequest()
        request.startDate = Date()
        request.endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Verify snake_case keys
        #expect(json["start_date"] != nil)
        #expect(json["end_date"] != nil)
        // Verify camelCase NOT present
        #expect(json["startDate"] == nil)
        #expect(json["endDate"] == nil)
    }

    // MARK: - Equatable Tests

    @Test func tabletsWithSamePropertiesAreEqual() {
        let date = Date()
        let tablet1 = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: "50mg",
            frequency: "Monthly",
            startDate: date,
            endDate: nil,
            notes: nil,
            petId: 22
        )
        let tablet2 = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: "50mg",
            frequency: "Monthly",
            startDate: date,
            endDate: nil,
            notes: nil,
            petId: 22
        )

        #expect(tablet1 == tablet2)
    }

    @Test func tabletsWithDifferentIdsAreNotEqual() {
        let date = Date()
        let tablet1 = Tablet(
            id: 1,
            name: "Heartgard",
            dosage: "50mg",
            frequency: "Monthly",
            startDate: date,
            endDate: nil,
            notes: nil,
            petId: 22
        )
        let tablet2 = Tablet(
            id: 2,
            name: "Heartgard",
            dosage: "50mg",
            frequency: "Monthly",
            startDate: date,
            endDate: nil,
            notes: nil,
            petId: 22
        )

        #expect(tablet1 != tablet2)
    }
}
