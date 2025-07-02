import SwiftUI

struct UserDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let user: DomainUser
    let onUserUpdated: (UpdateUserDTO) -> Void
    
    @State private var isEditing = false
    @State private var email: String
    @State private var firstName: String
    @State private var lastName: String
    @State private var selectedRole: DomainUserRole
    @State private var department: String
    @State private var position: String
    @State private var phoneNumber: String
    @State private var isActive: Bool
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isUpdating = false
    
    init(user: DomainUser, onUserUpdated: @escaping (UpdateUserDTO) -> Void) {
        self.user = user
        self.onUserUpdated = onUserUpdated
        
        // Initialize state variables
        _email = State(initialValue: user.email)
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _selectedRole = State(initialValue: user.role)
        _department = State(initialValue: user.department ?? "")
        _position = State(initialValue: user.position ?? "")
        _phoneNumber = State(initialValue: user.phoneNumber ?? "")
        _isActive = State(initialValue: user.isActive)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Header
                    userHeaderSection
                    
                    // User Information
                    userInformationSection
                    
                    // Statistics
                    userStatisticsSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Профиль пользователя")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        HStack {
                            Button("Отмена") {
                                cancelEditing()
                            }
                            
                            Button("Сохранить") {
                                saveChanges()
                            }
                            .disabled(!isFormValid || isUpdating)
                        }
                    } else {
                        Button("Редактировать") {
                            isEditing = true
                        }
                    }
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - User Header Section
    private var userHeaderSection: some View {
        VStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(user.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(user.initials)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(user.isActive ? .green : .gray)
                )
            
            // Name and Status
            VStack(spacing: 4) {
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Text(user.role.displayName)
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(user.role.color.opacity(0.2))
                        .foregroundColor(user.role.color)
                        .cornerRadius(6)
                    
                    if !user.isActive {
                        Text("Неактивен")
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - User Information Section
    private var userInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация")
                .font(.headline)
            
            if isEditing {
                editingForm
            } else {
                informationDisplay
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var editingForm: some View {
        VStack(spacing: 12) {
            TextField("Имя", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Фамилия", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Отдел", text: $department)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Должность", text: $position)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Телефон", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
            
            Toggle("Активен", isOn: $isActive)
        }
    }
    
    private var informationDisplay: some View {
        VStack(spacing: 12) {
            UserInfoRow(label: "Email", value: user.email)
            UserInfoRow(label: "Имя", value: user.firstName)
            UserInfoRow(label: "Фамилия", value: user.lastName)
            UserInfoRow(label: "Роль", value: user.role.displayName)
            
            if let department = user.department {
                UserInfoRow(label: "Отдел", value: department)
            }
            
            if let position = user.position {
                UserInfoRow(label: "Должность", value: position)
            }
            
            if let phoneNumber = user.phoneNumber {
                UserInfoRow(label: "Телефон", value: phoneNumber)
            }
            
            UserInfoRow(label: "Статус", value: user.isActive ? "Активен" : "Неактивен")
        }
    }
    
    // MARK: - User Statistics Section
    private var userStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Активность")
                .font(.headline)
            
            VStack(spacing: 12) {
                if let lastLogin = user.lastLoginAt {
                    UserInfoRow(label: "Последний вход", value: formatDate(lastLogin))
                } else {
                    UserInfoRow(label: "Последний вход", value: "Никогда")
                }
                
                UserInfoRow(label: "Дата создания", value: formatDate(user.createdAt))
                UserInfoRow(label: "Последнее обновление", value: formatDate(user.updatedAt))
                
                if user.isRecentlyActive {
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Недавно активен")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty
    }
    
    private func cancelEditing() {
        // Reset to original values
        email = user.email
        firstName = user.firstName
        lastName = user.lastName
        selectedRole = user.role
        department = user.department ?? ""
        position = user.position ?? ""
        phoneNumber = user.phoneNumber ?? ""
        isActive = user.isActive
        
        isEditing = false
    }
    
    private func saveChanges() {
        guard isFormValid else { return }
        
        isUpdating = true
        
        let updateDTO = UpdateUserDTO(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            department: department.isEmpty ? nil : department.trimmingCharacters(in: .whitespacesAndNewlines),
            position: position.isEmpty ? nil : position.trimmingCharacters(in: .whitespacesAndNewlines),
            profileImageUrl: nil,
            isActive: isActive
        )
        
        let validationErrors = updateDTO.validationErrors()
        if validationErrors.isEmpty {
            onUserUpdated(updateDTO)
            isEditing = false
        } else {
            errorMessage = validationErrors.joined(separator: "\n")
            showingError = true
        }
        
        isUpdating = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct UserInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = DomainUser(
            id: "sample-user-id",
            email: "john.doe@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .teacher,
            isActive: true,
            profileImageUrl: nil,
            phoneNumber: "+7 (999) 123-45-67",
            department: "Engineering",
            position: "Senior Developer",
            lastLoginAt: Date(),
            createdAt: Date().addingTimeInterval(-86400 * 30),
            updatedAt: Date()
        )
        
        UserDetailView(user: sampleUser) { _ in }
    }
} 