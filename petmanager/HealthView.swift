//
//  HealthView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI

struct HealthView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.8, blue: 0.6),
                        Color(red: 0.3, green: 0.6, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text("Pet Health")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Manage care & records")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 40)
                        
                        // Widgets Grid
                        LazyVGrid(columns: columns, spacing: 20) {
                            // Vaccines Widget
                            NavigationLink(destination: VaccinesView()) {
                                HealthWidgetContent(
                                    title: "Vaccines",
                                    icon: "syringe.fill",
                                    color: Color(red: 1.0, green: 0.6, blue: 0.4),
                                    subtitle: "Up to date"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // Appointments Widget
                            NavigationLink(destination: AppointmentsView()) {
                                HealthWidgetContent(
                                    title: "Appointments",
                                    icon: "calendar.badge.clock",
                                    color: Color(red: 0.9, green: 0.5, blue: 0.7),
                                    subtitle: "1 upcoming"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // Tablets Widget
                            NavigationLink(destination: TabletsView()) {
                                HealthWidgetContent(
                                    title: "Tablets",
                                    icon: "pills.fill",
                                    color: Color(red: 0.5, green: 0.7, blue: 1.0),
                                    subtitle: "Daily meds"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // Medical Records
                            NavigationLink(destination: RecordsView()) {
                                HealthWidgetContent(
                                    title: "Records",
                                    icon: "doc.text.fill",
                                    color: Color(red: 0.8, green: 0.8, blue: 0.4),
                                    subtitle: "History"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HealthWidgetContent: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(height: 140)
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

struct HealthWidget: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        Button(action: {
            // Action placeholder
        }) {
            HealthWidgetContent(
                title: title,
                icon: icon,
                color: color,
                subtitle: subtitle
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    HealthView()
}
