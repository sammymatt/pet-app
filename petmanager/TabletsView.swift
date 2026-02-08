//
//  TabletsView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI
import Combine

// MARK: - Frequency Options

enum TabletFrequency: String, CaseIterable {
    case none = ""
    case daily = "Daily"
    case twiceDaily = "Twice Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
    case triMonthly = "Tri-Monthly"
    case asNeeded = "As Needed"

    var displayName: String {
        switch self {
        case .none: return "None"
        case .daily: return "Daily"
        case .twiceDaily: return "Twice Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Biweekly (Every 2 weeks)"
        case .monthly: return "Monthly"
        case .triMonthly: return "Tri-Monthly (Every 3 months)"
        case .asNeeded: return "As Needed"
        }
    }

    static func from(_ string: String?) -> TabletFrequency {
        guard let string = string else { return .none }
        return TabletFrequency.allCases.first { $0.rawValue == string } ?? .none
    }
}

// MARK: - Tablets View

struct TabletsView: View {
    @Environment(\.dismiss) var dismiss

    let petId: Int

    @State private var tablets: [Tablet] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showingAddTablet = false
    @State private var selectedTablet: Tablet?

    var activeTablets: [Tablet] {
        tablets.filter { $0.isActive }.sorted { $0.startDate > $1.startDate }
    }

    var pastTablets: [Tablet] {
        tablets.filter { !$0.isActive }.sorted { ($0.endDate ?? Date.distantPast) > ($1.endDate ?? Date.distantPast) }
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

                        if !tablets.isEmpty {
                            Text("\(activeTablets.count) active medication\(activeTablets.count == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 20)

                    // Content
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                            .padding(.vertical, 40)
                    } else if tablets.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "pills")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No medications recorded")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 40)
                    } else {
                        // Active Medications
                        if !activeTablets.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)

                                ForEach(activeTablets) { tablet in
                                    TabletCard(tablet: tablet)
                                        .onTapGesture {
                                            selectedTablet = tablet
                                        }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // Past Medications
                        if !pastTablets.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Past")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 20)

                                ForEach(pastTablets) { tablet in
                                    TabletCard(tablet: tablet)
                                        .opacity(0.6)
                                        .onTapGesture {
                                            selectedTablet = tablet
                                        }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // Add Medication Button
                    Button(action: {
                        showingAddTablet = true
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
        .onAppear {
            fetchTablets()
        }
        .sheet(isPresented: $showingAddTablet) {
            AddTabletView(petId: petId) {
                fetchTablets()
            }
        }
        .sheet(item: $selectedTablet) { tablet in
            TabletDetailView(tablet: tablet, onUpdate: {
                fetchTablets()
                selectedTablet = nil
            })
        }
    }

    private func fetchTablets() {
        isLoading = true
        errorMessage = nil

        PetService.shared.fetchTablets(forPetId: petId)
            .sink(receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                    print("Error fetching tablets: \(error)")
                }
            }, receiveValue: { fetchedTablets in
                tablets = fetchedTablets
            })
            .store(in: &cancellables)
    }
}

// MARK: - Tablet Card

struct TabletCard: View {
    let tablet: Tablet

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: "pills.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.5, green: 0.7, blue: 1.0))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(tablet.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if let frequency = tablet.frequency, !frequency.isEmpty {
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

