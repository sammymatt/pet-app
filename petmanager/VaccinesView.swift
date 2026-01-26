//
//  VaccinesView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI

struct Vaccine: Identifiable {
    let id = UUID()
    let name: String
    let dateAdministered: Date
    let nextDue: Date?
    let veterinarian: String
    let isUpToDate: Bool
}

struct VaccinesView: View {
    @Environment(\.dismiss) var dismiss

    // Sample data
    let vaccines: [Vaccine] = [
        Vaccine(
            name: "Rabies",
            dateAdministered: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            nextDue: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
            veterinarian: "Dr. Smith",
            isUpToDate: true
        ),
        Vaccine(
            name: "DHPP",
            dateAdministered: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            nextDue: Calendar.current.date(byAdding: .month, value: 9, to: Date()),
            veterinarian: "Dr. Smith",
            isUpToDate: true
        ),
        Vaccine(
            name: "Bordetella",
            dateAdministered: Calendar.current.date(byAdding: .month, value: -11, to: Date())!,
            nextDue: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
            veterinarian: "Dr. Johnson",
            isUpToDate: true
        ),
        Vaccine(
            name: "Leptospirosis",
            dateAdministered: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
            nextDue: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
            veterinarian: "Dr. Smith",
            isUpToDate: false
        )
    ]

    var upToDateCount: Int {
        vaccines.filter { $0.isUpToDate }.count
    }

    var body: some View {
        ZStack {
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
                    VStack(spacing: 8) {
                        Image(systemName: "syringe.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text("Vaccines")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("\(upToDateCount) of \(vaccines.count) up to date")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)

                    // Vaccine List
                    VStack(spacing: 12) {
                        ForEach(vaccines) { vaccine in
                            VaccineCard(vaccine: vaccine)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Add Vaccine Button
                    Button(action: {
                        // TODO: Implement add vaccine
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Vaccine Record")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 1.0, green: 0.6, blue: 0.4).opacity(0.8))
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
    }
}

struct VaccineCard: View {
    let vaccine: Vaccine

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(vaccine.isUpToDate ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: vaccine.isUpToDate ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(vaccine.isUpToDate ? .green : .red)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(vaccine.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Given: \(dateFormatter.string(from: vaccine.dateAdministered))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                if let nextDue = vaccine.nextDue {
                    Text("Next due: \(dateFormatter.string(from: nextDue))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(vaccine.isUpToDate ? .white.opacity(0.7) : .red.opacity(0.9))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        VaccinesView()
    }
}
