//
//  Tablet.swift
//  petmanager
//
//  Created by Sam Matthews on 08/02/2026.
//

import Foundation

struct Tablet: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let dosage: String?
    let frequency: String?
    let startDate: Date
    let endDate: Date?
    let notes: String?
    let petId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dosage
        case frequency
        case startDate = "start_date"
        case endDate = "end_date"
        case notes
        case petId = "pet_id"
    }

    /// Returns true if the medication is currently active (no end date or end date is in the future)
    var isActive: Bool {
        guard let endDate = endDate else { return true }
        return endDate >= Date()
    }
}

struct TabletCreateRequest: Codable {
    let name: String
    let dosage: String?
    let frequency: String?
    let startDate: Date
    let endDate: Date?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name
        case dosage
        case frequency
        case startDate = "start_date"
        case endDate = "end_date"
        case notes
    }
}

struct TabletUpdateRequest: Codable {
    var name: String?
    var dosage: String?
    var frequency: String?
    var startDate: Date?
    var endDate: Date?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case name
        case dosage
        case frequency
        case startDate = "start_date"
        case endDate = "end_date"
        case notes
    }
}
