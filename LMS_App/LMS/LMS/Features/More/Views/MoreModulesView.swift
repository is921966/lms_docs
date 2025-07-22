import SwiftUI

struct MoreModulesView: View {
    @StateObject private var featureRegistry = FeatureRegistryManager.shared
    @EnvironmentObject var authService: MockAuthService
    @State private var selectedModule: Feature?
    @State private var showingModule = false
    @State private var showingSettings = false
    @State private var showingCourses = false
    @State private var showingPendingUsers = false
    
    // Все функции для администратора в одном списке
    var allFunctions: [(title: String, subtitle: String, icon: String, color: Color, action: () -> Void, badge: Int?)] {
        var functions: [(title: String, subtitle: String, icon: String, color: Color, action: () -> Void, badge: Int?)] = []
        
        // 1. Настройки - всегда первые
        functions.append((
            title: "Настройки",
            subtitle: "Управление приложением и аккаунтом",
            icon: "gear",
            color: .blue,
            action: { showingSettings = true },
            badge: nil
        ))
        
        // 2. Оргструктура - сразу после настроек
        if Feature.orgStructure.isEnabled {
            functions.append((
                title: Feature.orgStructure.displayName,
                subtitle: Feature.orgStructure.description,
                icon: Feature.orgStructure.icon,
                color: Feature.orgStructure.color,
                action: {
                    selectedModule = .orgStructure
                    showingModule = true
                },
                badge: nil
            ))
        }
        
        // 3. Новости (Feed) - после оргструктуры
        if Feature.feed.isEnabled {
            functions.append((
                title: Feature.feed.displayName,
                subtitle: Feature.feed.description,
                icon: Feature.feed.icon,
                color: Feature.feed.color,
                action: {
                    selectedModule = .feed
                    showingModule = true
                },
                badge: nil
            ))
        }
        
        // Для администраторов добавляем админские функции
        if authService.currentUser?.role == .admin {
            // 4. Новые студенты
            functions.append((
                title: "Новые студенты",
                subtitle: "Одобрение новых пользователей",
                icon: "person.badge.plus",
                color: .orange,
                action: { showingPendingUsers = true },
                badge: 3  // Количество ожидающих
            ))
            
            // 5. Управление курсами
            functions.append((
                title: "Управление курсами",
                subtitle: "Создание и редактирование курсов",
                icon: "book.fill",
                color: .green,
                action: { showingCourses = true },
                badge: nil
            ))
            
            // 6. Cmi5 Контент - сразу после курсов
            if Feature.cmi5.isEnabled {
                functions.append((
                    title: Feature.cmi5.displayName,
                    subtitle: Feature.cmi5.description,
                    icon: Feature.cmi5.icon,
                    color: Feature.cmi5.color,
                    action: {
                        selectedModule = .cmi5
                        showingModule = true
                    },
                    badge: -1  // -1 означает "НОВОЕ"
                ))
            }
        }
        
        // Добавляем все остальные активные модули (исключая уже добавленные)
        let activeModules = Feature.allCases.filter { 
            $0.isEnabled && 
            $0 != .cmi5 && 
            $0 != .feed && 
            $0 != .settings &&  // Исключаем settings, так как он уже добавлен вручную
            $0 != .orgStructure  // Исключаем orgStructure, так как он уже добавлен вручную
        }
        for module in activeModules {
            // Для администраторов пропускаем модуль "Курсы", так как есть "Управление курсами"
            if authService.currentUser?.role == .admin && module == .courses {
                continue
            }
            
            // Также пропускаем courseManagement если уже добавили "Управление курсами" выше
            if authService.currentUser?.role == .admin && module == .courseManagement {
                continue
            }
            
            functions.append((
                title: module.displayName,
                subtitle: module.description,
                icon: module.icon,
                color: module.color,
                action: {
                    selectedModule = module
                    showingModule = true
                },
                badge: nil
            ))
        }
        
        return functions
    }
    
    // Будущие модули
    let futureModules: [(title: String, icon: String, color: Color)] = [
        (title: "Сертификаты", icon: "seal.fill", color: .purple),
        (title: "Геймификация", icon: "gamecontroller.fill", color: .orange),
        (title: "Уведомления", icon: "bell.fill", color: .red)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Все функции в едином списке
                VStack(spacing: 12) {
                    ForEach(Array(allFunctions.enumerated()), id: \.offset) { index, function in
                        FunctionCard(
                            title: function.title,
                            subtitle: function.subtitle,
                            icon: function.icon,
                            color: function.color,
                            badge: function.badge,
                            action: function.action
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Скоро будут доступны
                if !futureModules.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Скоро будут доступны")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        VStack(spacing: 12) {
                            ForEach(futureModules, id: \.title) { module in
                                FutureFunctionCard(
                                    title: module.title,
                                    icon: module.icon,
                                    color: module.color
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Информация для тестировщиков
                TestingInfoSection()
                    .padding(.top)
            }
            .padding(.bottom)
        }
        .navigationTitle("Ещё")
        .navigationDestination(isPresented: $showingModule) {
            if let module = selectedModule {
                module.view
            }
        }
        .navigationDestination(isPresented: $showingSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: $showingCourses) {
            CourseManagementView()
        }
        .navigationDestination(isPresented: $showingPendingUsers) {
            MockPendingUsersView()
        }
        // Обновляем при изменении feature flags
        .onReceive(featureRegistry.$lastUpdate) { _ in
            // Триггерим обновление UI
        }
    }
}

// MARK: - Function Card (единообразная карточка для всех функций)
struct FunctionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let badge: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Иконка
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 50)
                
                // Текст
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Badge или стрелка
                if let badge = badge {
                    if badge == -1 {
                        // Специальный badge "НОВОЕ"
                        Text("НОВОЕ")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(8)
                    } else {
                        // Числовой badge
                        Text("\(badge)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Future Function Card
struct FutureFunctionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            // Иконка
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color.opacity(0.5))
                .frame(width: 50)
            
            // Текст
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("В разработке")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
            
            Spacer()
            
            Text("Скоро")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(.gray.opacity(0.3))
        )
    }
}

// MARK: - Settings Card
struct SettingsCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "gear")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Настройки")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Управление приложением и аккаунтом")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Courses Card (для админов)
struct CoursesCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Управление курсами")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Создание и редактирование курсов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Testing Info Section
struct TestingInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Информация для тестировщиков")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                MoreInfoRow(icon: "1.circle.fill", text: "Все модули включены автоматически в TestFlight")
                MoreInfoRow(icon: "2.circle.fill", text: "Нажмите на модуль для перехода")
                MoreInfoRow(icon: "3.circle.fill", text: "Используйте Shake для обратной связи")
                MoreInfoRow(icon: "4.circle.fill", text: "Debug режим: Настройки → 7 тапов по версии")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MoreInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        MoreModulesView()
    }
} 