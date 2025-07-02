import SwiftUI

struct UserFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: UserListViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Фильтры") {
                    // Role Filter
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Роль")
                            .font(.headline)
                        
                        Picker("Роль", selection: $viewModel.selectedRole) {
                            Text("Все роли").tag(nil as DomainUserRole?)
                            ForEach(viewModel.availableRoles, id: \.self) { role in
                                Text(role.displayName).tag(role as DomainUserRole?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Department Filter
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Отдел")
                            .font(.headline)
                        
                        Picker("Отдел", selection: $viewModel.selectedDepartment) {
                            Text("Все отделы").tag(nil as String?)
                            ForEach(viewModel.availableDepartments, id: \.self) { department in
                                Text(department).tag(department as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section("Действия") {
                    Button("Очистить все фильтры") {
                        viewModel.clearAllFilters()
                    }
                    .foregroundColor(.red)
                    .disabled(!viewModel.hasActiveFilters)
                }
            }
            .navigationTitle("Фильтры")
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

struct UserFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        UserFiltersView(viewModel: UserListViewModel())
    }
} 