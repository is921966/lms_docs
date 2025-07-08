//
//  AnalyticsDashboardView.swift
//  LMS
//
//  Created on Sprint 42 Day 3 - Analytics Dashboard
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsDashboardViewModel()
    @State private var selectedTimeRange = TimeRange.week
    @State private var showingExportSheet = false
    
    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"  
        case month = "Month"
        case all = "All Time"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with time range selector
                headerSection
                
                // Key metrics cards
                metricsSection
                
                // Progress chart
                progressChartSection
                
                // Performance breakdown
                performanceSection
                
                // Engagement heatmap
                engagementSection
                
                // Learning patterns
                patternsSection
            }
            .padding()
        }
        .navigationTitle("Analytics Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingExportSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            ReportExportView()
        }
        .onAppear {
            viewModel.loadData(for: selectedTimeRange)
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Learning Analytics")
                .font(.largeTitle)
                .bold()
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedTimeRange) { newValue in
                viewModel.loadData(for: newValue)
            }
        }
    }
    
    private var metricsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MetricCard(
                title: "Completion",
                value: viewModel.completionRate,
                format: .percentage,
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            MetricCard(
                title: "Avg Score",
                value: viewModel.averageScore,
                format: .percentage,
                icon: "star.fill",
                color: .orange
            )
            
            MetricCard(
                title: "Time Spent",
                value: viewModel.totalTime,
                format: .time,
                icon: "clock.fill",
                color: .blue
            )
            
            MetricCard(
                title: "Activities",
                value: Double(viewModel.completedActivities),
                format: .number,
                icon: "book.fill",
                color: .purple
            )
        }
    }
    
    private var progressChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Over Time")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart(viewModel.progressData) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Progress", dataPoint.value)
                    )
                    .foregroundStyle(.blue)
                    
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Progress", dataPoint.value)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }
                .frame(height: 200)
            } else {
                // Fallback for older iOS versions
                ProgressChartLegacy(data: viewModel.progressData)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Breakdown")
                .font(.headline)
            
            ForEach(viewModel.performanceBreakdown) { module in
                HStack {
                    Text(module.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    ProgressView(value: module.score)
                        .frame(width: 100)
                    
                    Text("\(Int(module.score * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var engagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Activity Heatmap")
                .font(.headline)
            
            HeatmapView(data: viewModel.activityHeatmap)
                .frame(height: 150)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Learning Patterns")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                PatternRow(
                    icon: "sunrise.fill",
                    title: "Peak Time",
                    value: viewModel.peakLearningTime
                )
                
                PatternRow(
                    icon: "calendar",
                    title: "Most Active Day",
                    value: viewModel.mostActiveDay
                )
                
                PatternRow(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(viewModel.currentStreak) days"
                )
                
                PatternRow(
                    icon: "speedometer",
                    title: "Learning Velocity",
                    value: viewModel.learningVelocity
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: Double
    let format: Format
    let icon: String
    let color: Color
    
    enum Format {
        case percentage
        case number
        case time
    }
    
    var formattedValue: String {
        switch format {
        case .percentage:
            return "\(Int(value * 100))%"
        case .number:
            return "\(Int(value))"
        case .time:
            return LearningMetrics.formatLearningTime(value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(formattedValue)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct PatternRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ProgressChartLegacy: View {
    let data: [ChartDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !data.isEmpty else { return }
                
                let maxValue = data.map(\.value).max() ?? 1
                let xStep = geometry.size.width / CGFloat(data.count - 1)
                
                for (index, point) in data.enumerated() {
                    let x = CGFloat(index) * xStep
                    let y = geometry.size.height - (CGFloat(point.value / maxValue) * geometry.size.height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}

struct HeatmapView: View {
    let data: [[Double]] // 7 days x 24 hours
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                ForEach(0..<7) { day in
                    HStack(spacing: 2) {
                        ForEach(0..<24) { hour in
                            Rectangle()
                                .fill(heatColor(for: data[safe: day]?[safe: hour] ?? 0))
                                .frame(
                                    width: geometry.size.width / 24 - 2,
                                    height: geometry.size.height / 7 - 2
                                )
                        }
                    }
                }
            }
        }
    }
    
    private func heatColor(for value: Double) -> Color {
        let intensity = min(max(value, 0), 1)
        return Color.blue.opacity(0.1 + intensity * 0.8)
    }
}

// MARK: - View Model

class AnalyticsDashboardViewModel: ObservableObject {
    @Published var completionRate: Double = 0.75
    @Published var averageScore: Double = 0.82
    @Published var totalTime: TimeInterval = 45000 // seconds
    @Published var completedActivities: Int = 15
    
    @Published var progressData: [ChartDataPoint] = []
    @Published var performanceBreakdown: [ModulePerformance] = []
    @Published var activityHeatmap: [[Double]] = []
    
    @Published var peakLearningTime: String = "2-3 PM"
    @Published var mostActiveDay: String = "Tuesday"
    @Published var currentStreak: Int = 5
    @Published var learningVelocity: String = "2.5 activities/hour"
    
    func loadData(for timeRange: AnalyticsDashboardView.TimeRange) {
        // In real implementation, would fetch from AnalyticsCollector
        generateMockData()
    }
    
    private func generateMockData() {
        // Progress data
        progressData = (0..<7).map { day in
            ChartDataPoint(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                value: Double.random(in: 0.6...0.9)
            )
        }.reversed()
        
        // Performance breakdown
        performanceBreakdown = [
            ModulePerformance(id: "1", name: "Module 1: Basics", score: 0.85),
            ModulePerformance(id: "2", name: "Module 2: Advanced", score: 0.78),
            ModulePerformance(id: "3", name: "Module 3: Expert", score: 0.82)
        ]
        
        // Activity heatmap (7 days x 24 hours)
        activityHeatmap = (0..<7).map { _ in
            (0..<24).map { hour in
                // Simulate higher activity during work hours
                if (9...17).contains(hour) {
                    return Double.random(in: 0.3...1.0)
                } else {
                    return Double.random(in: 0...0.3)
                }
            }
        }
    }
}

// MARK: - Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ModulePerformance: Identifiable {
    let id: String
    let name: String
    let score: Double
}

// MARK: - Extensions

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

struct AnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnalyticsDashboardView()
        }
    }
} 