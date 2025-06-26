//
//  CourseAssignmentView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CourseAssignmentView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedUsers: Set<String> = []
    @State private var dueDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days default
    @State private var isMandatory = true
    @State private var showingConfirmation = false
    @State private var assignments: [CourseAssignment] = []
    
    // Mock users for demo
    let users = [
        UserResponse(
            id: "1", 
            email: "ivan@company.com", 
            firstName: "Иван", 
            lastName: "Петров", 
            middleName: nil,
            position: "Менеджер по продажам", 
            department: "Продажи", 
            avatar: nil,
            roles: ["employee"], 
            permissions: []
        ),
        UserResponse(
            id: "2", 
            email: "maria@company.com", 
            firstName: "Мария", 
            lastName: "Сидорова", 
            middleName: nil,
            position: "Старший продавец", 
            department: "Продажи", 
            avatar: nil,
            roles: ["employee"], 
            permissions: []
        ),
        UserResponse(
            id: "3", 
            email: "alexey@company.com", 
            firstName: "Алексей", 
            lastName: "Козлов", 
            middleName: nil,
            position: "Продавец-консультант", 
            department: "Продажи", 
            avatar: nil,
            roles: ["employee"], 
            permissions: []
        ),
        UserResponse(
            id: "4", 
            email: "elena@company.com", 
            firstName: "Елена", 
            lastName: "Васильева", 
            middleName: nil,
            position: "Менеджер отдела", 
            department: "Товароведение", 
            avatar: nil,
            roles: ["manager"], 
            permissions: []
        ),
        UserResponse(
            id: "5", 
            email: "dmitry@company.com", 
            firstName: "Дмитрий", 
            lastName: "Новиков", 
            middleName: nil,
            position: "Товаровед", 
            department: "Товароведение", 
            avatar: nil,
            roles: ["employee"], 
            permissions: []
        )
    ]
    
    var filteredUsers: [UserResponse] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            let fullName = "\(user.firstName) \(user.lastName)"
            return fullName.localizedCaseInsensitiveContains(searchText) ||
            user.email.localizedCaseInsensitiveContains(searchText) ||
            (user.position?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (user.department?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Course info header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: course.icon)
                            .font(.title2)
                            .foregroundColor(course.color)
                        
                        VStack(alignment: .leading) {
                            Text(course.title)
                                .font(.headline)
                            Text("Назначение курса сотрудникам")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    // Assignment settings
                    VStack(spacing: 12) {
                        Toggle("Обязательный курс", isOn: $isMandatory)
                        
                        DatePicker("Срок выполнения", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color(.systemGroupedBackground))
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск сотрудников", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Selected count
                if !selectedUsers.isEmpty {
                    HStack {
                        Text("Выбрано: \(selectedUsers.count)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Button("Снять выделение") {
                            selectedUsers.removeAll()
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)
                }
                
                // User list
                List(filteredUsers) { user in
                    UserSelectionRow(
                        user: user,
                        isSelected: selectedUsers.contains(user.id),
                        onToggle: {
                            if selectedUsers.contains(user.id) {
                                selectedUsers.remove(user.id)
                            } else {
                                selectedUsers.insert(user.id)
                            }
                        }
                    )
                }
                .listStyle(PlainListStyle())
                
                // Assign button
                Button(action: assignCourse) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Назначить курс (\(selectedUsers.count))")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedUsers.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .disabled(selectedUsers.isEmpty)
            }
            .navigationTitle("Назначение курса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert("Курс назначен", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Курс успешно назначен \(selectedUsers.count) сотрудникам")
            }
        }
    }
    
    private func assignCourse() {
        // Create assignments
        let currentUserId = MockAuthService.shared.currentUser?.id ?? "admin"
        
        for userId in selectedUsers {
            let assignment = CourseAssignment(
                courseId: course.id,
                userId: UUID(), // In real app, would convert from String
                assignedBy: UUID(), // In real app, would convert currentUserId
                assignedAt: Date(),
                dueDate: dueDate,
                completedAt: nil,
                isMandatory: isMandatory
            )
            assignments.append(assignment)
        }
        
        // In real app, would save to backend
        // await courseService.assignCourse(assignments)
        
        showingConfirmation = true
    }
}

// MARK: - User Selection Row
struct UserSelectionRow: View {
    let user: UserResponse
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if let position = user.position {
                            Text(position)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if user.department != nil {
                                Text("•")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let department = user.department {
                            Text(department)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CourseAssignmentView(
        course: Course.createMockCourses().first!
    )
} 