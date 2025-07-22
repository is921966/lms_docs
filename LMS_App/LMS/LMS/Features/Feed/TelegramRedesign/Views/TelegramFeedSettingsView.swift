import SwiftUI

struct TelegramFeedSettingsView: View {
    let onDismiss: () -> Void
    
    // Notification settings
    @AppStorage("feedNotifications_announcement") private var announcementNotifications = true
    @AppStorage("feedNotifications_learning") private var learningNotifications = true
    @AppStorage("feedNotifications_achievement") private var achievementNotifications = true
    @AppStorage("feedNotifications_event") private var eventNotifications = true
    @AppStorage("feedNotifications_department") private var departmentNotifications = true
    
    // Priority settings
    @AppStorage("feedPriority_pinAnnouncements") private var pinAnnouncements = true
    @AppStorage("feedPriority_showUnreadFirst") private var showUnreadFirst = true
    
    var body: some View {
        NavigationView {
            Form {
                // Notification Settings Section
                Section(header: Text("Уведомления")) {
                    ForEach(NewsCategory.allCases, id: \.self) { category in
                        Toggle(
                            category.title,
                            isOn: binding(for: category)
                        )
                    }
                }
                
                // Priority Settings Section
                Section(header: Text("Приоритет")) {
                    Toggle("Закреплять важные объявления", isOn: $pinAnnouncements)
                    Toggle("Показывать непрочитанные сверху", isOn: $showUnreadFirst)
                }
                
                // About Section
                Section(header: Text("О настройках")) {
                    Text("Настройте какие категории новостей вы хотите получать и как они должны отображаться в ленте.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Настройки новостей")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func binding(for category: NewsCategory) -> Binding<Bool> {
        switch category {
        case .announcement:
            return $announcementNotifications
        case .learning:
            return $learningNotifications
        case .achievement:
            return $achievementNotifications
        case .event:
            return $eventNotifications
        case .department:
            return $departmentNotifications
        }
    }
}

struct TelegramFeedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TelegramFeedSettingsView(onDismiss: {})
    }
} 