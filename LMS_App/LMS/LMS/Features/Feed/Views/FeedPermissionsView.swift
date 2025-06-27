import SwiftUI

struct FeedPermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var studentPermissions = FeedPermissions.studentDefault
    @State private var adminPermissions = FeedPermissions.adminDefault
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Student permissions section
                Section {
                    Toggle("Создавать записи", isOn: .constant(studentPermissions.canPost))
                    Toggle("Комментировать", isOn: .constant(studentPermissions.canComment))
                    Toggle("Ставить лайки", isOn: .constant(studentPermissions.canLike))
                    Toggle("Делиться записями", isOn: .constant(studentPermissions.canShare))
                } header: {
                    Label("Права студентов", systemImage: "graduationcap")
                } footer: {
                    Text("Определите, какие действия могут выполнять студенты в ленте новостей")
                }
                
                // Admin permissions section
                Section {
                    Toggle("Создавать записи", isOn: .constant(adminPermissions.canPost))
                        .disabled(true)
                    Toggle("Комментировать", isOn: .constant(adminPermissions.canComment))
                        .disabled(true)
                    Toggle("Ставить лайки", isOn: .constant(adminPermissions.canLike))
                        .disabled(true)
                    Toggle("Делиться записями", isOn: .constant(adminPermissions.canShare))
                        .disabled(true)
                    Toggle("Удалять любые записи", isOn: .constant(adminPermissions.canDelete))
                        .disabled(true)
                    Toggle("Редактировать записи", isOn: .constant(adminPermissions.canEdit))
                        .disabled(true)
                } header: {
                    Label("Права администраторов", systemImage: "shield")
                } footer: {
                    Text("Администраторы имеют полный доступ ко всем функциям ленты")
                }
                
                // Visibility settings
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Кто может видеть записи:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(FeedVisibility.allCases, id: \.self) { visibility in
                            HStack {
                                Image(systemName: visibility.icon)
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading) {
                                    Text(visibility.title)
                                        .font(.subheadline)
                                    
                                    Text(visibilityDescription(for: visibility))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Label("Настройки видимости", systemImage: "eye")
                }
                
                // Moderation settings
                Section {
                    Toggle("Премодерация записей студентов", isOn: .constant(false))
                    Toggle("Премодерация комментариев", isOn: .constant(false))
                    Toggle("Автоматическая фильтрация контента", isOn: .constant(true))
                } header: {
                    Label("Модерация", systemImage: "shield.lefthalf.filled")
                } footer: {
                    Text("Включите премодерацию для проверки контента перед публикацией")
                }
            }
            .navigationTitle("Права доступа к ленте")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        savePermissions()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Сохранено", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Права доступа к ленте обновлены")
            }
        }
    }
    
    private func visibilityDescription(for visibility: FeedVisibility) -> String {
        switch visibility {
        case .everyone:
            return "Все пользователи системы"
        case .students:
            return "Только пользователи с ролью студента"
        case .admins:
            return "Только администраторы системы"
        case .specific:
            return "Определенные группы пользователей"
        }
    }
    
    private func savePermissions() {
        // In real app, would save to server
        showingSaveAlert = true
    }
}

#Preview {
    FeedPermissionsView()
} 