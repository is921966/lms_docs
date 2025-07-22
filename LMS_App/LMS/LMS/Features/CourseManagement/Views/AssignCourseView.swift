//
//  AssignCourseView.swift
//  LMS
//
//  Created on Sprint 40 - Course Management Enhancement
//

import SwiftUI

struct AssignCourseView: View {
    let course: ManagedCourse
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AssignCourseViewModel()
    
    @State private var searchText = ""
    @State private var selectedStudents = Set<UUID>()
    @State private var deadline: Date = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Course Header
                courseHeader
                
                // Search Bar
                searchBar
                
                // Students List
                studentsList
                
                // Bottom Bar with Selected Count
                if !selectedStudents.isEmpty {
                    selectedStudentsBar
                }
                
                // Assignment Settings
                assignmentSettings
            }
            .navigationTitle("Назначить курс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Назначить") {
                        showingConfirmation = true
                    }
                    .disabled(selectedStudents.isEmpty)
                }
            }
            .alert("Подтвердить назначение", isPresented: $showingConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Назначить") {
                    assignCourse()
                }
            } message: {
                Text("Назначить курс '\(course.title)' для \(selectedStudents.count) студентов?")
            }
            .onAppear {
                viewModel.loadStudents()
            }
        }
    }
    
    // MARK: - Views
    
    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title)
                .font(.headline)
            
            HStack {
                Label("\(course.duration) часов", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if course.cmi5PackageId != nil {
                    Label("Cmi5", systemImage: "cube.box.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Поиск студентов...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var studentsList: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filteredStudents) { student in
                        StudentRowView(
                            student: student,
                            isSelected: selectedStudents.contains(student.id)
                        ) {
                            toggleSelection(for: student.id)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    private var selectedStudentsBar: some View {
        HStack {
            Text("Выбрано: \(selectedStudents.count)")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button("Очистить") {
                selectedStudents.removeAll()
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
    }
    
    private var assignmentSettings: some View {
        VStack(spacing: 16) {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Настройки назначения")
                    .font(.headline)
                
                DatePicker(
                    "Срок выполнения",
                    selection: $deadline,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
            }
            .padding()
        }
    }
    
    // MARK: - Helpers
    
    private var filteredStudents: [Student] {
        if searchText.isEmpty {
            return viewModel.students
        }
        
        return viewModel.students.filter { student in
            student.name.localizedCaseInsensitiveContains(searchText) ||
            student.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func toggleSelection(for studentId: UUID) {
        if selectedStudents.contains(studentId) {
            selectedStudents.remove(studentId)
        } else {
            selectedStudents.insert(studentId)
        }
    }
    
    private func assignCourse() {
        viewModel.assignCourse(
            courseId: course.id,
            studentIds: Array(selectedStudents),
            deadline: deadline
        )
        dismiss()
    }
}

// MARK: - Student Row View

struct StudentRowView: View {
    let student: Student
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(student.initials)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    )
                
                // Student Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(student.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(student.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .imageScale(.large)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    AssignCourseView(
        course: ManagedCourse(
            title: "Основы Swift",
            description: "Изучите основы языка программирования Swift",
            duration: 40,
            status: .published
        )
    )
} 