//
//  OnboardingDashboard.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct OnboardingDashboard: View {
    @StateObject private var service = OnboardingMockService.shared
    @State private var selectedFilter: FilterType = .all
    @State private var searchText = ""
    @State private var showingNewProgram = false
    @State private var showingTemplates = false
    @State private var selectedProgram: OnboardingProgram?
    @State private var showingCreateProgram = false
    @State private var selectedTemplate: OnboardingTemplate?
    
    enum FilterType: String, CaseIterable {
        case all = "Все"
        case inProgress = "Активные"
        case notStarted = "Не начаты"
        case completed = "Завершены"
        case overdue = "Просроченные"
    }
    
    var filteredPrograms: [OnboardingProgram] {
        var filtered = service.programs
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .inProgress:
            filtered = filtered.filter { $0.status == .inProgress }
        case .notStarted:
            filtered = filtered.filter { $0.status == .notStarted }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        case .overdue:
            filtered = filtered.filter { $0.isOverdue }
        }
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { program in
                program.employeeName.localizedCaseInsensitiveContains(searchText) ||
                program.title.localizedCaseInsensitiveContains(searchText) ||
                program.employeeDepartment.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistics
                OnboardingStatsView(programs: service.programs)
                    .accessibilityIdentifier("onboardingStatsView")
                
                // Filter and Search
                VStack(spacing: 12) {
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            OnboardingFilterChip(
                                title: "Все",
                                isSelected: selectedFilter == .all,
                                action: { selectedFilter = .all }
                            )
                            .accessibilityIdentifier("filterChipAll")
                            
                            ForEach(FilterType.allCases, id: \.self) { filter in
                                OnboardingFilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                                .accessibilityIdentifier("filterChip\(filter.rawValue)")
                            }
                        }
                    }
                    .accessibilityIdentifier("filterChipsScrollView")
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .accessibilityIdentifier("searchIcon")
                        TextField("Поиск по сотрудникам", text: $searchText)
                            .accessibilityIdentifier("searchTextField")
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .accessibilityIdentifier("searchBar")
                }
                
                // Programs list
                if filteredPrograms.isEmpty {
                    OnboardingEmptyStateView(filter: selectedFilter)
                        .accessibilityIdentifier("emptyStateView")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPrograms) { program in
                                NavigationLink(destination: OnboardingProgramView(program: program)) {
                                    OnboardingProgramCard(program: program)
                                        .accessibilityIdentifier("programCard_\(program.id)")
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .accessibilityIdentifier("programsListScrollView")
                }
            }
            .navigationTitle("Программы адаптации")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: OnboardingTemplateListView()) {
                        VStack(spacing: 4) {
                            Image(systemName: "plus.rectangle.on.rectangle")
                                .font(.title3)
                                .accessibilityIdentifier("createFromTemplateIcon")
                            Text("Создать из шаблона")
                                .font(.caption2)
                                .minimumScaleFactor(0.7)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .accessibilityIdentifier("createFromTemplateText")
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(height: 60)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("createFromTemplateButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: OnboardingReportsView()) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.title3)
                            .foregroundColor(.purple)
                    }
                    .accessibilityIdentifier("reportsButton")
                }
            }
            .onAppear {
                loadPrograms()
            }
            .sheet(isPresented: $showingNewProgram) {
                // NewProgramView()
                NavigationView {
                    VStack(spacing: 20) {
                        Text("Выберите способ создания")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 40)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                showingNewProgram = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showingTemplates = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("Из шаблона")
                                            .font(.headline)
                                        Text("Быстрое создание на основе готового шаблона")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "plus.square.fill")
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("С нуля")
                                            .font(.headline)
                                        Text("Создать уникальную программу")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .navigationTitle("Новая программа")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Отмена") {
                                showingNewProgram = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTemplates) {
                OnboardingTemplateListView()
            }
            .sheet(item: $selectedProgram) { program in
                NavigationView {
                    OnboardingProgramView(program: program)
                }
            }
            .sheet(isPresented: $showingCreateProgram) {
                if let selectedTemplate = selectedTemplate {
                    CreateProgramFromTemplateView(template: selectedTemplate)
                }
            }
        }
    }
    
    private func loadPrograms() {
        // Programs are now loaded automatically from service
    }
    
    private func countForFilter(_ filter: FilterType) -> Int {
        switch filter {
        case .all:
            return service.programs.count
        case .inProgress:
            return service.programs.filter { $0.status == .inProgress }.count
        case .notStarted:
            return service.programs.filter { $0.status == .notStarted }.count
        case .completed:
            return service.programs.filter { $0.status == .completed }.count
        case .overdue:
            return service.programs.filter { $0.isOverdue }.count
        }
    }
}

