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
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView()
                    .environmentObject(petViewModel)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
