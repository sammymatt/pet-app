//
//  VaccineModelTests.swift
//  petmanagerTests
//
//  Created by Sam Matthews on 06/02/2026.
//

import Testing
import Foundation
@testable import petmanager

struct VaccineModelTests {

    // MARK: - Initialization Tests

    @Test func initializesWithAllProperties() {
        let administeredDate = Date()
        let nextDueDate = Calendar.current.date(byAdding: .year, value: 1, to: administeredDate)!
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: administeredDate,
            nextDueDate: nextDueDate,
            administeredBy: "Dr. Smith",
            notes: "3-year vaccine",
            frequency: "Annual",
            upToDate: true,
            petId: 22
        )

        #expect(vaccine.id == 1)
        #expect(vaccine.name == "Rabies")
        #expect(vaccine.administeredDate == administeredDate)
        #expect(vaccine.nextDueDate == nextDueDate)
        #expect(vaccine.administeredBy == "Dr. Smith")
        #expect(vaccine.notes == "3-year vaccine")
        #expect(vaccine.frequency == "Annual")
        #expect(vaccine.upToDate == true)
        #expect(vaccine.petId == 22)
    }

    @Test func initializesWithNilOptionalFields() {
        let administeredDate = Date()
        let vaccine = Vaccine(
            id: 1,
            name: "Distemper",
            administeredDate: administeredDate,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )

        #expect(vaccine.nextDueDate == nil)
        #expect(vaccine.administeredBy == nil)
        #expect(vaccine.notes == nil)
        #expect(vaccine.frequency == nil)
        #expect(vaccine.upToDate == nil)
    }

    // MARK: - isUpToDate Computed Property Tests

    @Test func isUpToDateReturnsTrueWhenUpToDateIsTrue() {
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: true,
            petId: 22
        )

        #expect(vaccine.isUpToDate == true)
    }

    @Test func isUpToDateReturnsFalseWhenUpToDateIsFalse() {
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: false,
            petId: 22
        )

        #expect(vaccine.isUpToDate == false)
    }

    @Test func isUpToDateReturnsFalseWhenUpToDateIsNil() {
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )

        #expect(vaccine.isUpToDate == false)
    }

    // MARK: - needsConfirmation Computed Property Tests

    @Test func needsConfirmationReturnsTrueWhenDatePassedAndUpToDateIsNil() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: pastDate,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )

        #expect(vaccine.needsConfirmation == true)
    }

    @Test func needsConfirmationReturnsFalseWhenDateInFuture() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: futureDate,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )

        #expect(vaccine.needsConfirmation == false)
    }

    @Test func needsConfirmationReturnsFalseWhenAlreadyConfirmed() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: pastDate,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: true,
            petId: 22
        )

        #expect(vaccine.needsConfirmation == false)
    }

    // MARK: - wasMissed Computed Property Tests

    @Test func wasMissedReturnsTrueWhenUpToDateIsFalse() {
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: false,
            petId: 22
        )

        #expect(vaccine.wasMissed == true)
    }

    @Test func wasMissedReturnsFalseWhenUpToDateIsTrue() {
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: true,
            petId: 22
        )

        #expect(vaccine.wasMissed == false)
    }

    @Test func wasMissedReturnsFalseWhenUpToDateIsNil() {
        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )

        #expect(vaccine.wasMissed == false)
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
            "name": "Rabies",
            "administered_date": "2026-01-15",
            "next_due_date": "2027-01-15",
            "administered_by": "Dr. Smith",
            "notes": "Annual booster",
            "frequency": "Annual",
            "up_to_date": true,
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let vaccine = try decoder.decode(Vaccine.self, from: json)

        #expect(vaccine.id == 1)
        #expect(vaccine.name == "Rabies")
        #expect(vaccine.administeredBy == "Dr. Smith")
        #expect(vaccine.notes == "Annual booster")
        #expect(vaccine.frequency == "Annual")
        #expect(vaccine.upToDate == true)
        #expect(vaccine.petId == 22)
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
            "name": "Distemper",
            "administered_date": "2026-01-15",
            "next_due_date": null,
            "administered_by": null,
            "notes": null,
            "frequency": null,
            "up_to_date": null,
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let vaccine = try decoder.decode(Vaccine.self, from: json)

        #expect(vaccine.nextDueDate == nil)
        #expect(vaccine.administeredBy == nil)
        #expect(vaccine.notes == nil)
        #expect(vaccine.frequency == nil)
        #expect(vaccine.upToDate == nil)
    }

    @Test func encodesToJSONWithSnakeCaseKeys() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let vaccine = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: "Dr. Smith",
            notes: nil,
            frequency: "Annual",
            upToDate: true,
            petId: 22
        )

        let data = try encoder.encode(vaccine)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["administered_date"] != nil)
        #expect(json["administered_by"] as? String == "Dr. Smith")
        #expect(json["frequency"] as? String == "Annual")
        #expect(json["up_to_date"] as? Bool == true)
        #expect(json["pet_id"] as? Int == 22)
        // Verify camelCase keys are not present
        #expect(json["administeredDate"] == nil)
        #expect(json["administeredBy"] == nil)
        #expect(json["petId"] == nil)
        #expect(json["upToDate"] == nil)
    }

    // MARK: - VaccineCreateRequest Tests

    @Test func vaccineCreateRequestEncodesCorrectly() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let request = VaccineCreateRequest(
            name: "Rabies",
            administeredDate: Date(),
            nextDueDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            administeredBy: "Dr. Jones",
            notes: "3-year vaccine",
            frequency: "Annual"
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "Rabies")
        #expect(json["administered_date"] != nil)
        #expect(json["next_due_date"] != nil)
        #expect(json["administered_by"] as? String == "Dr. Jones")
        #expect(json["notes"] as? String == "3-year vaccine")
        #expect(json["frequency"] as? String == "Annual")
    }

    @Test func vaccineCreateRequestEncodesNilOptionals() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let request = VaccineCreateRequest(
            name: "Distemper",
            administeredDate: Date(),
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "Distemper")
        #expect(json["administered_date"] != nil)
    }

    // MARK: - VaccineUpdateRequest Tests

    @Test func vaccineUpdateRequestEncodesAllFields() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        var request = VaccineUpdateRequest()
        request.name = "Updated Rabies"
        request.administeredDate = Date()
        request.nextDueDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())
        request.administeredBy = "Dr. New"
        request.notes = "Updated notes"
        request.frequency = "Triennial"
        request.upToDate = true

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "Updated Rabies")
        #expect(json["administered_date"] != nil)
        #expect(json["next_due_date"] != nil)
        #expect(json["administered_by"] as? String == "Dr. New")
        #expect(json["notes"] as? String == "Updated notes")
        #expect(json["frequency"] as? String == "Triennial")
        #expect(json["up_to_date"] as? Bool == true)
    }

    @Test func vaccineUpdateRequestEncodesPartialUpdate() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        // Only updating name - all other fields nil
        var request = VaccineUpdateRequest()
        request.name = "New Name"

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "New Name")
    }

    @Test func vaccineUpdateRequestEncodesUpToDateOnly() throws {
        let encoder = JSONEncoder()

        var request = VaccineUpdateRequest()
        request.upToDate = true

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["up_to_date"] as? Bool == true)
    }

    @Test func vaccineUpdateRequestUsesSnakeCaseKeys() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        var request = VaccineUpdateRequest()
        request.administeredDate = Date()
        request.administeredBy = "Dr. Test"
        request.nextDueDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        request.upToDate = false

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Verify snake_case keys are used
        #expect(json["administered_date"] != nil)
        #expect(json["administered_by"] != nil)
        #expect(json["next_due_date"] != nil)
        #expect(json["up_to_date"] != nil)
        // Verify camelCase keys are NOT present
        #expect(json["administeredDate"] == nil)
        #expect(json["administeredBy"] == nil)
        #expect(json["nextDueDate"] == nil)
        #expect(json["upToDate"] == nil)
    }

    // MARK: - Equatable Tests

    @Test func vaccinesWithSameIdAreEqual() {
        let date = Date()
        let vaccine1 = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: date,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )
        let vaccine2 = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: date,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )

        #expect(vaccine1 == vaccine2)
    }

    @Test func vaccinesWithDifferentIdsAreNotEqual() {
        let date = Date()
        let vaccine1 = Vaccine(
            id: 1,
            name: "Rabies",
            administeredDate: date,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )
        let vaccine2 = Vaccine(
            id: 2,
            name: "Rabies",
            administeredDate: date,
            nextDueDate: nil,
            administeredBy: nil,
            notes: nil,
            frequency: nil,
            upToDate: nil,
            petId: 22
        )

        #expect(vaccine1 != vaccine2)
    }
}
