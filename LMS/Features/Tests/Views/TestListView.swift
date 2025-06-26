//
//  TestListView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestListView: View {
    @StateObject private var viewModel = TestViewModel()
    @State private var showFilters = false
    @State private var selectedTest: Test?
    @State private var showTestDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Filters
                    if showFilters {
                        filtersView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Tests list
                    if viewModel.filteredTests.isEmpty {
                        emptyStateView
                    } else {
                        testsList
                    }
                }
            }
            .navigationTitle("Тесты и оценки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { showFilters.toggle() } }) {
                        Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(item: $selectedTest) { test in
                NavigationView {
                    TestDetailView(test: test, viewModel: viewModel)
                }
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Поиск тестов...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Filters View
    
    private var filtersView: some View {
        VStack(spacing: 12) {
            // Type filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "Все типы",
                        isSelected: viewModel.selectedType == nil,
                        action: { viewModel.selectedType = nil }
                    )
                    
                    ForEach(TestType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.rawValue,
                            icon: type.icon,
                            isSelected: viewModel.selectedType == type,
                            color: type.color,
                            action: { viewModel.selectedType = type }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Difficulty filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "Все уровни",
                        isSelected: viewModel.selectedDifficulty == nil,
                        action: { viewModel.selectedDifficulty = nil }
                    )
                    
                    ForEach(TestDifficulty.allCases, id: \.self) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue,
                            icon: difficulty.icon,
                            isSelected: viewModel.selectedDifficulty == difficulty,
                            color: difficulty.color,
                            action: { viewModel.selectedDifficulty = difficulty }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Toggle for available tests only
            Toggle("Только доступные", isOn: $viewModel.showOnlyAvailable)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }
    
    // MARK: - Tests List
    
    private var testsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredTests) { test in
                    TestCardView(test: test, viewModel: viewModel)
                        .onTapGesture {
                            selectedTest = test
                        }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Тесты не найдены")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Попробуйте изменить параметры поиска")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Test Card View

struct TestCardView: View {
    let test: Test
    @ObservedObject var viewModel: TestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Type icon
                Image(systemName: test.type.icon)
                    .foregroundColor(test.type.color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(test.title)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        // Difficulty
                        Label(test.difficulty.rawValue, systemImage: test.difficulty.icon)
                            .font(.caption)
                            .foregroundColor(test.difficulty.color)
                        
                        // Questions count
                        Label("\(test.totalQuestions) вопросов", systemImage: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // Time
                        if test.timeLimit != nil {
                            Label(test.estimatedTime, systemImage: "timer")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Status
                statusBadge
            }
            
            // Description
            Text(test.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // User progress
            if let result = viewModel.getUserTestResult(test) {
                userProgressView(result: result)
            }
            
            // Actions
            HStack {
                // Statistics
                if test.totalAttempts > 0 {
                    HStack(spacing: 16) {
                        StatisticView(
                            icon: "person.3",
                            value: "\(test.totalAttempts)",
                            label: "попыток"
                        )
                        
                        StatisticView(
                            icon: "percent",
                            value: String(format: "%.0f%%", test.passRate),
                            label: "успех"
                        )
                        
                        StatisticView(
                            icon: "star",
                            value: String(format: "%.1f", test.averageScore),
                            label: "ср. балл"
                        )
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                // Action button
                actionButton
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        Group {
            switch test.status {
            case .published:
                if test.canBeTaken {
                    Text("Доступен")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(8)
                } else {
                    Text("Недоступен")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            case .draft:
                Text("Черновик")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(8)
            case .archived:
                Text("Архив")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray)
                    .cornerRadius(8)
            }
        }
    }
    
    private func userProgressView(result: TestResult) -> some View {
        HStack {
            // Result icon
            Image(systemName: result.resultIcon)
                .foregroundColor(result.resultColor)
            
            // Score
            Text(result.scoreText)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            // Percentage
            Text("(\(result.percentageText))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Completed date
            Text("Пройден \(result.completedAt, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(result.resultColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var actionButton: some View {
        Group {
            if let activeAttempt = viewModel.service.getActiveAttempt(userId: viewModel.currentUserId, testId: test.id) {
                Button(action: { viewModel.resumeTest(activeAttempt) }) {
                    Label("Продолжить", systemImage: "play.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else if viewModel.canRetakeTest(test) && test.canBeTaken {
                Button(action: { viewModel.startTest(test) }) {
                    Label("Начать", systemImage: "play")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else {
                Text("Недоступен")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Helper Views

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct StatisticView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(value)
                .fontWeight(.semibold)
            Text(label)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Date Formatter

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

// MARK: - Preview

struct TestListView_Previews: PreviewProvider {
    static var previews: some View {
        TestListView()
    }
} 