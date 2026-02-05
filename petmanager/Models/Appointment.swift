//
//  Appointment.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import Foundation

struct Appointment: Identifiable, Codable, Equatable {
    let id: Int
    let appointmentDate: Date
    let reason: String
    let vetName: String?
    let location: String?
    let notes: String?
    let status: String
    let petId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case appointmentDate = "appointment_date"
        case reason
        case vetName = "vet_name"
        case location
        case notes
        case status
        case petId = "pet_id"
    }

    /// Computed property: true if the appointment date is today or in the future
    var isUpcoming: Bool {
        Calendar.current.startOfDay(for: appointmentDate) >= Calendar.current.startOfDay(for: Date())
    }
}

struct AppointmentRequest: Codable {
    let appointmentDate: Date
    let reason: String
    let vetName: String?
    let location: String?
    let notes: String?
    let status: String

    enum CodingKeys: String, CodingKey {
        case appointmentDate = "appointment_date"
        case reason
        case vetName = "vet_name"
        case location
        case notes
        case status
    }
}

struct AppointmentUpdateRequest: Codable {
    var appointmentDate: Date?
    var reason: String?
    var vetName: String?
    var location: String?
    var notes: String?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case appointmentDate = "appointment_date"
        case reason
        case vetName = "vet_name"
        case location
        case notes
        case status
    }
}
