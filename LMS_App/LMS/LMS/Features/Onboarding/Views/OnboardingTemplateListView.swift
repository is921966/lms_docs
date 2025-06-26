//
//  OnboardingTemplateListView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct OnboardingTemplateListView: View {
    @State private var templates: [OnboardingTemplate] = []
    @State private var searchText = ""
    @State private var selectedTemplate: OnboardingTemplate?
    @State private var showingNewTemplate = false
    @Environment(\.dismiss) private var dismiss
    
    var filteredTemplates: [OnboardingTemplate] {
        if searchText.isEmpty {
            return templates
        }
        return templates.filter { template in
            template.title.localizedCaseInsensitiveContains(searchText) ||
            template.targetPosition.localizedCaseInsensitiveContains(searchText) ||
            (template.targetDepartment?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск шаблонов", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                if filteredTemplates.isEmpty {
                    TemplateEmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTemplates) { template in
                                TemplateCardView(template: template) {
                                    selectedTemplate = template
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Шаблоны онбординга")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewTemplate = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                loadTemplates()
            }
            .sheet(item: $selectedTemplate) { template in
                TemplateDetailView(template: template)
            }
            .sheet(isPresented: $showingNewTemplate) {
                // NewTemplateView()
                Text("Создание нового шаблона")
            }
        }
    }
    
    private func loadTemplates() {
        templates = OnboardingTemplate.mockTemplates
    }
}

// MARK: - Template Card
struct TemplateCardView: View {
    let template: OnboardingTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(template.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: template.icon)
                            .font(.system(size: 24))
                            .foregroundColor(template.color)
                    }
                    
                    // Title and position
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(template.targetPosition)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let department = template.targetDepartment {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(department)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Active status
                    if template.isActive {
                        Text("Активен")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(10)
                    }
                }
                
                // Description
                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Stats
                HStack(spacing: 20) {
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(template.duration) дней")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Stages
                    HStack(spacing: 4) {
                        Image(systemName: "flag.checkered")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(template.stages.count) этапов")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Tasks
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.square")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(totalTasks(in: template)) задач")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Last update
                    Text("Обновлен \(formatDate(template.updatedAt))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func totalTasks(in template: OnboardingTemplate) -> Int {
        template.stages.reduce(0) { $0 + $1.taskTemplates.count }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Template Detail View
struct TemplateDetailView: View {
    let template: OnboardingTemplate
    @State private var expandedStages: Set<UUID> = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    TemplateHeaderView(template: template)
                    
                    // Stages
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Этапы программы")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(template.stages) { stage in
                            TemplateStageCard(
                                stage: stage,
                                isExpanded: expandedStages.contains(stage.id)
                            ) {
                                withAnimation {
                                    if expandedStages.contains(stage.id) {
                                        expandedStages.remove(stage.id)
                                    } else {
                                        expandedStages.insert(stage.id)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Создать программу из шаблона")
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text("Редактировать шаблон")
                                Spacer()
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Детали шаблона")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Template Header View
struct TemplateHeaderView: View {
    let template: OnboardingTemplate
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(template.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: template.icon)
                    .font(.system(size: 40))
                    .foregroundColor(template.color)
            }
            
            // Title
            Text(template.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Target info
            HStack {
                Label(template.targetPosition, systemImage: "person.fill")
                if let department = template.targetDepartment {
                    Text("•")
                    Text(department)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            // Description
            Text(template.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Stats
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(template.duration)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("дней")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(template.stages.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("этапов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(totalTasks(in: template))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("задач")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func totalTasks(in template: OnboardingTemplate) -> Int {
        template.stages.reduce(0) { $0 + $1.taskTemplates.count }
    }
}

// MARK: - Template Stage Card
struct TemplateStageCard: View {
    let stage: OnboardingTemplateStage
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Stage header
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Этап \(stage.orderIndex): \(stage.title)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(stage.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(isExpanded ? nil : 1)
                        }
                        
                        HStack(spacing: 16) {
                            Label("\(stage.duration) дн.", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Label("\(stage.taskTemplates.count) задач", systemImage: "checkmark.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            // Tasks (expanded)
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(stage.taskTemplates) { task in
                        HStack(spacing: 12) {
                            Image(systemName: getTaskIcon(task.type))
                                .font(.system(size: 16))
                                .foregroundColor(getTaskColor(task.type))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(task.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            if let duration = task.estimatedDuration {
                                Text("\(duration / 60) ч.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func getTaskIcon(_ type: TaskType) -> String {
        switch type {
        case .course: return "book.closed.fill"
        case .test: return "doc.text.fill"
        case .document: return "doc.fill"
        case .meeting: return "person.2.fill"
        case .task: return "checkmark.square.fill"
        case .feedback: return "bubble.left.and.bubble.right.fill"
        }
    }
    
    private func getTaskColor(_ type: TaskType) -> Color {
        switch type {
        case .course: return .blue
        case .test: return .purple
        case .document: return .orange
        case .meeting: return .green
        case .task: return .gray
        case .feedback: return .pink
        }
    }
}

// MARK: - Empty State
struct TemplateEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Шаблоны не найдены")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Попробуйте изменить параметры поиска или создайте новый шаблон")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    OnboardingTemplateListView()
} 