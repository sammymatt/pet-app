//
//  SupabaseManager.swift
//  petmanager
//
//  Created by Sam Matthews on 26/02/2026.
//

import Foundation
import Supabase

struct SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Secrets.supabaseURL)!,
            supabaseKey: Secrets.supabaseKey
        )
    }
}
