import SwiftUI

// MARK: - Feed View

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { _ in
                        FeedCard()
                    }
                }
                .padding()
            }
            .navigationTitle("Лента")
        }
    }
}

struct FeedCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Новость компании")
                .font(.headline)
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("2 часа назад")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    
    private let feedService: FeedServiceProtocol
    
    init(feedService: FeedServiceProtocol) {
        self.feedService = feedService
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Иван Иванов")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Менеджер по продажам")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Статистика") {
                    HStack {
                        Label("Пройдено курсов", systemImage: "checkmark.circle.fill")
                        Spacer()
                        Text("12")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Часов обучения", systemImage: "clock.fill")
                        Spacer()
                        Text("48")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Сертификатов", systemImage: "doc.fill")
                        Spacer()
                        Text("8")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        coordinator.logout()
                    }) {
                        Text("Выйти")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Профиль")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.showSettings()
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

struct ProfileViewModel: ObservableObject {
    @Published var user: User?
    
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(userService: UserServiceProtocol, authService: AuthServiceProtocol) {
        self.userService = userService
        self.authService = authService
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        List {
            Section("Настройки приложения") {
                Toggle("Push-уведомления", isOn: .constant(true))
                Toggle("Биометрия", isOn: .constant(false))
            }
            
            Section("О приложении") {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text("3.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private let storage: UserDefaultsStorageProtocol
    
    init(userService: UserServiceProtocol, authService: AuthServiceProtocol, storage: UserDefaultsStorageProtocol) {
        self.userService = userService
        self.authService = authService
        self.storage = storage
    }
}

// MARK: - More Menu View

struct MoreMenuView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: NotificationsView()) {
                        Label("Уведомления", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: CourseManagementView()) {
                        Label("Управление курсами", systemImage: "slider.horizontal.3")
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        Label("Обратная связь", systemImage: "envelope")
                    }
                }
                
                Section {
                    NavigationLink(destination: Text("Помощь")) {
                        Label("Помощь", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: Text("О приложении")) {
                        Label("О приложении", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Ещё")
        }
    }
}

// MARK: - Other Views

struct CourseDetailView: View {
    let course: Course
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Course image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(course.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(course.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(course.duration) мин", systemImage: "clock")
                        Label(course.level.displayName, systemImage: "chart.bar")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CourseManagementView: View {
    var body: some View {
        Text("Управление курсами")
            .navigationTitle("Управление курсами")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationsView: View {
    var body: some View {
        Text("Уведомления")
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeedbackView: View {
    var body: some View {
        Text("Обратная связь")
            .navigationTitle("Обратная связь")
            .navigationBarTitleDisplayMode(.inline)
    }
} 