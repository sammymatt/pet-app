//
//  RecordsView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI
import Combine

enum RecordType: String, CaseIterable {
    case all = "All"
    case vaccines = "Vaccines"
    case tablets = "Tablets"
    case appointments = "Appointments"

    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .vaccines: return "syringe.fill"
        case .tablets: return "pills.fill"
        case .appointments: return "calendar.badge.clock"
        }
    }

    var color: Color {
        switch self {
        case .all: return .white
        case .vaccines: return Color(red: 1.0, green: 0.6, blue: 0.4)
        case .tablets: return Color(red: 0.5, green: 0.7, blue: 1.0)
        case .appointments: return Color(red: 0.9, green: 0.5, blue: 0.7)
        }
    }
}

// Unified record for sorting all types together
enum UnifiedRecord: Identifiable {
    case vaccine(VaccineRecord)
    case tablet(TabletRecord)
    case appointment(AppointmentRecord)

    var id: String {
        switch self {
        case .vaccine(let v): return "vaccine-\(v.id)"
        case .tablet(let t): return "tablet-\(t.id)"
        case .appointment(let a): return "appointment-\(a.id)"
        }
    }

    var date: Date {
        switch self {
        case .vaccine(let v): return v.administeredDate
        case .tablet(let t): return t.startDate ?? Date.distantPast
        case .appointment(let a): return a.appointmentDate
        }
    }
}

struct RecordsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: PetViewModel

    @State private var selectedType: RecordType = .all
    @State private var selectedPetId: Int? = nil
    @State private var records: RecordsResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()

    var totalRecordsCount: Int {
        guard let records = records else { return 0 }
        return records.vaccines.count + records.tablets.count + records.appointments.count
    }

    var allRecordsSortedByDate: [UnifiedRecord] {
        guard let records = records else { return [] }
        var unified: [UnifiedRecord] = []
        unified.append(contentsOf: records.vaccines.map { .vaccine($0) })
        unified.append(contentsOf: records.tablets.map { .tablet($0) })
        unified.append(contentsOf: records.appointments.map { .appointment($0) })
        return unified.sorted { $0.date > $1.date }
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

                        Text("\(totalRecordsCount) records")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)

                    // Pet Filter
                    if !viewModel.pets.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                PetFilterChip(
                                    title: "All Pets",
                                    isSelected: selectedPetId == nil
                                ) {
                                    selectedPetId = nil
                                    fetchRecords()
                                }

                                ForEach(viewModel.pets) { pet in
                                    PetFilterChip(
                                        title: pet.name,
                                        isSelected: selectedPetId == pet.id
                                    ) {
                                        selectedPetId = pet.id
                                        fetchRecords()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Type Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(RecordType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    isSelected: selectedType == type,
                                    color: type.color
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Records List
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                            .padding(.vertical, 40)
                    } else if let error = errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.6))
                            Text(error)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    } else if totalRecordsCount == 0 {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No records found")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 12) {
                            if selectedType == .all {
                                // Show all records sorted by date
                                ForEach(allRecordsSortedByDate) { record in
                                    switch record {
                                    case .vaccine(let vaccine):
                                        VaccineRecordCard(vaccine: vaccine)
                                    case .tablet(let tablet):
                                        TabletRecordCard(tablet: tablet)
                                    case .appointment(let appointment):
                                        AppointmentRecordCard(appointment: appointment)
                                    }
                                }
                            } else if selectedType == .vaccines,
                                      let vaccines = records?.vaccines, !vaccines.isEmpty {
                                ForEach(vaccines) { vaccine in
                                    VaccineRecordCard(vaccine: vaccine)
                                }
                            } else if selectedType == .tablets,
                                      let tablets = records?.tablets, !tablets.isEmpty {
                                ForEach(tablets) { tablet in
                                    TabletRecordCard(tablet: tablet)
                                }
                            } else if selectedType == .appointments,
                                      let appointments = records?.appointments, !appointments.isEmpty {
                                ForEach(appointments) { appointment in
                                    AppointmentRecordCard(appointment: appointment)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 20)
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
        .onAppear {
            fetchRecords()
        }
    }

    private func fetchRecords() {
        isLoading = true
        errorMessage = nil

        let publisher: AnyPublisher<RecordsResponse, Error>

        if let petId = selectedPetId {
            publisher = PetService.shared.fetchPetRecords(petId: petId)
        } else {
            // Default to user ID 1 for now - in a real app this would come from auth
            publisher = PetService.shared.fetchUserRecords(userId: 1)
        }

        publisher
            .sink(receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = "Failed to load records"
                    print("Error fetching records: \(error)")
                }
            }, receiveValue: { response in
                records = response
            })
            .store(in: &cancellables)
    }
}

// MARK: - Pet Filter Chip

struct PetFilterChip: View {
    let title: String
    let isSelected: Bool
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
                        .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
    }
}

// MARK: - Filter Chip

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

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - Vaccine Record Card

struct VaccineRecordCard: View {
    let vaccine: VaccineRecord

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(RecordType.vaccines.color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "syringe.fill")
                        .font(.system(size: 20))
                        .foregroundColor(RecordType.vaccines.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(vaccine.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(dateFormatter.string(from: vaccine.administeredDate))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                if let petName = vaccine.petName {
                    Text(petName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }

            HStack(spacing: 16) {
                if let administeredBy = vaccine.administeredBy, !administeredBy.isEmpty {
                    Label(administeredBy, systemImage: "person.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                if let frequency = vaccine.frequency, !frequency.isEmpty {
                    Label(frequency, systemImage: "repeat")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Status badge
            if let upToDate = vaccine.upToDate {
                Text(upToDate ? "Confirmed" : "Missed")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(upToDate ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill((upToDate ? Color.green : Color.red).opacity(0.2))
                    )
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

// MARK: - Tablet Record Card

struct TabletRecordCard: View {
    let tablet: TabletRecord

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(RecordType.tablets.color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "pills.fill")
                        .font(.system(size: 20))
                        .foregroundColor(RecordType.tablets.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(tablet.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if let dosage = tablet.dosage, !dosage.isEmpty {
                        Text(dosage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                if let petName = tablet.petName {
                    Text(petName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }

            HStack(spacing: 16) {
                if let frequency = tablet.frequency, !frequency.isEmpty {
                    Label(frequency, systemImage: "repeat")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                if let startDate = tablet.startDate {
                    Label("From: \(dateFormatter.string(from: startDate))", systemImage: "calendar")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            if let notes = tablet.notes, !notes.isEmpty {
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

// MARK: - Appointment Record Card

struct AppointmentRecordCard: View {
    let appointment: AppointmentRecord

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var statusColor: Color {
        switch appointment.status.lowercased() {
        case "completed": return .green
        case "cancelled": return .red
        case "scheduled": return .blue
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(RecordType.appointments.color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundColor(RecordType.appointments.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(appointment.reason)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(dateFormatter.string(from: appointment.appointmentDate))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                if let petName = appointment.petName {
                    Text(petName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }

            HStack(spacing: 16) {
                if let vetName = appointment.vetName, !vetName.isEmpty {
                    Label(vetName, systemImage: "person.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                if let location = appointment.location, !location.isEmpty {
                    Label(location, systemImage: "building.2.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }

            // Status badge
            Text(appointment.status.capitalized)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.2))
                )
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
            .environmentObject(PetViewModel())
    }
}
