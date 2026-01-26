//
//  TabletsView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI

struct Medication: Identifiable {
    let id = UUID()
    let name: String
    let dosage: String
    let frequency: String
    let timeOfDay: String
    let startDate: Date
    let endDate: Date?
    let notes: String?
    let isActive: Bool
}

struct TabletsView: View {
    @Environment(\.dismiss) var dismiss

    // Sample data
    let medications: [Medication] = [
        Medication(
            name: "Heartworm Prevention",
            dosage: "1 tablet",
            frequency: "Monthly",
            timeOfDay: "Morning",
            startDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            endDate: nil,
            notes: "Give with food",
            isActive: true
        ),
        Medication(
            name: "Flea & Tick",
            dosage: "1 chewable",
            frequency: "Monthly",
            timeOfDay: "Evening",
            startDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            endDate: nil,
            notes: nil,
            isActive: true
        ),
        Medication(
            name: "Joint Supplement",
            dosage: "2 tablets",
            frequency: "Daily",
            timeOfDay: "With breakfast",
            startDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            endDate: nil,
            notes: "For hip support",
            isActive: true
        ),
        Medication(
            name: "Antibiotic",
            dosage: "250mg",
            frequency: "Twice daily",
            timeOfDay: "Morning & Evening",
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            notes: "For ear infection",
            isActive: false
        )
    ]

    var activeMedications: [Medication] {
        medications.filter { $0.isActive }
    }

    var pastMedications: [Medication] {
        medications.filter { !$0.isActive }
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
                        Image(systemName: "pills.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text("Medications")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("\(activeMedications.count) active medications")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)

                    // Active Medications
                    if !activeMedications.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)

                            ForEach(activeMedications) { medication in
                                MedicationCard(medication: medication)
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Past Medications
                    if !pastMedications.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Past")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 20)

                            ForEach(pastMedications) { medication in
                                MedicationCard(medication: medication)
                                    .opacity(0.6)
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Add Medication Button
                    Button(action: {
                        // TODO: Implement add medication
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Medication")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.8))
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

struct MedicationCard: View {
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(medication.dosage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                if medication.isActive {
                    Text(medication.frequency)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.5))
                        )
                }
            }

            HStack(spacing: 16) {
                Label(medication.timeOfDay, systemImage: "clock.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                if let notes = medication.notes {
                    Label(notes, systemImage: "note.text")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
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
        TabletsView()
    }
}
