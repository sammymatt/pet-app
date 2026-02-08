//
//  Vaccine.swift
//  petmanager
//
//  Created by Sam Matthews on 06/02/2026.
//

import Foundation

struct Vaccine: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let administeredDate: Date
    let nextDueDate: Date?
    let administeredBy: String?
    let notes: String?
    let frequency: String?
    let upToDate: Bool?
    let petId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case administeredDate = "administered_date"
        case nextDueDate = "next_due_date"
        case administeredBy = "administered_by"
        case notes
        case frequency
        case upToDate = "up_to_date"
        case petId = "pet_id"
    }

    /// Returns true if the vaccine is confirmed up to date
    var isUpToDate: Bool {
        upToDate ?? false
    }

    /// Returns true if the vaccine needs confirmation (scheduled date has passed but not confirmed)
    var needsConfirmation: Bool {
        administeredDate <= Date() && upToDate == nil
    }

    /// Returns true if the vaccine was missed (date passed and marked as not up to date)
    var wasMissed: Bool {
        upToDate == false
    }
}

struct VaccineCreateRequest: Codable {
    let name: String
    let administeredDate: Date
    let nextDueDate: Date?
    let administeredBy: String?
    let notes: String?
    let frequency: String?

    enum CodingKeys: String, CodingKey {
        case name
        case administeredDate = "administered_date"
        case nextDueDate = "next_due_date"
        case administeredBy = "administered_by"
        case notes
        case frequency
    }
}

struct VaccineUpdateRequest: Codable {
    var name: String?
    var administeredDate: Date?
    var nextDueDate: Date?
    var administeredBy: String?
    var notes: String?
    var frequency: String?
    var upToDate: Bool?

    enum CodingKeys: String, CodingKey {
        case name
        case administeredDate = "administered_date"
        case nextDueDate = "next_due_date"
        case administeredBy = "administered_by"
        case notes
        case frequency
        case upToDate = "up_to_date"
    }
}
