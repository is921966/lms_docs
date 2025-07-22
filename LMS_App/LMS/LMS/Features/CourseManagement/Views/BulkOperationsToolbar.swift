//
//  BulkOperationsToolbar.swift
//  LMS
//
//  Toolbar for bulk operations on courses
//

import SwiftUI

struct BulkOperationsToolbar: View {
    @ObservedObject var viewModel: CourseManagementViewModel
    @State private var showingDeleteConfirmation = false
    @State private var showingAssignView = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Selection info
            HStack {
                Text("Выбрано: \(viewModel.selectionCount)")
                    .font(.headline)
                Spacer()
                Button("Снять выбор") {
                    viewModel.deselectAllCourses()
                }
                .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Delete
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        VStack {
                            Image(systemName: "trash")
                                .font(.title2)
                            Text("Удалить")
                                .font(.caption)
                        }
                        .frame(width: 70)
                    }
                    .foregroundColor(.red)
                    .accessibilityIdentifier("bulkDeleteButton")
                    
                    // Archive
                    Button(action: {
                        Task {
                            isProcessing = true
                            do {
                                try await viewModel.bulkArchiveSelectedCourses()
                            } catch {
                                // Error handled in viewModel
                            }
                            isProcessing = false
                        }
                    }) {
                        VStack {
                            Image(systemName: "archivebox")
                                .font(.title2)
                            Text("Архивировать")
                                .font(.caption)
                        }
                        .frame(width: 70)
                    }
                    .accessibilityIdentifier("bulkArchiveButton")
                    
                    // Publish
                    Button(action: {
                        Task {
                            isProcessing = true
                            do {
                                try await viewModel.bulkPublishSelectedCourses()
                            } catch {
                                // Error handled in viewModel
                            }
                            isProcessing = false
                        }
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                            Text("Опубликовать")
                                .font(.caption)
                        }
                        .frame(width: 80)
                    }
                    .foregroundColor(.green)
                    .accessibilityIdentifier("bulkPublishButton")
                    
                    // Assign
                    Button(action: {
                        showingAssignView = true
                    }) {
                        VStack {
                            Image(systemName: "person.2")
                                .font(.title2)
                            Text("Назначить")
                                .font(.caption)
                        }
                        .frame(width: 70)
                    }
                    .foregroundColor(.blue)
                    .accessibilityIdentifier("bulkAssignButton")
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .center) {
            if isProcessing {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .confirmationDialog(
            "Удалить выбранные курсы?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                Task {
                    isProcessing = true
                    do {
                        try await viewModel.bulkDeleteSelectedCourses()
                    } catch {
                        // Error handled in viewModel
                    }
                    isProcessing = false
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Это действие нельзя отменить. Выбрано курсов: \(viewModel.selectionCount)")
        }
        .sheet(isPresented: $showingAssignView) {
            BulkAssignView(viewModel: viewModel)
        }
        .disabled(isProcessing)
    }
}

// MARK: - Bulk Assign View

struct BulkAssignView: View {
    @ObservedObject var viewModel: CourseManagementViewModel
    @State private var selectedStudentIds = Set<UUID>()
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    // Mock students for demo
    let mockStudents = [
        (id: UUID(), name: "Иван Иванов", email: "ivan@example.com"),
        (id: UUID(), name: "Мария Петрова", email: "maria@example.com"),
        (id: UUID(), name: "Алексей Сидоров", email: "alex@example.com"),
        (id: UUID(), name: "Елена Козлова", email: "elena@example.com"),
        (id: UUID(), name: "Дмитрий Новиков", email: "dmitry@example.com")
    ]
    
    var filteredStudents: [(id: UUID, name: String, email: String)] {
        if searchText.isEmpty {
            return mockStudents
        }
        return mockStudents.filter { student in
            student.name.localizedCaseInsensitiveContains(searchText) ||
            student.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск студентов...", text: $searchText)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Students list
                List(filteredStudents, id: \.id) { student in
                    HStack {
                        Image(systemName: selectedStudentIds.contains(student.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedStudentIds.contains(student.id) ? .blue : .gray)
                        
                        VStack(alignment: .leading) {
                            Text(student.name)
                                .font(.headline)
                            Text(student.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedStudentIds.contains(student.id) {
                            selectedStudentIds.remove(student.id)
                        } else {
                            selectedStudentIds.insert(student.id)
                        }
                    }
                }
                
                // Selected count
                if !selectedStudentIds.isEmpty {
                    Text("Выбрано студентов: \(selectedStudentIds.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle("Назначить студентам")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Назначить") {
                        Task {
                            do {
                                try await viewModel.bulkAssignSelectedCoursesToStudents(Array(selectedStudentIds))
                                dismiss()
                            } catch {
                                // Error handled in viewModel
                            }
                        }
                    }
                    .disabled(selectedStudentIds.isEmpty)
                }
            }
        }
    }
}

#Preview {
    BulkOperationsToolbar(viewModel: CourseManagementViewModel())
} 