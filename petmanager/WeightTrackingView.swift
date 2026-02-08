//
//  WeightTrackingView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI
import Charts
import Combine

struct WeightTrackingView: View {
    let pet: Pet
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPeriod: TimePeriod = .month
    @State private var weights: [Weight] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAddWeight = false
    @State private var selectedWeight: Weight?
    @State private var cancellables = Set<AnyCancellable>()

    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"

        var dateThreshold: Date {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)!
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: now)!
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: now)!
            }
        }
    }

    var filteredWeights: [Weight] {
        let threshold = selectedPeriod.dateThreshold
        return weights
            .filter { $0.recordedAt >= threshold }
            .sorted { $0.recordedAt < $1.recordedAt }
    }

    var currentWeight: Double? {
        weights.first?.weight
    }

    var averageWeight: Double? {
        guard !filteredWeights.isEmpty else { return nil }
        let total = filteredWeights.reduce(0) { $0 + $1.weight }
        return total / Double(filteredWeights.count)
    }

    var weightChange: Double? {
        guard let first = filteredWeights.first?.weight,
              let last = filteredWeights.last?.weight else { return nil }
        return last - first
    }

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

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.8))
                        Text(error)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            loadWeights()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 8) {
                                Image(systemName: "scalemass.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)

                                Text("\(pet.name)'s Weight")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 20)

                            // Time Period Selector
                            Picker("Period", selection: $selectedPeriod) {
                                ForEach(TimePeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)

                            // Stats Cards
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Current",
                                    value: currentWeight.map { String(format: "%.1f kg", $0) } ?? "--",
                                    icon: "scalemass.fill",
                                    color: Color(red: 0.5, green: 0.7, blue: 1.0)
                                )

                                StatCard(
                                    title: "Average",
                                    value: averageWeight.map { String(format: "%.1f kg", $0) } ?? "--",
                                    icon: "chart.bar.fill",
                                    color: Color(red: 0.4, green: 0.8, blue: 0.6)
                                )

                                if let change = weightChange {
                                    StatCard(
                                        title: "Change",
                                        value: String(format: "%+.1f kg", change),
                                        icon: change >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                                        color: change >= 0 ? Color(red: 1.0, green: 0.6, blue: 0.4) : Color(red: 0.9, green: 0.5, blue: 0.7)
                                    )
                                } else {
                                    StatCard(
                                        title: "Change",
                                        value: "--",
                                        icon: "arrow.up.circle.fill",
                                        color: Color(red: 1.0, green: 0.6, blue: 0.4)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)

                            // Chart
                            if filteredWeights.count >= 2 {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Weight Trend")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)

                                    Chart(filteredWeights) { entry in
                                        LineMark(
                                            x: .value("Date", entry.recordedAt),
                                            y: .value("Weight", entry.weight)
                                        )
                                        .foregroundStyle(Color.white)
                                        .lineStyle(StrokeStyle(lineWidth: 3))

                                        AreaMark(
                                            x: .value("Date", entry.recordedAt),
                                            y: .value("Weight", entry.weight)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )

                                        PointMark(
                                            x: .value("Date", entry.recordedAt),
                                            y: .value("Weight", entry.weight)
                                        )
                                        .foregroundStyle(Color.white)
                                        .symbolSize(50)
                                    }
                                    .frame(height: 250)
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) { _ in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                                .foregroundStyle(Color.white.opacity(0.3))
                                            AxisValueLabel()
                                                .foregroundStyle(Color.white.opacity(0.8))
                                                .font(.caption)
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(values: .automatic) { _ in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                                .foregroundStyle(Color.white.opacity(0.3))
                                            AxisValueLabel()
                                                .foregroundStyle(Color.white.opacity(0.8))
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.white.opacity(0.15))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .padding(.horizontal, 20)
                                }
                            } else if filteredWeights.count == 1 {
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Add more weight entries to see the trend")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white.opacity(0.15))
                                )
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "scalemass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("No weight entries yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Add your first weight entry to start tracking")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white.opacity(0.15))
                                )
                                .padding(.horizontal, 20)
                            }

                            // Weight History
                            if !weights.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Entries")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)

                                    VStack(spacing: 8) {
                                        ForEach(weights.prefix(10)) { weight in
                                            WeightHistoryRow(
                                                weight: weight,
                                                onTap: {
                                                    selectedWeight = weight
                                                },
                                                onDelete: {
                                                    deleteWeight(weight)
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            // Add Weight Button
                            Button(action: {
                                showingAddWeight = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Weight Entry")
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            loadWeights()
        }
        .sheet(isPresented: $showingAddWeight) {
            AddWeightView(petId: pet.id) { _ in
                loadWeights()
            }
        }
        .sheet(item: $selectedWeight) { weight in
            EditWeightView(weight: weight) { _ in
                loadWeights()
            }
        }
    }

    private func deleteWeight(_ weight: Weight) {
        PetService.shared.deleteWeight(id: weight.id)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    weights.removeAll { $0.id == weight.id }
                }
            )
            .store(in: &cancellables)
    }

    private func loadWeights() {
        isLoading = true
        errorMessage = nil

        PetService.shared.fetchWeights(forPetId: pet.id)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { fetchedWeights in
                    weights = fetchedWeights
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Weight History Row

struct WeightHistoryRow: View {
    let weight: Weight
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var showingDeleteAlert = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f kg", weight.weight))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(dateFormatter.string(from: weight.recordedAt))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                if let notes = weight.notes, !notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.15))
            )
        }
        .contextMenu {
            Button(role: .destructive, action: {
                showingDeleteAlert = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Weight Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this weight entry?")
        }
    }
}

// MARK: - Add Weight View

struct AddWeightView: View {
    let petId: Int
    let onSave: (Weight) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var weightValue: String = ""
    @State private var recordedDate: Date = Date()
    @State private var notes: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()

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
                        // Weight Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight (kg)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            TextField("0.0", text: $weightValue)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.2))
                                )
                        }
                        .padding(.horizontal, 20)

                        // Date Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            DatePicker(
                                "",
                                selection: $recordedDate,
                                in: ...Date(),
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.2))
                            )
                        }
                        .padding(.horizontal, 20)

                        // Notes Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (optional)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            TextField("Any notes about this entry...", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.2))
                                )
                        }
                        .padding(.horizontal, 20)

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        // Save Button
                        Button(action: saveWeight) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Save Weight")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(weightValue.isEmpty ? Color.gray.opacity(0.5) : Color(red: 0.5, green: 0.7, blue: 1.0))
                        )
                        .disabled(weightValue.isEmpty || isLoading)
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Add Weight")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
    }

    private func saveWeight() {
        guard let weight = Double(weightValue), weight > 0 else {
            errorMessage = "Please enter a valid weight"
            return
        }

        isLoading = true
        errorMessage = nil

        let request = WeightCreateRequest(
            weight: weight,
            notes: notes.isEmpty ? nil : notes,
            recordedAt: recordedDate
        )

        PetService.shared.createWeight(forPetId: petId, request: request)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { newWeight in
                    onSave(newWeight)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Edit Weight View

struct EditWeightView: View {
    let weight: Weight
    let onSave: (Weight) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var weightValue: String
    @State private var recordedDate: Date
    @State private var notes: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingDeleteAlert = false
    @State private var cancellables = Set<AnyCancellable>()

    init(weight: Weight, onSave: @escaping (Weight) -> Void) {
        self.weight = weight
        self.onSave = onSave
        _weightValue = State(initialValue: String(format: "%.1f", weight.weight))
        _recordedDate = State(initialValue: weight.recordedAt)
        _notes = State(initialValue: weight.notes ?? "")
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
                        // Weight Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight (kg)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            TextField("0.0", text: $weightValue)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.2))
                                )
                        }
                        .padding(.horizontal, 20)

                        // Date Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            DatePicker(
                                "",
                                selection: $recordedDate,
                                in: ...Date(),
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.2))
                            )
                        }
                        .padding(.horizontal, 20)

                        // Notes Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (optional)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            TextField("Any notes about this entry...", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.2))
                                )
                        }
                        .padding(.horizontal, 20)

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        // Save Button
                        Button(action: saveWeight) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(weightValue.isEmpty ? Color.gray.opacity(0.5) : Color(red: 0.5, green: 0.7, blue: 1.0))
                        )
                        .disabled(weightValue.isEmpty || isLoading)
                        .padding(.horizontal, 20)

                        // Delete Button
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Entry")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Edit Weight")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
            .alert("Delete Weight Entry", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteWeight()
                }
            } message: {
                Text("Are you sure you want to delete this weight entry?")
            }
        }
    }

    private func saveWeight() {
        guard let weightDouble = Double(weightValue), weightDouble > 0 else {
            errorMessage = "Please enter a valid weight"
            return
        }

        isLoading = true
        errorMessage = nil

        let request = WeightUpdateRequest(
            weight: weightDouble,
            notes: notes.isEmpty ? nil : notes,
            recordedAt: recordedDate
        )

        PetService.shared.updateWeight(id: weight.id, request: request)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { updatedWeight in
                    onSave(updatedWeight)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .store(in: &cancellables)
    }

    private func deleteWeight() {
        isLoading = true

        PetService.shared.deleteWeight(id: weight.id)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    onSave(weight) // Trigger reload
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .store(in: &cancellables)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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
    WeightTrackingView(pet: Pet.willow)
}
