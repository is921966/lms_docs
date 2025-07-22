//
//  CompetencyBindingView.swift
//  LMS
//
//  View for binding competencies to courses
//

import SwiftUI

struct CompetencyBindingView: View {
    @StateObject private var viewModel: CompetencyBindingViewModel
    @Environment(\.dismiss) var dismiss
    
    let onSave: (ManagedCourse) -> Void
    
    init(course: ManagedCourse, onSave: @escaping (ManagedCourse) -> Void) {
        self._viewModel = StateObject(wrappedValue: CompetencyBindingViewModel(course: course))
        self.onSave = onSave
    }
    
    // For testing
    init(viewModel: CompetencyBindingViewModel, onSave: @escaping (ManagedCourse) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка компетенций...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.availableCompetencies.isEmpty {
                    emptyStateView
                } else {
                    competencyListView
                }
            }
            .navigationTitle("Привязка компетенций")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        Task {
                            let updatedCourse = await viewModel.saveCompetencies()
                            onSave(updatedCourse)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
        }
        .task {
            await viewModel.loadCompetencies()
        }
    }
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Компетенции не найдены")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("В системе пока нет доступных компетенций")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
    
    private var competencyListView: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            VStack(spacing: 12) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Поиск компетенций", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Level filter
                if !viewModel.availableLevels.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CompetencyFilterChip(
                                title: "Все уровни",
                                isSelected: viewModel.selectedLevel == nil,
                                action: { viewModel.selectedLevel = nil }
                            )
                            
                            ForEach(viewModel.availableLevels, id: \.self) { level in
                                CompetencyFilterChip(
                                    title: "Уровень \(level)",
                                    isSelected: viewModel.selectedLevel == level,
                                    action: { viewModel.selectedLevel = level }
                                )
                            }
                        }
                    }
                }
                
                // Selected count
                HStack {
                    Text("Выбрано: \(viewModel.selectedCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if viewModel.selectedCount > 0 {
                        Button("Очистить") {
                            viewModel.selectedCompetencies.removeAll()
                        }
                        .font(.subheadline)
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Competency list
            List {
                ForEach(viewModel.filteredCompetencies) { competency in
                    CompetencyRowView(
                        competency: competency,
                        isSelected: viewModel.isSelected(competency),
                        onToggle: { viewModel.toggleCompetency(competency) }
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

// MARK: - Competency Row View

struct CompetencyRowView: View {
    let competency: Competency
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(competency.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(competency.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label("Уровень \(competency.currentLevel)", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        if competency.requiredLevel > competency.currentLevel {
                            Label("Требуется: \(competency.requiredLevel)", systemImage: "arrow.up.circle")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .imageScale(.large)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Chip

struct CompetencyFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CompetencyBindingView(
        course: ManagedCourse(
            title: "Test Course",
            description: "Test",
            duration: 40,
            status: .draft
        )
    ) { _ in }
} 