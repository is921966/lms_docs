//
//  CourseFilterView.swift
//  LMS
//
//  View for filtering courses
//

import SwiftUI

struct CourseFilterView: View {
    @ObservedObject var filterViewModel: CourseFilterViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Status Section
                statusSection
                
                // Type Section
                typeSection
                
                // Modules Section
                modulesSection
                
                // Competencies Section
                competenciesSection
                
                // Clear Filters
                if filterViewModel.hasActiveFilters {
                    clearFiltersSection
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Применить") {
                        filterViewModel.saveFilterState()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var statusSection: some View {
        Section("Статус курса") {
            ForEach([nil, ManagedCourseStatus.draft, .published, .archived], id: \.self) { status in
                HStack {
                    if let status = status {
                        Label(status.displayName, systemImage: status.icon)
                            .foregroundColor(status.color)
                    } else {
                        Label("Все статусы", systemImage: "checkmark.circle")
                    }
                    
                    Spacer()
                    
                    if filterViewModel.selectedStatus == status {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    filterViewModel.selectedStatus = status
                }
            }
        }
    }
    
    private var typeSection: some View {
        Section("Тип курса") {
            FilterToggleRow(
                title: "Только Cmi5 курсы",
                icon: "cube.box.fill",
                iconColor: .blue,
                isOn: $filterViewModel.showOnlyCmi5,
                onChange: { if $0 { filterViewModel.showOnlyRegular = false } }
            )
            
            FilterToggleRow(
                title: "Только обычные курсы",
                icon: "book.fill",
                iconColor: .green,
                isOn: $filterViewModel.showOnlyRegular,
                onChange: { if $0 { filterViewModel.showOnlyCmi5 = false } }
            )
        }
    }
    
    private var modulesSection: some View {
        Section("Модули") {
            FilterToggleRow(
                title: "С модулями",
                icon: "rectangle.stack.fill",
                iconColor: .orange,
                isOn: $filterViewModel.showOnlyWithModules,
                onChange: { if $0 { filterViewModel.showOnlyWithoutModules = false } }
            )
            
            FilterToggleRow(
                title: "Без модулей",
                icon: "rectangle.stack.badge.minus",
                iconColor: .gray,
                isOn: $filterViewModel.showOnlyWithoutModules,
                onChange: { if $0 { filterViewModel.showOnlyWithModules = false } }
            )
        }
    }
    
    private var competenciesSection: some View {
        Section("Компетенции") {
            FilterToggleRow(
                title: "С компетенциями",
                icon: "checkmark.seal.fill",
                iconColor: .purple,
                isOn: $filterViewModel.showOnlyWithCompetencies,
                onChange: { if $0 { filterViewModel.showOnlyWithoutCompetencies = false } }
            )
            
            FilterToggleRow(
                title: "Без компетенций",
                icon: "xmark.seal",
                iconColor: .gray,
                isOn: $filterViewModel.showOnlyWithoutCompetencies,
                onChange: { if $0 { filterViewModel.showOnlyWithCompetencies = false } }
            )
        }
    }
    
    private var clearFiltersSection: some View {
        Section {
            Button(role: .destructive) {
                filterViewModel.clearFilters()
            } label: {
                HStack {
                    Spacer()
                    Label("Сбросить фильтры", systemImage: "xmark.circle.fill")
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Filter Toggle Row

struct FilterToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    var onChange: ((Bool) -> Void)? = nil
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { isOn },
            set: { newValue in
                isOn = newValue
                onChange?(newValue)
            }
        )) {
            Label(title, systemImage: icon)
                .foregroundColor(isOn ? iconColor : .primary)
        }
        .toggleStyle(SwitchToggleStyle(tint: iconColor))
    }
}

// MARK: - Active Filters Bar

struct ActiveFiltersBar: View {
    @ObservedObject var filterViewModel: CourseFilterViewModel
    
    var body: some View {
        if filterViewModel.hasActiveFilters {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Label("\(filterViewModel.activeFilterCount) фильтров", systemImage: "line.3.horizontal.decrease.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Show active filter chips
                    if let status = filterViewModel.selectedStatus {
                        CourseFilterChip(title: status.displayName, color: status.color)
                    }
                    
                    if filterViewModel.showOnlyCmi5 {
                        CourseFilterChip(title: "Cmi5", color: .blue)
                    }
                    
                    if filterViewModel.showOnlyRegular {
                        CourseFilterChip(title: "Обычные", color: .green)
                    }
                    
                    if filterViewModel.showOnlyWithModules {
                        CourseFilterChip(title: "С модулями", color: .orange)
                    }
                    
                    if filterViewModel.showOnlyWithoutModules {
                        CourseFilterChip(title: "Без модулей", color: .gray)
                    }
                    
                    if filterViewModel.showOnlyWithCompetencies {
                        CourseFilterChip(title: "С компетенциями", color: .purple)
                    }
                    
                    if filterViewModel.showOnlyWithoutCompetencies {
                        CourseFilterChip(title: "Без компетенций", color: .gray)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 40)
        }
    }
}

// MARK: - Filter Chip

struct CourseFilterChip: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(6)
    }
}

// MARK: - Extensions
// ManagedCourseStatus extensions already exist in ManagedCourse.swift

#Preview {
    CourseFilterView(
        filterViewModel: CourseFilterViewModel(courses: [])
    )
} 