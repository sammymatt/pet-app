//
//  HomeView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.6, blue: 0.95),
                        Color(red: 0.6, green: 0.4, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text("Pet Pal")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Keep your furry friends healthy & happy")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Quick Stats Cards
                        VStack(spacing: 16) {
                            // Upcoming Reminders Card
                            QuickStatCard(
                                icon: "bell.fill",
                                title: "Upcoming Reminders",
                                value: "3",
                                subtitle: "Next: Vaccine on Feb 15",
                                color: Color(red: 1.0, green: 0.6, blue: 0.4)
                            )
                            
                            // Weight Tracking Card
                            QuickStatCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Weight Tracking",
                                value: "12.5 kg",
                                subtitle: "Last updated: Jan 20",
                                color: Color(red: 0.4, green: 0.8, blue: 0.6)
                            )
                            
                            // Vet Appointments Card
                            QuickStatCard(
                                icon: "cross.case.fill",
                                title: "Vet Appointments",
                                value: "1",
                                subtitle: "Next: Feb 28, 2:00 PM",
                                color: Color(red: 0.9, green: 0.5, blue: 0.7)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
}
