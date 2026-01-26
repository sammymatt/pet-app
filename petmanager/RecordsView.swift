//
//  RecordsView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI

struct MedicalRecord: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let category: RecordCategory
    let veterinarian: String
    let clinic: String
    let notes: String?
    let cost: Double?
}

enum RecordCategory: String, CaseIterable {
    case checkup = "Checkup"
    case vaccination = "Vaccination"
    case surgery = "Surgery"
    case dental = "Dental"
    case emergency = "Emergency"
    case other = "Other"

    var icon: String {
        switch self {
        case .checkup: return "stethoscope"
        case .vaccination: return "syringe.fill"
        case .surgery: return "bandage.fill"
        case .dental: return "mouth.fill"
        case .emergency: return "cross.circle.fill"
        case .other: return "doc.text.fill"
        }
    }

    var color: Color {
        switch self {
        case .checkup: return Color(red: 0.4, green: 0.8, blue: 0.6)
        case .vaccination: return Color(red: 1.0, green: 0.6, blue: 0.4)
        case .surgery: return Color(red: 0.9, green: 0.5, blue: 0.7)
        case .dental: return Color(red: 0.5, green: 0.7, blue: 1.0)
        case .emergency: return Color.red
        case .other: return Color(red: 0.8, green: 0.8, blue: 0.4)
        }
    }
}

struct RecordsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: RecordCategory? = nil

    // Sample data
    let records: [MedicalRecord] = [
        MedicalRecord(
            title: "Annual Checkup",
            date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            category: .checkup,
            veterinarian: "Dr. Smith",
            clinic: "Happy Paws Clinic",
            notes: "All vitals normal. Weight healthy.",
            cost: 85.00
        ),
        MedicalRecord(
            title: "Rabies Vaccination",
            date: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            category: .vaccination,
            veterinarian: "Dr. Smith",
            clinic: "Happy Paws Clinic",
            notes: nil,
            cost: 45.00
        ),
        MedicalRecord(
            title: "Dental Cleaning",
            date: Calendar.current.date(byAdding: .month, value: -8, to: Date())!,
            category: .dental,
            veterinarian: "Dr. Johnson",
            clinic: "Pet Dental Care",
            notes: "Minor tartar buildup removed. Recommend dental chews.",
            cost: 250.00
        ),
        MedicalRecord(
            title: "Spay Surgery",
            date: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
            category: .surgery,
            veterinarian: "Dr. Williams",
            clinic: "City Vet Hospital",
            notes: "Routine procedure. Recovery normal.",
            cost: 400.00
        ),
        MedicalRecord(
            title: "DHPP Vaccination",
            date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            category: .vaccination,
            veterinarian: "Dr. Smith",
            clinic: "Happy Paws Clinic",
            notes: nil,
            cost: 55.00
        )
    ]

    var filteredRecords: [MedicalRecord] {
        if let category = selectedCategory {
            return records.filter { $0.category == category }
        }
        return records.sorted { $0.date > $1.date }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
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
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text("Medical Records")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("\(records.count) records")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)

                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                color: .white
                            ) {
                                selectedCategory = nil
                            }

                            ForEach(RecordCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Records List
                    VStack(spacing: 12) {
                        ForEach(filteredRecords) { record in
                            RecordCard(record: record)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Add Record Button
                    Button(action: {
                        // TODO: Implement add record
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Medical Record")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.8, green: 0.8, blue: 0.4).opacity(0.8))
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

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.3))
                )
        }
    }
}

struct RecordCard: View {
    let record: MedicalRecord

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(record.category.color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: record.category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(record.category.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(dateFormatter.string(from: record.date))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                if let cost = record.cost {
                    Text(currencyFormatter.string(from: NSNumber(value: cost)) ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            HStack(spacing: 16) {
                Label(record.veterinarian, systemImage: "person.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Label(record.clinic, systemImage: "building.2.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }

            if let notes = record.notes {
                Text(notes)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
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
        RecordsView()
    }
}
