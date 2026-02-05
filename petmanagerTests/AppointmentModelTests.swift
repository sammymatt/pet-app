//
//  AppointmentModelTests.swift
//  petmanagerTests
//
//  Created by Sam Matthews on 25/01/2026.
//

import Testing
import Foundation
@testable import petmanager

struct AppointmentModelTests {

    // MARK: - Initialization Tests

    @Test func initializesWithAllProperties() {
        let date = Date()
        let appointment = Appointment(
            id: 1,
            appointmentDate: date,
            reason: "Annual Checkup",
            vetName: "Dr. Smith",
            location: "Happy Paws Clinic",
            notes: "Bring vaccination records",
            status: "scheduled",
            petId: 22
        )

        #expect(appointment.id == 1)
        #expect(appointment.appointmentDate == date)
        #expect(appointment.reason == "Annual Checkup")
        #expect(appointment.vetName == "Dr. Smith")
        #expect(appointment.location == "Happy Paws Clinic")
        #expect(appointment.notes == "Bring vaccination records")
        #expect(appointment.status == "scheduled")
        #expect(appointment.petId == 22)
    }

    @Test func initializesWithNilOptionalFields() {
        let date = Date()
        let appointment = Appointment(
            id: 1,
            appointmentDate: date,
            reason: "Checkup",
            vetName: nil,
            location: nil,
            notes: nil,
            status: "scheduled",
            petId: 22
        )

        #expect(appointment.vetName == nil)
        #expect(appointment.location == nil)
        #expect(appointment.notes == nil)
    }

    // MARK: - isUpcoming Computed Property Tests

    @Test func isUpcomingReturnsTrueForFutureDate() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let appointment = Appointment(
            id: 1,
            appointmentDate: futureDate,
            reason: "Checkup",
            vetName: nil,
            location: nil,
            notes: nil,
            status: "scheduled",
            petId: 22
        )

        #expect(appointment.isUpcoming == true)
    }

    @Test func isUpcomingReturnsTrueForToday() {
        let today = Date()
        let appointment = Appointment(
            id: 1,
            appointmentDate: today,
            reason: "Checkup",
            vetName: nil,
            location: nil,
            notes: nil,
            status: "scheduled",
            petId: 22
        )

        #expect(appointment.isUpcoming == true)
    }

    @Test func isUpcomingReturnsFalseForPastDate() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let appointment = Appointment(
            id: 1,
            appointmentDate: pastDate,
            reason: "Checkup",
            vetName: nil,
            location: nil,
            notes: nil,
            status: "completed",
            petId: 22
        )

        #expect(appointment.isUpcoming == false)
    }

    // MARK: - Codable Tests

    @Test func decodesFromJSONWithSnakeCaseKeys() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let json = """
        {
            "id": 1,
            "appointment_date": "2026-02-10T10:30:00Z",
            "reason": "Annual Checkup",
            "vet_name": "Dr. Smith",
            "location": "Happy Paws Clinic",
            "notes": "Bring records",
            "status": "scheduled",
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let appointment = try decoder.decode(Appointment.self, from: json)

        #expect(appointment.id == 1)
        #expect(appointment.reason == "Annual Checkup")
        #expect(appointment.vetName == "Dr. Smith")
        #expect(appointment.location == "Happy Paws Clinic")
        #expect(appointment.notes == "Bring records")
        #expect(appointment.status == "scheduled")
        #expect(appointment.petId == 22)
    }

    @Test func decodesFromJSONWithNullOptionalFields() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let json = """
        {
            "id": 1,
            "appointment_date": "2026-02-10T10:30:00Z",
            "reason": "Checkup",
            "vet_name": null,
            "location": null,
            "notes": null,
            "status": "scheduled",
            "pet_id": 22
        }
        """.data(using: .utf8)!

        let appointment = try decoder.decode(Appointment.self, from: json)

        #expect(appointment.vetName == nil)
        #expect(appointment.location == nil)
        #expect(appointment.notes == nil)
    }

    @Test func encodesToJSONWithSnakeCaseKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let appointment = Appointment(
            id: 1,
            appointmentDate: Date(),
            reason: "Checkup",
            vetName: "Dr. Smith",
            location: "Clinic",
            notes: nil,
            status: "scheduled",
            petId: 22
        )

        let data = try encoder.encode(appointment)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["appointment_date"] != nil)
        #expect(json["vet_name"] as? String == "Dr. Smith")
        #expect(json["pet_id"] as? Int == 22)
        // Verify camelCase keys are not present
        #expect(json["appointmentDate"] == nil)
        #expect(json["vetName"] == nil)
        #expect(json["petId"] == nil)
    }

    // MARK: - AppointmentRequest Tests

    @Test func appointmentRequestEncodesCorrectly() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let request = AppointmentRequest(
            appointmentDate: Date(),
            reason: "Vaccination",
            vetName: "Dr. Jones",
            location: "Pet Hospital",
            notes: "Fasting required",
            status: "scheduled"
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["appointment_date"] != nil)
        #expect(json["reason"] as? String == "Vaccination")
        #expect(json["vet_name"] as? String == "Dr. Jones")
        #expect(json["location"] as? String == "Pet Hospital")
        #expect(json["notes"] as? String == "Fasting required")
        #expect(json["status"] as? String == "scheduled")
    }

    @Test func appointmentRequestEncodesNilOptionals() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let request = AppointmentRequest(
            appointmentDate: Date(),
            reason: "Checkup",
            vetName: nil,
            location: nil,
            notes: nil,
            status: "scheduled"
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["reason"] as? String == "Checkup")
        #expect(json["status"] as? String == "scheduled")
    }

    // MARK: - AppointmentUpdateRequest Tests

    @Test func appointmentUpdateRequestEncodesAllFields() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let date = Date()
        let request = AppointmentUpdateRequest(
            appointmentDate: date,
            reason: "Updated Checkup",
            vetName: "Dr. New",
            location: "New Clinic",
            notes: "Updated notes",
            status: "completed"
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["appointment_date"] != nil)
        #expect(json["reason"] as? String == "Updated Checkup")
        #expect(json["vet_name"] as? String == "Dr. New")
        #expect(json["location"] as? String == "New Clinic")
        #expect(json["notes"] as? String == "Updated notes")
        #expect(json["status"] as? String == "completed")
    }

    @Test func appointmentUpdateRequestEncodesPartialUpdate() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        // Only updating status - all other fields nil
        let request = AppointmentUpdateRequest(
            appointmentDate: nil,
            reason: nil,
            vetName: nil,
            location: nil,
            notes: nil,
            status: "cancelled"
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["status"] as? String == "cancelled")
    }

    @Test func appointmentUpdateRequestEncodesOnlyChangedFields() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        // Updating just reason and status
        let request = AppointmentUpdateRequest(
            appointmentDate: nil,
            reason: "Follow-up Visit",
            vetName: nil,
            location: nil,
            notes: nil,
            status: "scheduled"
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["reason"] as? String == "Follow-up Visit")
        #expect(json["status"] as? String == "scheduled")
    }

    @Test func appointmentUpdateRequestUsesSnakeCaseKeys() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let request = AppointmentUpdateRequest(
            appointmentDate: Date(),
            reason: "Test",
            vetName: "Dr. Test",
            location: nil,
            notes: nil,
            status: nil
        )

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Verify snake_case keys are used
        #expect(json["appointment_date"] != nil)
        #expect(json["vet_name"] != nil)
        // Verify camelCase keys are NOT present
        #expect(json["appointmentDate"] == nil)
        #expect(json["vetName"] == nil)
    }
}