// MARK: - Stats View
struct OnboardingStatsView: View {
    let programs: [OnboardingProgram]
    
    var activePrograms: Int {
        programs.filter { $0.status == .inProgress }.count
    }
    
    var completionRate: Double {
        guard !programs.isEmpty else { return 0 }
        let completed = programs.filter { $0.status == .completed }.count
        return Double(completed) / Double(programs.count) * 100
    }
    
    var averageProgress: Double {
        guard !programs.isEmpty else { return 0 }
        let totalProgress = programs.reduce(0) { $0 + $1.overallProgress }
        return totalProgress / Double(programs.count) * 100
    }
    
    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "person.3.fill",
                value: "\(programs.count)",
                title: "Всего программ",
                color: .blue
            )
            
            StatCard(
                icon: "person.fill.checkmark",
                value: "\(programs.filter { $0.status == .completed }.count)",
                title: "Завершено",
                color: .green
            )
            
            StatCard(
                icon: "clock.fill",
                value: "\(programs.filter { $0.status == .inProgress }.count)",
                title: "В процессе",
                color: .orange
            )
        }
        .padding()
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Filter Chip
struct OnboardingFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Program Card
struct OnboardingProgramCard: View {
    let program: OnboardingProgram
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Employee info
                VStack(alignment: .leading, spacing: 4) {
                    Text(program.employeeName)
                        .font(.headline)
                    
                    HStack {
                        Text(program.employeePosition)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(program.employeeDepartment)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status badge
                StatusBadge(status: program.status, isOverdue: program.isOverdue)
            }
            
            // Program title
            Text(program.title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
            
            // Progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Этап \(program.completedStages + 1) из \(program.stages.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(program.overallProgress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(program.isOverdue ? Color.red : Color.blue)
                            .frame(width: geometry.size.width * program.overallProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // Footer
            HStack {
                // Manager
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(program.managerName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Days remaining
                if program.status == .inProgress {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(program.isOverdue ? "Просрочено" : "Осталось \(program.daysRemaining) дн.")
                            .font(.caption)
                            .foregroundColor(program.isOverdue ? .red : .secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: OnboardingStatus
    let isOverdue: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
            
            Text(isOverdue && status == .inProgress ? "Просрочено" : status.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(12)
    }
    
    private var iconName: String {
        if isOverdue && status == .inProgress {
            return "exclamationmark.triangle.fill"
        }
        
        switch status {
        case .notStarted: return "clock"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    private var backgroundColor: Color {
        if isOverdue && status == .inProgress {
            return .red.opacity(0.1)
        }
        
        switch status {
        case .notStarted: return .gray.opacity(0.1)
        case .inProgress: return .blue.opacity(0.1)
        case .completed: return .green.opacity(0.1)
        case .cancelled: return .red.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        if isOverdue && status == .inProgress {
            return .red
        }
        
        switch status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - Empty State
struct OnboardingEmptyStateView: View {
    let filter: OnboardingDashboard.FilterType
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(emptyMessage)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(emptyDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {}) {
                Text("Создать программу")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyMessage: String {
        switch filter {
        case .all: return "Нет программ онбординга"
        case .inProgress: return "Нет активных программ"
        case .notStarted: return "Нет запланированных программ"
        case .completed: return "Нет завершенных программ"
        case .overdue: return "Нет просроченных программ"
        }
    }
    
    private var emptyDescription: String {
        switch filter {
        case .all: return "Создайте первую программу адаптации для новых сотрудников"
        case .inProgress: return "Все программы либо завершены, либо еще не начаты"
        case .notStarted: return "Все новые сотрудники уже начали адаптацию"
        case .completed: return "Пока нет завершенных программ адаптации"
        case .overdue: return "Отличная работа! Все программы идут по графику"
        }
    }
}

#Preview {
    OnboardingDashboard()
}
