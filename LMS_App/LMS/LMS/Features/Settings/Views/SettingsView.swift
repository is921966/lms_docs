import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: MockAuthService
    @AppStorage("isAdminMode") private var isAdminMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("autoPlayVideos") private var autoPlayVideos = true

    var isAdmin: Bool {
        authService.currentUser?.roles.contains("admin") == true
    }

    var body: some View {
        NavigationStack {
            List {
                // User info section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.fullName ?? "Пользователь")
                                .font(.headline)
                            Text(authService.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if isAdmin {
                                Label("Администратор", systemImage: "crown.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // Admin settings (only for admins)
                if isAdmin {
                    Section("Режим администратора") {
                        Toggle(isOn: $isAdminMode) {
                            Label("Админский режим", systemImage: "crown")
                        }
                        .tint(.orange)

                        NavigationLink(destination: FeatureToggleSettings()) {
                            Label("Управление модулями", systemImage: "flag.2.crossed")
                        }

                        NavigationLink(destination: AdminDashboardView()) {
                            Label("Админ панель", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    }
                }

                // App settings
                Section("Настройки приложения") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Уведомления", systemImage: "bell")
                    }

                    Toggle(isOn: $darkModeEnabled) {
                        Label("Тёмная тема", systemImage: "moon")
                    }

                    Toggle(isOn: $autoPlayVideos) {
                        Label("Автовоспроизведение видео", systemImage: "play.circle")
                    }
                }

                // Learning settings
                Section("Обучение") {
                    NavigationLink(destination: Text("Настройки обучения")) {
                        Label("Предпочтения обучения", systemImage: "brain")
                    }

                    NavigationLink(destination: Text("История обучения")) {
                        Label("История просмотров", systemImage: "clock")
                    }

                    NavigationLink(destination: Text("Загрузки")) {
                        Label("Загруженные материалы", systemImage: "arrow.down.circle")
                    }
                }

                // Support section
                Section("Поддержка") {
                    NavigationLink(destination: FeedbackFeedView()) {
                        Label("Лента отзывов", systemImage: "message.badge.filled.fill")
                    }

                    NavigationLink(destination: FeedbackView()) {
                        Label("Отправить отзыв", systemImage: "exclamationmark.bubble")
                    }

                    NavigationLink(destination: Text("FAQ")) {
                        Label("Часто задаваемые вопросы", systemImage: "questionmark.circle")
                    }

                    NavigationLink(destination: Text("О приложении")) {
                        Label("О приложении", systemImage: "info.circle")
                    }
                }

                // Logout section
                Section {
                    Button(action: {
                        authService.logout()
                    }) {
                        HStack {
                            Spacer()
                            Label("Выйти из аккаунта", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }

                // Version info
                Section {
                    HStack {
                        Text("Версия приложения")
                        Spacer()
                        Text("2.0.1 (Build 52)")
                            .foregroundColor(.secondary)
                    }

                    if isAdminMode {
                        HStack {
                            Text("Device ID")
                            Spacer()
                            Text(UIDevice.current.identifierForVendor?.uuidString ?? "Unknown")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}

// Quick settings for profile view
struct QuickSettingsSection: View {
    @AppStorage("isAdminMode") private var isAdminMode = false
    @EnvironmentObject var authService: MockAuthService

    var isAdmin: Bool {
        authService.currentUser?.roles.contains("admin") == true
    }

    var body: some View {
        VStack(spacing: 12) {
            // Settings link
            NavigationLink(destination: SettingsView()) {
                HStack {
                    Image(systemName: "gear")
                        .font(.body)
                    Text("Настройки")
                        .font(.body)
                    Spacer()

                    if isAdmin && isAdminMode {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.primary)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            }

            // Admin quick toggle (if admin)
            if isAdmin {
                Button(action: {
                    isAdminMode.toggle()
                }) {
                    HStack {
                        Image(systemName: isAdminMode ? "crown.fill" : "crown")
                            .font(.body)
                            .foregroundColor(isAdminMode ? .orange : .primary)
                        Text(isAdminMode ? "Админ режим включен" : "Включить админ режим")
                            .font(.body)
                        Spacer()
                        Toggle("", isOn: $isAdminMode)
                            .labelsHidden()
                            .tint(.orange)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(MockAuthService.shared)
    }
}
