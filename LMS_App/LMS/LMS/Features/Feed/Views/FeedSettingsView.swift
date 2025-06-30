import SwiftUI

struct FeedSettingsView: View {
    @State private var studentCanPost = false
    @State private var studentCanComment = true
    @State private var studentCanLike = true
    @State private var studentCanShare = true
    @State private var requireModeration = false
    @State private var autoModerateContent = true
    @State private var showingPermissionsSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Настройки ленты новостей")
                .font(.title2)
                .fontWeight(.bold)

            // Quick permissions
            VStack(alignment: .leading, spacing: 16) {
                Text("Права студентов")
                    .font(.headline)

                VStack(spacing: 12) {
                    PermissionToggle(
                        title: "Создавать записи",
                        description: "Студенты смогут публиковать свои записи в ленте",
                        isOn: $studentCanPost,
                        icon: "square.and.pencil"
                    )

                    PermissionToggle(
                        title: "Комментировать",
                        description: "Студенты смогут оставлять комментарии к записям",
                        isOn: $studentCanComment,
                        icon: "bubble.left"
                    )

                    PermissionToggle(
                        title: "Ставить лайки",
                        description: "Студенты смогут отмечать понравившиеся записи",
                        isOn: $studentCanLike,
                        icon: "hand.thumbsup"
                    )

                    PermissionToggle(
                        title: "Делиться записями",
                        description: "Студенты смогут делиться записями с другими",
                        isOn: $studentCanShare,
                        icon: "square.and.arrow.up"
                    )
                }

                Button("Расширенные настройки прав") {
                    showingPermissionsSheet = true
                }
                .buttonStyle(.bordered)
            }

            Divider()

            // Moderation settings
            VStack(alignment: .leading, spacing: 16) {
                Text("Модерация контента")
                    .font(.headline)

                PermissionToggle(
                    title: "Премодерация записей студентов",
                    description: "Записи студентов будут проверяться перед публикацией",
                    isOn: $requireModeration,
                    icon: "shield.lefthalf.filled"
                )

                PermissionToggle(
                    title: "Автоматическая фильтрация",
                    description: "Блокировать нежелательный контент автоматически",
                    isOn: $autoModerateContent,
                    icon: "text.magnifyingglass"
                )

                if requireModeration {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Модераторы")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("Администраторы автоматически являются модераторами")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button("Управление модераторами") {
                            // Show moderators management
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }

            Divider()

            // Feed statistics
            VStack(alignment: .leading, spacing: 12) {
                Text("Статистика ленты")
                    .font(.headline)

                HStack(spacing: 16) {
                    FeedStatCard(title: "Записей", value: "156", icon: "doc.text", color: .blue)
                    FeedStatCard(title: "Комментариев", value: "423", icon: "bubble.left", color: .green)
                    FeedStatCard(title: "Активных авторов", value: "34", icon: "person.2", color: .orange)
                    FeedStatCard(title: "Лайков", value: "1.2K", icon: "hand.thumbsup", color: .red)
                }
            }

            Divider()

            // Save button
            Button("Сохранить изменения") {
                saveSettings()
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showingPermissionsSheet) {
            FeedPermissionsView()
        }
    }

    private func saveSettings() {
        // Save settings to server
        // Update FeedService permissions
    }
}

// MARK: - Permission Toggle
struct PermissionToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Toggle(isOn: $isOn) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Feed Stat Card
struct FeedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    FeedSettingsView()
        .padding()
}
