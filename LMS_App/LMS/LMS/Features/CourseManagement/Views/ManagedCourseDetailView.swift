//
//  CourseDetailView.swift
//  LMS
//
//  Created on Sprint 40 - Course Management Enhancement
//

import SwiftUI

struct ManagedCourseDetailView: View {
    let courseId: UUID
    @StateObject private var viewModel: CourseDetailViewModel
    @State private var showingEditView = false
    @State private var showingAssignView = false
    @State private var showingDeleteAlert = false
    @State private var showingModuleManagement = false
    @State private var showingCompetencyBinding = false
    @State private var showingPreview = false
    @Environment(\.dismiss) var dismiss
    @State private var showingDuplicationProgress = false
    @State private var duplicationError: String?
    
    init(courseId: UUID) {
        self.courseId = courseId
        self._viewModel = StateObject(wrappedValue: CourseDetailViewModel(courseId: courseId))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
            } else if let course = viewModel.course {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    headerSection(course: course)
                    
                    // Status and Info Section
                    infoSection(course: course)
                    
                    // Description Section
                    descriptionSection(course: course)
                    
                    // Modules Section
                    modulesSection(course: course)
                    
                    // Competencies Section
                    competenciesSection(course: course)
                    
                    // Actions Section
                    actionsSection()
                }
                .padding()
            } else {
                ContentUnavailableView(
                    "Курс не найден",
                    systemImage: "book.closed",
                    description: Text("Не удалось загрузить информацию о курсе")
                )
            }
        }
        .navigationTitle("Детали курса")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingAssignView = true
                    }) {
                        Label("Назначить студентам", systemImage: "person.2")
                    }
                    
                    Button(action: {
                        duplicateCourse()
                    }) {
                        Label("Дублировать курс", systemImage: "doc.on.doc")
                    }
                    
                    Divider()
                    
                    if viewModel.course?.status == .draft {
                        Button(action: {
                            viewModel.publishCourse()
                        }) {
                            Label("Опубликовать", systemImage: "checkmark.circle")
                        }
                    } else if viewModel.course?.status == .published {
                        Button(action: {
                            viewModel.archiveCourse()
                        }) {
                            Label("Архивировать", systemImage: "archivebox")
                        }
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Удалить курс", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .accessibilityIdentifier("courseDetailMenuButton")
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            if let course = viewModel.course {
                EditCourseView(course: course) { updatedCourse in
                    viewModel.updateCourse(updatedCourse)
                }
            }
        }
        .sheet(isPresented: $showingAssignView) {
            if let course = viewModel.course {
                AssignCourseView(course: course)
            }
        }
        .alert("Удалить курс?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                viewModel.deleteCourse()
                dismiss()
            }
        } message: {
            Text("Это действие нельзя отменить. Все данные курса будут удалены.")
        }
        .sheet(isPresented: $showingModuleManagement) {
            if var course = viewModel.course {
                ModuleManagementView(modules: Binding(
                    get: { course.modules },
                    set: { newModules in
                        course.modules = newModules
                        viewModel.updateCourse(course)
                    }
                ))
            }
        }
        .sheet(isPresented: $showingCompetencyBinding) {
            if let course = viewModel.course {
                CompetencyBindingView(course: course) { updatedCourse in
                    viewModel.updateCourse(updatedCourse)
                }
            }
        }
        .overlay {
            if showingDuplicationProgress {
                ProgressView("Дублирование курса...")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .alert("Ошибка дублирования", isPresented: .constant(duplicationError != nil)) {
            Button("OK") {
                duplicationError = nil
            }
        } message: {
            if let error = duplicationError {
                Text(error)
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let course = viewModel.course {
                CoursePreviewView(course: course)
            }
        }
        .onAppear {
            viewModel.loadCourse()
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private func headerSection(course: ManagedCourse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(course.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Cmi5 indicator
                if course.cmi5PackageId != nil {
                    Label("Cmi5", systemImage: "cube.box.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            CourseStatusBadge(status: course.status)
        }
    }
    
    @ViewBuilder
    private func infoSection(course: ManagedCourse) -> some View {
        HStack(spacing: 20) {
            Label("\(course.duration) часов", systemImage: "clock")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Label("\(course.modules.count) модулей", systemImage: "rectangle.stack")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !course.competencies.isEmpty {
                Label("\(course.competencies.count) компетенций", systemImage: "checkmark.seal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func descriptionSection(course: ManagedCourse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            
            Text(course.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func modulesSection(course: ManagedCourse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Модули")
                    .font(.headline)
                
                Spacer()
                
                Button("Управлять") {
                    showingModuleManagement = true
                }
                .font(.subheadline)
            }
            
            if course.modules.isEmpty {
                Text("Модули не добавлены")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                VStack(spacing: 8) {
                    ForEach(course.modules.sorted(by: { $0.order < $1.order })) { module in
                        ModuleRowView(module: module)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func competenciesSection(course: ManagedCourse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Компетенции")
                    .font(.headline)
                
                Spacer()
                
                Button("Управлять") {
                    showingCompetencyBinding = true
                }
                .font(.subheadline)
            }
            
            if course.competencies.isEmpty {
                Text("Компетенции не привязаны")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                // TODO: Show competencies when CompetencyService is integrated
                Text("\(course.competencies.count) компетенций привязано")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func actionsSection() -> some View {
        VStack(spacing: 12) {
            Button {
                showingAssignView = true
            } label: {
                Label("Назначить студентам", systemImage: "person.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("assignStudentsButton")
            
            Button {
                showingPreview = true
            } label: {
                Label("Предпросмотр курса", systemImage: "eye")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("previewCourseButton")
        }
        .padding(.top, 20)
    }
    
    // MARK: - Private Methods
    
    private func duplicateCourse() {
        guard let course = viewModel.course else { return }
        
        showingDuplicationProgress = true
        
        Task {
            do {
                // Используем глобальный CourseManagementViewModel для дублирования
                if let courseManagementVM = try? await getCourseManagementViewModel() {
                    try await courseManagementVM.duplicateCourse(course.id)
                    
                    await MainActor.run {
                        showingDuplicationProgress = false
                        dismiss()
                    }
                } else {
                    // Fallback - используем локальный метод
                    viewModel.duplicateCourse()
                    
                    await MainActor.run {
                        showingDuplicationProgress = false
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    showingDuplicationProgress = false
                    duplicationError = error.localizedDescription
                }
            }
        }
    }
    
    private func getCourseManagementViewModel() async throws -> CourseManagementViewModel? {
        // В реальном приложении это бы получалось через DI или Environment
        // Пока возвращаем nil для использования fallback
        return nil
    }
}

// MARK: - Module Row View

struct ModuleRowView: View {
    let module: ManagedCourseModule
    
    var body: some View {
        HStack {
            Image(systemName: module.contentType.icon)
                .foregroundColor(module.contentType.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(module.order). \(module.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(module.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("\(module.duration) мин")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Extensions
// ContentType extensions moved to ModuleManagementViewModel.swift

#Preview {
    NavigationStack {
        ManagedCourseDetailView(courseId: UUID())
    }
} 