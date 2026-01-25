//
//  WeightTrackingView.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import SwiftUI
import Charts

struct WeightEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct WeightTrackingView: View {
    let pet: Pet
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPeriod: TimePeriod = .month
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
    }
    
    // Fake data for demonstration
    var weightData: [WeightEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .week:
            return (0..<7).map { day in
                let date = calendar.date(byAdding: .day, value: -day, to: now)!
                let weight = pet.weight + Double.random(in: -0.3...0.3)
                return WeightEntry(date: date, weight: weight)
            }.reversed()
        case .month:
            return (0..<30).map { day in
                let date = calendar.date(byAdding: .day, value: -day, to: now)!
                let weight = pet.weight + Double.random(in: -0.5...0.5)
                return WeightEntry(date: date, weight: weight)
            }.reversed()
        case .threeMonths:
            return (0..<12).map { week in
                let date = calendar.date(byAdding: .weekOfYear, value: -week, to: now)!
                let weight = pet.weight + Double.random(in: -1.0...1.0)
                return WeightEntry(date: date, weight: weight)
            }.reversed()
        case .year:
            return (0..<12).map { month in
                let date = calendar.date(byAdding: .month, value: -month, to: now)!
                let weight = pet.weight + Double.random(in: -1.5...1.5)
                return WeightEntry(date: date, weight: weight)
            }.reversed()
        }
    }
    
    var averageWeight: Double {
        let total = weightData.reduce(0) { $0 + $1.weight }
        return total / Double(weightData.count)
    }
    
    var weightChange: Double {
        guard let first = weightData.first?.weight,
              let last = weightData.last?.weight else { return 0 }
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
                                value: String(format: "%.1f kg", pet.weight),
                                icon: "scalemass.fill",
                                color: Color(red: 0.5, green: 0.7, blue: 1.0)
                            )
                            
                            StatCard(
                                title: "Average",
                                value: String(format: "%.1f kg", averageWeight),
                                icon: "chart.bar.fill",
                                color: Color(red: 0.4, green: 0.8, blue: 0.6)
                            )
                            
                            StatCard(
                                title: "Change",
                                value: String(format: "%+.1f kg", weightChange),
                                icon: weightChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                                color: weightChange >= 0 ? Color(red: 1.0, green: 0.6, blue: 0.4) : Color(red: 0.9, green: 0.5, blue: 0.7)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weight Trend")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            Chart(weightData) { entry in
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Weight", entry.weight)
                                )
                                .foregroundStyle(Color.white)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                AreaMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Weight", entry.weight)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
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
                        
                        // Add Weight Button
                        Button(action: {
                            // TODO: Implement add weight entry
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
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
