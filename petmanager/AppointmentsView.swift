//
//  AppointmentsView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI
import Combine

struct AppointmentsView: View {
    @Environment(\.dismiss) var dismiss

    let petId: Int

    @State private var appointments: [Appointment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showingAddAppointment = false
    @State private var selectedAppointment: Appointment?

    var upcomingAppointments: [Appointment] {
        appointments.filter { $0.isUpcoming }.sorted { $0.appointmentDate < $1.appointmentDate }
    }

    var pastAppointments: [Appointment] {
        appointments.filter { !$0.isUpcoming }.sorted { $0.appointmentDate > $1.appointmentDate }
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
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text("Appointments")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("\(upcomingAppointments.count) upcoming")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)

                    // Upcoming Appointments
                    if !upcomingAppointments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)

                            ForEach(upcomingAppointments) { appointment in
                                AppointmentCard(appointment: appointment)
                                    .onTapGesture {
                                        selectedAppointment = appointment
                                    }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Past Appointments
                    if !pastAppointments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Past")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 20)

                            ForEach(pastAppointments) { appointment in
                                AppointmentCard(appointment: appointment)
                                    .opacity(0.6)
                                    .onTapGesture {
                                        selectedAppointment = appointment
                                    }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Empty State
                    if !isLoading && appointments.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No appointments yet")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 40)
                    }

                    // Add Appointment Button
                    Button(action: {
                        showingAddAppointment = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Schedule Appointment")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.9, green: 0.5, blue: 0.7).opacity(0.8))
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
            fetchAppointments()
        }
        .sheet(isPresented: $showingAddAppointment) {
            AddAppointmentView(petId: petId) {
                fetchAppointments()
            }
        }
        .sheet(item: $selectedAppointment) { appointment in
            AppointmentDetailView(appointment: appointment, onUpdate: {
                fetchAppointments()
                selectedAppointment = nil
            })
        }
    }

    private func fetchAppointments() {
        isLoading = true
        errorMessage = nil

        PetService.shared.fetchAppointments(forPetId: petId)
            .sink(receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                    print("Error fetching appointments: \(error)")
                }
            }, receiveValue: { fetchedAppointments in
                appointments = fetchedAppointments
            })
            .store(in: &cancellables)
    }

}


struct AppointmentCard: View {
    let appointment: Appointment

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var daysUntil: Int? {
        guard appointment.isUpcoming else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: appointment.appointmentDate)
        return components.day
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(appointment.appointmentDate)
    }

    var displayStatus: String {
        if isToday {
            return "Today"
        } else if !appointment.isUpcoming {
            return "Previous"
        } else {
            return appointment.status.capitalized
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.reason)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatter.string(from: appointment.appointmentDate))
                        Text("•")
                        Text(timeFormatter.string(from: appointment.appointmentDate))
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                if let days = daysUntil {
                    VStack(spacing: 2) {
                        Text("\(days)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(days == 1 ? "day" : "days")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color(red: 0.9, green: 0.5, blue: 0.7).opacity(0.5))
                    )
                }
            }

            Divider()
                .background(Color.white.opacity(0.3))

            if let vetName = appointment.vetName {
                Label(vetName, systemImage: "person.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }

            if let location = appointment.location {
                Label(location, systemImage: "location.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }

            if let notes = appointment.notes, !notes.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .foregroundColor(.white.opacity(0.7))
                    Text(notes)
                        .foregroundColor(.white.opacity(0.9))
                }
                .font(.system(size: 12, weight: .medium))
            }

            // Status badge
            HStack {
                Spacer()
                Text(displayStatus)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(statusColor(for: displayStatus))
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

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "today":
            return Color.orange.opacity(0.8)
        case "previous":
            return Color.gray.opacity(0.6)
        case "scheduled":
            return Color.blue.opacity(0.6)
        case "completed":
            return Color.green.opacity(0.6)
        case "cancelled":
            return Color.red.opacity(0.6)
        default:
            return Color.gray.opacity(0.6)
        }
    }
}

// MARK: - Appointment Detail View

struct AppointmentDetailView: View {
    @Environment(\.dismiss) var dismiss

