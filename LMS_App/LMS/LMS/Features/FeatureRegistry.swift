import SwiftUI

/// Единый реестр всех модулей приложения
enum Feature: String, CaseIterable {
    // Основные модули (включены по умолчанию)
    case auth = "Авторизация"
    case users = "Пользователи"
    case courses = "Курсы"
    case profile = "Профиль"
    case settings = "Настройки"
    case tests = "Тесты"
    case analytics = "Аналитика"
    case onboarding = "Онбординг"
    
    // Готовые но не интегрированные модули
    case competencies = "Компетенции"
    case positions = "Должности"
    case feed = "Новости"
    
    // Будущие модули
    case certificates = "Сертификаты"
    case gamification = "Геймификация"
    case notifications = "Уведомления"
    
    /// Проверка, включен ли модуль
    var isEnabled: Bool {
        switch self {
        // Основные модули всегда включены
        case .auth, .users, .courses, .profile, .settings, .tests, .analytics:
            return true
            
        // Онбординг включен по умолчанию
        case .onboarding:
            return true
            
        // Feature flags для остальных модулей
        default:
            return UserDefaults.standard.bool(forKey: "feature_\(self.rawValue)")
        }
    }
    
    /// Иконка для табов
    var icon: String {
        switch self {
        case .auth: return "person.circle"
        case .users: return "person.2"
        case .courses: return "book"
        case .profile: return "person"
        case .settings: return "gear"
        case .tests: return "checkmark.circle"
        case .analytics: return "chart.bar"
        case .onboarding: return "star"
        case .competencies: return "lightbulb"
        case .positions: return "briefcase"
        case .feed: return "newspaper"
        case .certificates: return "rosette"
        case .gamification: return "gamecontroller"
        case .notifications: return "bell"
        }
    }
    
    /// View для каждого модуля
    @ViewBuilder
    var view: some View {
        switch self {
        case .auth:
            AuthenticationView()
        case .users:
            UserManagementView()
        case .courses:
            CoursesListView()
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        case .tests:
            TestsListView()
        case .analytics:
            AnalyticsView()
        case .onboarding:
            OnboardingProgramsView()
        case .competencies:
            CompetencyListView()
        case .positions:
            PositionListView()
        case .feed:
            FeedView()
        case .certificates:
            PlaceholderView(title: "Сертификаты", icon: "rosette")
        case .gamification:
            PlaceholderView(title: "Геймификация", icon: "gamecontroller")
        case .notifications:
            PlaceholderView(title: "Уведомления", icon: "bell")
        }
    }
    
    /// Проверка, должен ли модуль показываться в табах
    var shouldShowInTabs: Bool {
        switch self {
        case .auth:
            // Авторизация не показывается в табах
            return false
        case .profile, .settings:
            // Профиль и настройки объединены в один таб
            return false
        default:
            return isEnabled
        }
    }
}

/// Заглушка для будущих модулей
struct PlaceholderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundColor(.secondary)
                
                Text("Модуль в разработке")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Эта функциональность будет доступна в следующих версиях")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 50)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

/// Расширение для управления feature flags
extension Feature {
    /// Включить модуль
    static func enable(_ feature: Feature) {
        UserDefaults.standard.set(true, forKey: "feature_\(feature.rawValue)")
    }
    
    /// Выключить модуль
    static func disable(_ feature: Feature) {
        UserDefaults.standard.set(false, forKey: "feature_\(feature.rawValue)")
    }
    
    /// Переключить состояние модуля
    func toggle() {
        if isEnabled {
            Feature.disable(self)
        } else {
            Feature.enable(self)
        }
    }
    
    /// Получить список включенных модулей для табов
    static var enabledTabFeatures: [Feature] {
        allCases.filter { $0.shouldShowInTabs }
    }
}

/// Настройки для админов
struct FeatureToggleSettings: View {
    @State private var features = Feature.allCases
    
    var body: some View {
        List {
            Section("Управление модулями") {
                ForEach(features, id: \.self) { feature in
                    if feature != .auth {
                        Toggle(isOn: Binding(
                            get: { feature.isEnabled },
                            set: { _ in feature.toggle() }
                        )) {
                            Label(feature.rawValue, systemImage: feature.icon)
                        }
                        .disabled(feature.shouldShowInTabs && feature.isEnabled)
                    }
                }
            }
            .listRowBackground(Color(.systemGray6))
        }
        .navigationTitle("Feature Flags")
        .navigationBarTitleDisplayMode(.inline)
    }
} 