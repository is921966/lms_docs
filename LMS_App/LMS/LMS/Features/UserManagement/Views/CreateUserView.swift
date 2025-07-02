import SwiftUI

struct CreateUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var selectedRole: DomainUserRole = .student
    @State private var department: String = ""
    @State private var position: String = ""
    @State private var phoneNumber: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isCreating = false
    
    let onUserCreated: (CreateUserDTO) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Имя", text: $firstName)
                    
                    TextField("Фамилия", text: $lastName)
                    
                    Picker("Роль", selection: $selectedRole) {
                        ForEach(DomainUserRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                }
                
                Section("Дополнительная информация") {
                    TextField("Отдел", text: $department)
                    
                    TextField("Должность", text: $position)
                    
                    TextField("Телефон", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Новый пользователь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createUser()
                    }
                    .disabled(!isFormValid || isCreating)
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty
    }
    
    private func createUser() {
        guard isFormValid else { return }
        
        isCreating = true
        
        let createDTO = CreateUserDTO(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            role: selectedRole.rawValue,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            department: department.isEmpty ? nil : department.trimmingCharacters(in: .whitespacesAndNewlines),
            position: position.isEmpty ? nil : position.trimmingCharacters(in: .whitespacesAndNewlines),
            password: nil
        )
        
        let validationErrors = createDTO.validationErrors()
        if validationErrors.isEmpty {
            onUserCreated(createDTO)
        } else {
            errorMessage = validationErrors.joined(separator: "\n")
            showingError = true
        }
        
        isCreating = false
    }
}

struct CreateUserView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserView { _ in }
    }
} 