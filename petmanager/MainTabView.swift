//
//  MainTabView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Pets", systemImage: "dog.fill")
                }
            
            HealthView()
                .tabItem {
                    Label("Health", systemImage: "heart.text.square.fill")
                }
        }
        .accentColor(Color(red: 0.6, green: 0.4, blue: 0.9))
    }
}

#Preview {
    MainTabView()
}
