//
//  petmanagerApp.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

@main
struct petmanagerApp: App {
    @StateObject private var petViewModel = PetViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(petViewModel)
        }
    }
}
