//
//  VaccinesView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI
import Combine

struct VaccinesView: View {
    @Environment(\.dismiss) var dismiss

    let petId: Int

    @State private var vaccines: [Vaccine] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showingAddVaccine = false
    @State private var selectedVaccine: Vaccine?

    var upToDateCount: Int {
        vaccines.filter { $0.isUpToDate }.count
    }

    var needsAttentionCount: Int {
        vaccines.filter { $0.needsConfirmation || $0.wasMissed }.count
    }

    var sortedVaccines: [Vaccine] {
        vaccines.sorted { vaccine1, vaccine2 in
            // Priority: needs confirmation > missed > scheduled > confirmed
            let priority1 = vaccinePriority(vaccine1)
            let priority2 = vaccinePriority(vaccine2)
            if priority1 != priority2 {
                return priority1 < priority2
            }
            // Within same priority, sort by date
            return vaccine1.administeredDate < vaccine2.administeredDate
        }
    }

    private func vaccinePriority(_ vaccine: Vaccine) -> Int {
        if vaccine.needsConfirmation { return 0 }
        if vaccine.wasMissed { return 1 }
        if vaccine.administeredDate > Date() { return 2 } // Scheduled
        return 3 // Confirmed
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

                        if !vaccines.isEmpty {
                            if needsAttentionCount > 0 {
                                Text("\(needsAttentionCount) need\(needsAttentionCount == 1 ? "s" : "") attention")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.orange)
                            } else {
                                Text("\(upToDateCount) of \(vaccines.count) confirmed")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(.top, 20)

                    // Vaccine List
                    if !isLoading && vaccines.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "syringe")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No vaccines recorded")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(sortedVaccines) { vaccine in
                                VaccineCard(vaccine: vaccine)
                                    .onTapGesture {
                                        selectedVaccine = vaccine
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Add Vaccine Button
                    Button(action: {
                        showingAddVaccine = true
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

            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
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
            fetchVaccines()
        }
        .sheet(isPresented: $showingAddVaccine) {
            AddVaccineView(petId: petId) {
                fetchVaccines()
            }
        }
        .sheet(item: $selectedVaccine) { vaccine in
            VaccineDetailView(vaccine: vaccine, onUpdate: {
                fetchVaccines()
                selectedVaccine = nil
            })
        }
    }

    private func fetchVaccines() {
        isLoading = true
        errorMessage = nil

        PetService.shared.fetchVaccines(forPetId: petId)
            .sink(receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                    print("Error fetching vaccines: \(error)")
                }
            }, receiveValue: { fetchedVaccines in
                vaccines = fetchedVaccines
            })
            .store(in: &cancellables)
    }
}