                if let dosage = tablet.dosage, !dosage.isEmpty {
                    Text(dosage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                Text("Started: \(dateFormatter.string(from: tablet.startDate))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))

                if let endDate = tablet.endDate {
                    Text("Ended: \(dateFormatter.string(from: endDate))")
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
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Tablet Detail View

struct TabletDetailView: View {
    @Environment(\.dismiss) var dismiss

    let tablet: Tablet
    let onUpdate: () -> Void

    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var showingEndAlert = false
    @State private var isDeleting = false
    @State private var isUpdating = false
    @State private var cancellables = Set<AnyCancellable>()

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
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
                                    .fill(Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "pills.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(red: 0.5, green: 0.7, blue: 1.0))
                            }

                            Text(tablet.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            // Status badge
                            Text(tablet.isActive ? "Active" : "Ended")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(tablet.isActive ? Color.green.opacity(0.6) : Color.gray.opacity(0.6))
                                )
                        }
                        .padding(.top, 20)

                        // Details Card
                        VStack(alignment: .leading, spacing: 16) {
                            if let dosage = tablet.dosage, !dosage.isEmpty {
                                DetailRow(icon: "scalemass", label: "Dosage", value: dosage)
                            }

                            if let frequency = tablet.frequency, !frequency.isEmpty {
                                DetailRow(icon: "repeat", label: "Frequency", value: frequency)
                            }

                            DetailRow(icon: "calendar", label: "Start Date", value: dateFormatter.string(from: tablet.startDate))

                            if let endDate = tablet.endDate {
                                DetailRow(icon: "calendar.badge.clock", label: "End Date", value: dateFormatter.string(from: endDate))
                            }

                            if let notes = tablet.notes, !notes.isEmpty {
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

                        // Action Buttons
                        VStack(spacing: 12) {
                            if tablet.isActive {
                                Button(action: {
                                    showingEndAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "stop.circle.fill")
                                        Text("End Medication")
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

                            Button(action: {
                                showingEditSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Medication")
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
                                    Text("Delete Medication")
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
            .alert("Delete Medication", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteTablet()
                }
            } message: {
                Text("Are you sure you want to delete this medication record?")
            }
            .alert("End Medication", isPresented: $showingEndAlert) {
                Button("Cancel", role: .cancel) { }
                Button("End Today", role: .destructive) {
                    endTablet()
                }
            } message: {
                Text("This will set today as the end date for this medication.")
            }
            .sheet(isPresented: $showingEditSheet) {
                EditTabletView(tablet: tablet) {
                    onUpdate()
                    dismiss()
                }
            }
        }
    }

    private func deleteTablet() {
        isDeleting = true
        PetService.shared.deleteTablet(id: tablet.id)
            .sink(receiveCompletion: { completion in
                isDeleting = false
                if case .failure(let error) = completion {
                    print("Error deleting tablet: \(error)")
                } else {
                    onUpdate()
                    dismiss()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    private func endTablet() {
        isUpdating = true
        var request = TabletUpdateRequest()
        request.endDate = Date()

        PetService.shared.updateTablet(id: tablet.id, request: request)
            .sink(receiveCompletion: { completion in
                isUpdating = false
                if case .failure(let error) = completion {
                    print("Error ending tablet: \(error)")
                }
            }, receiveValue: { _ in
                onUpdate()
                dismiss()
            })
            .store(in: &cancellables)
    }
}

// MARK: - Edit Tablet View

struct EditTabletView: View {
    @Environment(\.dismiss) var dismiss

    let tablet: Tablet
    let onSave: () -> Void

    @State private var name: String
    @State private var dosage: String
    @State private var frequency: TabletFrequency
    @State private var startDate: Date
    @State private var hasEndDate: Bool
    @State private var endDate: Date
    @State private var notes: String
    @State private var isSaving = false
    @State private var cancellables = Set<AnyCancellable>()

    init(tablet: Tablet, onSave: @escaping () -> Void) {
        self.tablet = tablet
        self.onSave = onSave
        _name = State(initialValue: tablet.name)
        _dosage = State(initialValue: tablet.dosage ?? "")
        _frequency = State(initialValue: TabletFrequency.from(tablet.frequency))
        _startDate = State(initialValue: tablet.startDate)
        _hasEndDate = State(initialValue: tablet.endDate != nil)
        _endDate = State(initialValue: tablet.endDate ?? Date())
        _notes = State(initialValue: tablet.notes ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 1 tablet, 250mg)", text: $dosage)
                }

                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(TabletFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                    Toggle("Set End Date", isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }

                Section(header: Text("Additional Info")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTablet()
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

    private func saveTablet() {
        isSaving = true

        var request = TabletUpdateRequest()
        request.name = name
        request.dosage = dosage.isEmpty ? nil : dosage
        request.frequency = frequency == .none ? nil : frequency.rawValue
        request.startDate = startDate
        request.endDate = hasEndDate ? endDate : nil
        request.notes = notes.isEmpty ? nil : notes

        PetService.shared.updateTablet(id: tablet.id, request: request)
            .sink(receiveCompletion: { completion in
                isSaving = false
                if case .failure(let error) = completion {
                    print("Error updating tablet: \(error)")
                }
            }, receiveValue: { _ in
                onSave()
                dismiss()
            })
            .store(in: &cancellables)
    }
}

// MARK: - Add Tablet View

struct AddTabletView: View {
    @Environment(\.dismiss) var dismiss

    let petId: Int
    let onSave: () -> Void

    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency: TabletFrequency = .none
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var notes = ""
    @State private var isSaving = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name (e.g., Heartworm Prevention)", text: $name)
                    TextField("Dosage (e.g., 1 tablet, 250mg)", text: $dosage)
                }

                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(TabletFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                    Toggle("Set End Date", isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }

                Section(header: Text("Additional Info")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTablet()
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

    private func saveTablet() {
        isSaving = true

        let request = TabletCreateRequest(
            name: name,
            dosage: dosage.isEmpty ? nil : dosage,
            frequency: frequency == .none ? nil : frequency.rawValue,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            notes: notes.isEmpty ? nil : notes
        )

        PetService.shared.createTablet(forPetId: petId, request: request)
            .sink(receiveCompletion: { completion in
                isSaving = false
                if case .failure(let error) = completion {
                    print("Error creating tablet: \(error)")
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
        TabletsView(petId: 1)
    }
}
