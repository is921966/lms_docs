import SwiftUI

/// Менеджер для реактивного управления Feature Registry
class FeatureRegistryManager: ObservableObject {
    static let shared = FeatureRegistryManager()

    @Published var lastUpdate = Date()

    private init() {}

    /// Обновить UI после изменения feature flags
    func refresh() {
        DispatchQueue.main.async {
            self.lastUpdate = Date()
        }
    }

    /// Включить готовые модули с обновлением UI
    func enableReadyModules() {
        Feature.enableReadyModules()
        refresh()
        print("🔄 FeatureRegistry обновлен - UI получит уведомление")
    }
}

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
            LoginView()
        case .users:
            AdminManagementView()
        case .courses:
            CourseListView()
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        case .tests:
            TestListView()
        case .analytics:
            AnalyticsDashboard()
        case .onboarding:
            MyOnboardingProgramsView()
        case .competencies:
            // Wrapper view для CompetencyListView чтобы передать environment object
            CompetencyListWrapper()
        case .positions:
            // Wrapper view для PositionListView чтобы передать environment object
            PositionListWrapper()
        case .feed:
            // Wrapper view для FeedView чтобы передать environment object
            FeedWrapper()
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

// MARK: - Wrapper Views для модулей, требующих @EnvironmentObject

/// Wrapper для CompetencyListView
struct CompetencyListWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        CompetencyListView()
            .environmentObject(authViewModel)
    }
}

/// Wrapper для PositionListView  
struct PositionListWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        PositionListView()
            .environmentObject(authViewModel)
    }
}

/// Wrapper для FeedView
struct FeedWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        FeedView()
            .environmentObject(authViewModel)
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

    /// Включить все готовые модули
    static func enableReadyModules() {
        // Включаем модули, которые готовы но не интегрированы
        Feature.enable(.competencies)
        Feature.enable(.positions)
        Feature.enable(.feed)

        print("✅ Готовые модули включены:")
        print("  - Компетенции")
        print("  - Должности")
        print("  - Новости")

        // КРИТИЧЕСКИ ВАЖНО: Уведомляем UI об изменениях
        FeatureRegistryManager.shared.refresh()
        print("🔄 UI уведомлен об изменениях Feature Registry")
    }

    /// Выключить все дополнительные модули
    static func disableExtraModules() {
        Feature.disable(.competencies)
        Feature.disable(.positions)
        Feature.disable(.feed)
        Feature.disable(.certificates)
        Feature.disable(.gamification)
        Feature.disable(.notifications)

        print("❌ Дополнительные модули выключены")
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