    let appointment: Appointment
    let onUpdate: () -> Void

    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var isDeleting = false
    @State private var cancellables = Set<AnyCancellable>()

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
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
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 60))
                                .foregroundColor(.white)

                            Text(appointment.reason)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            // Status badge
                            Text(appointment.status.capitalized)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(statusColor(for: appointment.status))
                                )
                        }
                        .padding(.top, 20)

                        // Details Card
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow(icon: "calendar", label: "Date", value: dateFormatter.string(from: appointment.appointmentDate))

                            DetailRow(icon: "clock", label: "Time", value: timeFormatter.string(from: appointment.appointmentDate))

                            if let vetName = appointment.vetName, !vetName.isEmpty {
                                DetailRow(icon: "person.fill", label: "Veterinarian", value: vetName)
                            }

                            if let location = appointment.location, !location.isEmpty {
                                DetailRow(icon: "location.fill", label: "Location", value: location)
                            }

                            if let notes = appointment.notes, !notes.isEmpty {
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
                            Button(action: {
                                showingEditSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Appointment")
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
                                    Text("Delete Appointment")
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

                if isDeleting {
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
            .alert("Delete Appointment", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAppointment()
                }
            } message: {
                Text("Are you sure you want to delete this appointment?")
            }
            .sheet(isPresented: $showingEditSheet) {
                EditAppointmentView(appointment: appointment) {
                    onUpdate()
                    dismiss()
                }
            }
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "scheduled":
            return Color.blue.opacity(0.6)
        case "completed":
            return Color.green.opacity(0.6)
        case "cancelled":
            return Color.red.opacity(0.6)
        default:
            return Color.gray.opacity(0.6)
        }
    }

    private func deleteAppointment() {
        isDeleting = true
        PetService.shared.deleteAppointment(id: appointment.id)
            .sink(receiveCompletion: { completion in
                isDeleting = false
                if case .failure(let error) = completion {
                    print("Error deleting appointment: \(error)")
                } else {
                    onUpdate()
                    dismiss()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }

            Spacer()
        }
    }
}

// MARK: - Edit Appointment View

struct EditAppointmentView: View {
    @Environment(\.dismiss) var dismiss

    let appointment: Appointment
    let onSave: () -> Void

    @State private var reason: String
    @State private var appointmentDate: Date
    @State private var vetName: String
    @State private var location: String
    @State private var notes: String
    @State private var status: String
    @State private var isSaving = false
    @State private var cancellables = Set<AnyCancellable>()

    let statusOptions = ["scheduled", "completed", "cancelled"]

    init(appointment: Appointment, onSave: @escaping () -> Void) {
        self.appointment = appointment
        self.onSave = onSave
        _reason = State(initialValue: appointment.reason)
        _appointmentDate = State(initialValue: appointment.appointmentDate)
        _vetName = State(initialValue: appointment.vetName ?? "")
        _location = State(initialValue: appointment.location ?? "")
        _notes = State(initialValue: appointment.notes ?? "")
        _status = State(initialValue: appointment.status)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appointment Details")) {
                    TextField("Reason", text: $reason)

                    DatePicker("Date & Time", selection: $appointmentDate, displayedComponents: [.date, .hourAndMinute])

                    Picker("Status", selection: $status) {
                        ForEach(statusOptions, id: \.self) { option in
                            Text(option.capitalized).tag(option)
                        }
                    }
                }

                Section(header: Text("Veterinarian")) {
                    TextField("Vet Name (optional)", text: $vetName)
                    TextField("Location (optional)", text: $location)
                }

                Section(header: Text("Notes")) {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAppointment()
                    }
                    .disabled(reason.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                }
            }
        }
    }

    private func saveAppointment() {
        isSaving = true

        let request = AppointmentUpdateRequest(
            appointmentDate: appointmentDate,
            reason: reason,
            vetName: vetName.isEmpty ? nil : vetName,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            status: status
        )

        PetService.shared.updateAppointment(id: appointment.id, request: request)
            .sink(receiveCompletion: { completion in
                isSaving = false
                if case .failure(let error) = completion {
                    print("Error updating appointment: \(error)")
                }
            }, receiveValue: { _ in
                onSave()
                dismiss()
            })
            .store(in: &cancellables)
    }
}

// MARK: - Add Appointment View

struct AddAppointmentView: View {
    @Environment(\.dismiss) var dismiss

    let petId: Int
    let onSave: () -> Void

    @State private var reason = ""
    @State private var appointmentDate = Date()
    @State private var vetName = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var isSaving = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appointment Details")) {
                    TextField("Reason (e.g., Annual Checkup)", text: $reason)

                    DatePicker("Date & Time", selection: $appointmentDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Veterinarian")) {
                    TextField("Vet Name (optional)", text: $vetName)
                    TextField("Location (optional)", text: $location)
                }

                Section(header: Text("Notes")) {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Schedule Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAppointment()
                    }
                    .disabled(reason.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                }
            }
        }
    }

    private func saveAppointment() {
        isSaving = true

        let request = AppointmentRequest(
            appointmentDate: appointmentDate,
            reason: reason,
            vetName: vetName.isEmpty ? nil : vetName,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            status: "scheduled"
        )

        PetService.shared.createAppointment(forPetId: petId, request: request)
            .sink(receiveCompletion: { completion in
                isSaving = false
                if case .failure(let error) = completion {
                    print("Error creating appointment: \(error)")
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
        AppointmentsView(petId: 1)
    }
}
