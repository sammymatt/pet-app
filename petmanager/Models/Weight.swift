//
//  Weight.swift
//  petmanager
//
//  Created by Sam Matthews on 08/02/2026.
//

import Foundation

struct Weight: Identifiable, Codable, Equatable {
    let id: Int
    let weight: Double
    let recordedAt: Date
    let notes: String?
    let petId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case weight
        case recordedAt = "recorded_at"
        case notes
        case petId = "pet_id"
    }
}

struct WeightCreateRequest: Codable {
    let weight: Double
    let notes: String?
    let recordedAt: Date?

    enum CodingKeys: String, CodingKey {
        case weight
        case notes
        case recordedAt = "recorded_at"
    }
}

struct WeightUpdateRequest: Codable {
    var weight: Double?
    var notes: String?
    var recordedAt: Date?

    enum CodingKeys: String, CodingKey {
        case weight
        case notes
        case recordedAt = "recorded_at"
    }
}
