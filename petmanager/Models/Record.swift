//
//  Record.swift
//  petmanager
//
//  Created by Sam Matthews on 06/02/2026.
//

import Foundation

struct RecordsResponse: Codable {
    let vaccines: [VaccineRecord]
    let tablets: [TabletRecord]
    let appointments: [AppointmentRecord]
}

struct VaccineRecord: Identifiable, Codable {
    let id: Int
    let name: String
    let administeredDate: Date
    let nextDueDate: Date?
    let administeredBy: String?
    let frequency: String?
    let upToDate: Bool?
    let petId: Int
    let petName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case administeredDate = "administered_date"
        case nextDueDate = "next_due_date"
        case administeredBy = "administered_by"
        case frequency
        case upToDate = "up_to_date"
        case petId = "pet_id"
        case petName = "pet_name"
    }
}

struct TabletRecord: Identifiable, Codable {
    let id: Int
    let name: String
    let dosage: String?
    let frequency: String?
    let startDate: Date?
    let endDate: Date?
    let notes: String?
    let petId: Int
    let petName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dosage
        case frequency
        case startDate = "start_date"
        case endDate = "end_date"
        case notes
        case petId = "pet_id"
        case petName = "pet_name"
    }
}

struct AppointmentRecord: Identifiable, Codable {
    let id: Int
    let appointmentDate: Date
    let reason: String
    let vetName: String?
    let location: String?
    let status: String
    let petId: Int
    let petName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case appointmentDate = "appointment_date"
        case reason
        case vetName = "vet_name"
        case location
        case status
        case petId = "pet_id"
        case petName = "pet_name"
    }
}
