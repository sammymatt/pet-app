//
//  AgeView.swift
//  petmanager
//
//  Created by Sam Matthews on 26/01/2026.
//

import SwiftUI

struct AgeView: View {
    @EnvironmentObject var viewModel: PetViewModel
    @Environment(\.dismiss) var dismiss
    let pet: Pet

    @State private var birthday: Date
    @State private var hasBirthday: Bool
    @State private var showingDatePicker = false

    init(pet: Pet) {
        self.pet = pet
        _birthday = State(initialValue: pet.birthday ?? Calendar.current.date(byAdding: .year, value: -pet.age, to: Date())!)
        _hasBirthday = State(initialValue: pet.birthday != nil)
    }

    var calculatedAge: (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthday, to: Date())
        return (years: components.year ?? 0, months: components.month ?? 0)
    }

    var nextBirthday: Date? {
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.month, .day], from: birthday)
        components.year = calendar.component(.year, from: today)

        guard let thisYearBirthday = calendar.date(from: components) else { return nil }

        if thisYearBirthday > today {
            return thisYearBirthday
        } else {
            components.year = (components.year ?? 0) + 1
            return calendar.date(from: components)
        }
    }

    var daysUntilBirthday: Int? {
        guard let next = nextBirthday else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: next)
        return components.day
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        ZStack {
            AppBackground(style: .profile)

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text("\(pet.name)'s Age")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Age Display
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            AgeStatBox(
                                value: "\(calculatedAge.years)",
                                label: calculatedAge.years == 1 ? "Year" : "Years",
                                color: Color(red: 0.5, green: 0.7, blue: 1.0)
                            )

                            AgeStatBox(
                                value: "\(calculatedAge.months)",
                                label: calculatedAge.months == 1 ? "Month" : "Months",
                                color: Color(red: 0.4, green: 0.8, blue: 0.6)
                            )
                        }
                        .padding(.horizontal, 20)

                        if hasBirthday, let days = daysUntilBirthday {
                            VStack(spacing: 8) {
                                Text(days == 0 ? "🎉 Happy Birthday! 🎉" : "\(days) days until birthday")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)

                                if let next = nextBirthday, days > 0 {
                                    Text(dateFormatter.string(from: next))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.2))
                            )
                            .padding(.horizontal, 20)
                        }
                    }

                    // Birthday Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Birthday")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        if hasBirthday {
                            Button(action: {
                                showingDatePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(red: 0.5, green: 0.7, blue: 1.0))

                                    Text(dateFormatter.string(from: birthday))
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.2))
                                )
                            }

                            Button(action: {
                                hasBirthday = false
                            }) {
                                Text("Remove Birthday")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        } else {
                            Button(action: {
                                hasBirthday = true
                                showingDatePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Birthday")
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
                        }
                    }
                    .padding(.horizontal, 20)

                    // Age Milestones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Life Stage")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        LifeStageCard(age: calculatedAge.years)
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
                    saveBirthday()
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            BirthdayPickerSheet(birthday: $birthday, isPresented: $showingDatePicker)
        }
    }

    private func saveBirthday() {
        var updatedPet = pet
        updatedPet.birthday = hasBirthday ? birthday : nil
        // Update age based on birthday
        if hasBirthday {
            updatedPet.age = calculatedAge.years
        }
        viewModel.updatePet(updatedPet)
    }
}

struct AgeStatBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
}

struct LifeStageCard: View {
    let age: Int

    var lifeStage: (name: String, description: String, icon: String) {
        switch age {
        case 0:
            return ("Puppy/Kitten", "Growing and learning about the world", "sparkles")
        case 1...2:
            return ("Young Adult", "Full of energy and curiosity", "bolt.fill")
        case 3...6:
            return ("Adult", "In their prime years", "star.fill")
        case 7...9:
            return ("Mature", "Experienced and wise", "heart.fill")
        default:
            return ("Senior", "Deserving of extra love and care", "crown.fill")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: lifeStage.icon)
                    .font(.system(size: 28))
                    .foregroundColor(.yellow)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(lifeStage.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(lifeStage.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
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

struct BirthdayPickerSheet: View {
    @Binding var birthday: Date
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Birthday",
                    selection: $birthday,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Select Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AgeView(pet: Pet.willow)
            .environmentObject(PetViewModel())
    }
}