struct VaccineCard: View {
    let vaccine: Vaccine

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var isScheduledForFuture: Bool {
        vaccine.administeredDate > Date()
    }

    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: statusIcon)
                    .font(.system(size: 24))
                    .foregroundColor(statusColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(vaccine.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if let frequency = vaccine.frequency, !frequency.isEmpty {
                        Text(frequency)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.25))
                            )
                    }
                }

                // Date display based on state
                if isScheduledForFuture {
                    Text("Scheduled: \(dateFormatter.string(from: vaccine.administeredDate))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue.opacity(0.9))
                } else {
                    Text("Date: \(dateFormatter.string(from: vaccine.administeredDate))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                // Status badge
                Text(statusLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(statusColor.opacity(0.2))
                    )

                if let administeredBy = vaccine.administeredBy, !administeredBy.isEmpty {
                    Text("By: \(administeredBy)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
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
                .stroke(vaccine.needsConfirmation ? statusColor : .white.opacity(0.3), lineWidth: vaccine.needsConfirmation ? 2 : 1)
        )
    }

    var statusColor: Color {
        if vaccine.needsConfirmation {
            return .orange
        } else if vaccine.wasMissed {
            return .red
        } else if isScheduledForFuture {
            return .blue
        } else if vaccine.isUpToDate {
            return .green
        } else {
            return .gray
        }
    }

    var statusIcon: String {
        if vaccine.needsConfirmation {
            return "questionmark.circle.fill"
        } else if vaccine.wasMissed {
            return "xmark.circle.fill"
        } else if isScheduledForFuture {
            return "calendar.circle.fill"
        } else if vaccine.isUpToDate {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }

    var statusLabel: String {
        if vaccine.needsConfirmation {
            return "Needs Confirmation"
        } else if vaccine.wasMissed {
            return "Missed"
        } else if isScheduledForFuture {
            return "Scheduled"
        } else if vaccine.isUpToDate {
            return "Confirmed"
        } else {
            return "Unknown"
        }
    }
}

// MARK: - Vaccine Detail View

struct VaccineDetailView: View {
    @Environment(\.dismiss) var dismiss

    let vaccine: Vaccine
    let onUpdate: () -> Void

    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var showingMissedAlert = false
    @State private var isDeleting = false
    @State private var isUpdating = false
    @State private var cancellables = Set<AnyCancellable>()

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var isScheduledForFuture: Bool {
        vaccine.administeredDate > Date()
    }

    var statusColor: Color {
        if vaccine.needsConfirmation {
            return .orange
        } else if vaccine.wasMissed {
            return .red
        } else if isScheduledForFuture {
            return .blue
        } else if vaccine.isUpToDate {
            return .green
        } else {
            return .gray
        }
    }

    var statusIcon: String {
        if vaccine.needsConfirmation {
            return "questionmark.circle.fill"
        } else if vaccine.wasMissed {
            return "xmark.circle.fill"
        } else if isScheduledForFuture {
            return "calendar.circle.fill"
        } else if vaccine.isUpToDate {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }

    var statusText: String {
        if vaccine.needsConfirmation {
            return "Needs Confirmation"
        } else if vaccine.wasMissed {
            return "Missed"
        } else if isScheduledForFuture {
            return "Scheduled"
        } else if vaccine.isUpToDate {
            return "Confirmed"
        } else {
            return "Unknown"
        }
    }

    var body: some View {
        NavigationView {
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
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(statusColor.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Image(systemName: statusIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(statusColor)
                            }

                            Text(vaccine.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            // Status badge
                            Text(statusText)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(statusColor.opacity(0.6))
                                )
                        }
                        .padding(.top, 20)

                        // Details Card
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow(icon: "calendar", label: isScheduledForFuture ? "Scheduled Date" : "Date Administered", value: dateFormatter.string(from: vaccine.administeredDate))

                            if let nextDue = vaccine.nextDueDate {
                                DetailRow(icon: "calendar.badge.clock", label: "Next Due", value: dateFormatter.string(from: nextDue))
                            }

                            if let frequency = vaccine.frequency, !frequency.isEmpty {
                                DetailRow(icon: "repeat", label: "Frequency", value: frequency)
                            }

                            if let administeredBy = vaccine.administeredBy, !administeredBy.isEmpty {
                                DetailRow(icon: "person.fill", label: "Administered By", value: administeredBy)
                            }

                            if let notes = vaccine.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Notes", systemImage: "note.text")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))

                                    Text(notes)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // Status Buttons (show for past vaccines that can be confirmed/changed)
                        if !isScheduledForFuture {
                            VStack(spacing: 12) {
                                // Show "Confirm Completed" if needs confirmation or was missed
                                if vaccine.needsConfirmation || vaccine.wasMissed {
                                    Button(action: {
                                        confirmVaccine()
                                    }) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text(vaccine.wasMissed ? "Mark as Completed" : "Confirm Completed")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.green.opacity(0.8))
                                        )
                                    }
                                }

                                // Show "Mark as Missed" if needs confirmation or is confirmed
                                if vaccine.needsConfirmation || vaccine.isUpToDate {
                                    Button(action: {
                                        showingMissedAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: "xmark.circle.fill")
                                            Text("Mark as Missed")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.orange.opacity(0.8))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showingEditSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Vaccine")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.blue.opacity(0.6))
                                )
                            }

                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Vaccine")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.red.opacity(0.6))
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }

                if isDeleting || isUpdating {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
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
            .alert("Delete Vaccine", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteVaccine()
                }
            } message: {
                Text("Are you sure you want to delete this vaccine record?")
            }
            .alert("Mark as Missed", isPresented: $showingMissedAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Mark as Missed", role: .destructive) {
                    markAsMissed()
                }
            } message: {
                Text("This will mark the vaccine as missed. You can change this later if needed.")
            }
            .sheet(isPresented: $showingEditSheet) {
                EditVaccineView(vaccine: vaccine) {
                    onUpdate()
                    dismiss()
                }
            }
        }
    }

    private func confirmVaccine() {
        isUpdating = true
        var request = VaccineUpdateRequest()
        request.upToDate = true

        PetService.shared.updateVaccine(id: vaccine.id, request: request)
            .sink(receiveCompletion: { completion in
                isUpdating = false
                if case .failure(let error) = completion {
                    print("Error confirming vaccine: \(error)")
                }
            }, receiveValue: { _ in
                onUpdate()
                dismiss()
            })
            .store(in: &cancellables)
    }

    private func markAsMissed() {
        isUpdating = true
        var request = VaccineUpdateRequest()
        request.upToDate = false

        PetService.shared.updateVaccine(id: vaccine.id, request: request)
            .sink(receiveCompletion: { completion in
                isUpdating = false
                if case .failure(let error) = completion {
                    print("Error marking vaccine as missed: \(error)")
                }
            }, receiveValue: { _ in
                onUpdate()
                dismiss()
            })
            .store(in: &cancellables)
    }

    private func deleteVaccine() {
        isDeleting = true
        PetService.shared.deleteVaccine(id: vaccine.id)
            .sink(receiveCompletion: { completion in
                isDeleting = false
                if case .failure(let error) = completion {
                    print("Error deleting vaccine: \(error)")
                } else {
                    onUpdate()
                    dismiss()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

// MARK: - Edit Vaccine View

struct EditVaccineView: View {
    @Environment(\.dismiss) var dismiss

    let vaccine: Vaccine
    let onSave: () -> Void

    @State private var name: String
    @State private var administeredDate: Date
    @State private var hasNextDueDate: Bool
    @State private var nextDueDate: Date
    @State private var administeredBy: String
    @State private var notes: String
    @State private var frequency: VaccineFrequency
    @State private var isSaving = false
    @State private var cancellables = Set<AnyCancellable>()

    init(vaccine: Vaccine, onSave: @escaping () -> Void) {
        self.vaccine = vaccine
        self.onSave = onSave
        _name = State(initialValue: vaccine.name)
        _administeredDate = State(initialValue: vaccine.administeredDate)
        _hasNextDueDate = State(initialValue: vaccine.nextDueDate != nil)
        _nextDueDate = State(initialValue: vaccine.nextDueDate ?? Calendar.current.date(byAdding: .year, value: 1, to: Date())!)
        _administeredBy = State(initialValue: vaccine.administeredBy ?? "")
        _notes = State(initialValue: vaccine.notes ?? "")
        _frequency = State(initialValue: VaccineFrequency.from(vaccine.frequency))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vaccine Details")) {
                    TextField("Vaccine Name", text: $name)

                    DatePicker("Date Administered", selection: $administeredDate, displayedComponents: .date)
                }

                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(VaccineFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    Toggle("Set Next Due Date", isOn: $hasNextDueDate)

                    if hasNextDueDate {
                        DatePicker("Next Due", selection: $nextDueDate, displayedComponents: .date)
                    }
                }

                Section(header: Text("Additional Info")) {
                    TextField("Administered By (optional)", text: $administeredBy)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Vaccine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVaccine()
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                }
            }
        }
    }

    private func saveVaccine() {
        isSaving = true

        let request = VaccineUpdateRequest(
            name: name,
            administeredDate: administeredDate,
            nextDueDate: hasNextDueDate ? nextDueDate : nil,
            administeredBy: administeredBy.isEmpty ? nil : administeredBy,
            notes: notes.isEmpty ? nil : notes,
            frequency: frequency == .none ? nil : frequency.rawValue
        )

        PetService.shared.updateVaccine(id: vaccine.id, request: request)
            .sink(receiveCompletion: { completion in
                isSaving = false
                if case .failure(let error) = completion {
                    print("Error updating vaccine: \(error)")
                }
            }, receiveValue: { _ in
                onSave()
                dismiss()
            })
            .store(in: &cancellables)
    }
}

// MARK: - Frequency Options

enum VaccineFrequency: String, CaseIterable {
    case none = ""
    case annual = "Annual"
    case biannual = "Biannual"
    case triennial = "Triennial"
    case monthly = "Monthly"
    case asNeeded = "As Needed"
    case oneTime = "One Time"

    var displayName: String {
        switch self {
        case .none: return "None"
        case .annual: return "Annual (Yearly)"
        case .biannual: return "Biannual (Every 6 months)"
        case .triennial: return "Triennial (Every 3 years)"
        case .monthly: return "Monthly"
        case .asNeeded: return "As Needed"
        case .oneTime: return "One Time"
        }
    }

    static func from(_ string: String?) -> VaccineFrequency {
        guard let string = string else { return .none }
        return VaccineFrequency.allCases.first { $0.rawValue == string } ?? .none
    }
}

// MARK: - Add Vaccine View

struct AddVaccineView: View {
    @Environment(\.dismiss) var dismiss

    let petId: Int
    let onSave: () -> Void

    @State private var name = ""
    @State private var administeredDate = Date()
    @State private var hasNextDueDate = false
    @State private var nextDueDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var administeredBy = ""
    @State private var notes = ""
    @State private var frequency: VaccineFrequency = .none
    @State private var isSaving = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vaccine Details")) {
                    TextField("Vaccine Name (e.g., Rabies)", text: $name)

                    DatePicker("Date Administered", selection: $administeredDate, displayedComponents: .date)
                }

                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(VaccineFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    Toggle("Set Next Due Date", isOn: $hasNextDueDate)

                    if hasNextDueDate {
                        DatePicker("Next Due", selection: $nextDueDate, displayedComponents: .date)
                    }
                }

                Section(header: Text("Additional Info")) {
                    TextField("Administered By (optional)", text: $administeredBy)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Vaccine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVaccine()
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                }
            }
        }
    }

    private func saveVaccine() {
        isSaving = true

        let request = VaccineCreateRequest(
            name: name,
            administeredDate: administeredDate,
            nextDueDate: hasNextDueDate ? nextDueDate : nil,
            administeredBy: administeredBy.isEmpty ? nil : administeredBy,
            notes: notes.isEmpty ? nil : notes,
            frequency: frequency == .none ? nil : frequency.rawValue
        )

        PetService.shared.createVaccine(forPetId: petId, request: request)
            .sink(receiveCompletion: { completion in
                isSaving = false
                if case .failure(let error) = completion {
                    print("Error creating vaccine: \(error)")
                }
            }, receiveValue: { _ in
                onSave()
                dismiss()
            })
            .store(in: &cancellables)
    }
}

#Preview {
    NavigationView {
        VaccinesView(petId: 1)
    }
}
