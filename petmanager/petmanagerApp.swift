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
    @State private var authViewModel = AuthViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoading {
                    ZStack {
                        AppBackground(style: .login)
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                } else if authViewModel.isLoggedIn {
                    MainTabView()
                        .environmentObject(petViewModel)
                        .environment(authViewModel)
                } else {
                    LoginView()
                        .environment(authViewModel)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
