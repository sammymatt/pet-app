//
//  AppointmentsView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI

struct Appointment: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let time: String
    let veterinarian: String
    let clinic: String
    let address: String?
    let notes: String?
    let isUpcoming: Bool
}

struct AppointmentsView: View {
    @Environment(\.dismiss) var dismiss

    // Sample data
    let appointments: [Appointment] = [
        Appointment(
            title: "Annual Checkup",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            time: "10:30 AM",
            veterinarian: "Dr. Smith",
            clinic: "Happy Paws Clinic",
            address: "123 Pet Street",
            notes: "Bring vaccination records",
            isUpcoming: true
        ),
        Appointment(
            title: "Dental Cleaning",
            date: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date())!,
            time: "2:00 PM",
            veterinarian: "Dr. Johnson",
            clinic: "Pet Dental Care",
            address: "456 Vet Avenue",
            notes: "No food after midnight",
            isUpcoming: true
        ),
        Appointment(
            title: "Vaccination Booster",
            date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            time: "11:00 AM",
            veterinarian: "Dr. Smith",
            clinic: "Happy Paws Clinic",
            address: "123 Pet Street",
            notes: nil,
            isUpcoming: false
        ),
        Appointment(
            title: "Follow-up Visit",
            date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            time: "3:30 PM",
            veterinarian: "Dr. Williams",
            clinic: "City Vet Hospital",
            address: "789 Health Blvd",
            notes: nil,
            isUpcoming: false
        )
    ]

    var upcomingAppointments: [Appointment] {
        appointments.filter { $0.isUpcoming }.sorted { $0.date < $1.date }
    }

    var pastAppointments: [Appointment] {
        appointments.filter { !$0.isUpcoming }.sorted { $0.date > $1.date }
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
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Add Appointment Button
                    Button(action: {
                        // TODO: Implement add appointment
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

struct AppointmentCard: View {
    let appointment: Appointment

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var daysUntil: Int? {
        guard appointment.isUpcoming else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: appointment.date)
        return components.day
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatter.string(from: appointment.date))
                        Text("•")
                        Text(appointment.time)
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

            HStack(spacing: 16) {
                Label(appointment.veterinarian, systemImage: "person.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Label(appointment.clinic, systemImage: "building.2.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }

            if let address = appointment.address {
                Label(address, systemImage: "location.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }

            if let notes = appointment.notes {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.yellow)
                    Text(notes)
                        .foregroundColor(.white.opacity(0.9))
                }
                .font(.system(size: 12, weight: .medium))
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
        AppointmentsView()
    }
}
