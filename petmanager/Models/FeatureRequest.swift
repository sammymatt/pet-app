//
//  FeatureRequest.swift
//  petmanager
//
//  Created by Sam Matthews on 12/02/2026.
//

import Foundation

struct FeatureRequest: Identifiable, Codable {
    let id: Int
    let title: String
    let category: String
    let description: String?
    let votes: Int
    let isImplemented: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case description
        case votes
        case isImplemented = "is_implemented"
    }
}

struct FeatureRequestCreate: Codable {
    let title: String
    let category: String
    let description: String?
}
