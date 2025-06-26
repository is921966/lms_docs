//
//  AdminSettingsView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct AdminSettingsView: View {
    @State private var selectedCategory = 0
    
    var body: some View {
        HStack(spacing: 0) {
            // Settings categories sidebar
            VStack(alignment: .leading, spacing: 0) {
                ForEach(SettingsCategory.allCases, id: \.self) { category in
                    SettingsCategoryRow(
                        category: category,
                        isSelected: selectedCategory == category.rawValue
                    ) {
                        selectedCategory = category.rawValue
                    }
                }
                
                Spacer()
            }
            .frame(width: 250)
            .background(Color(.systemGray6))
            
            // Settings content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch SettingsCategory(rawValue: selectedCategory) {
                    case .organization:
                        OrganizationSettingsView()
                    case .integrations:
                        IntegrationsSettingsView()
                    case .notifications:
                        NotificationSettingsView()
                    case .security:
                        SecuritySettingsView()
                    case .backup:
                        BackupSettingsView()
                    case .system:
                        SystemSettingsView()
                    default:
                        EmptyView()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Настройки системы")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Settings Category
enum SettingsCategory: Int, CaseIterable {
    case organization = 0
    case integrations = 1
    case notifications = 2
    case security = 3
    case backup = 4
    case system = 5
    
    var title: String {
        switch self {
        case .organization: return "Организация"
        case .integrations: return "Интеграции"
        case .notifications: return "Уведомления"
        case .security: return "Безопасность"
        case .backup: return "Резервное копирование"
        case .system: return "Система"
        }
    }
    
    var icon: String {
        switch self {
        case .organization: return "building.2"
        case .integrations: return "link"
        case .notifications: return "bell"
        case .security: return "lock.shield"
        case .backup: return "externaldrive"
        case .system: return "gearshape.2"
        }
    }
}

// MARK: - Settings Category Row
struct SettingsCategoryRow: View {
    let category: SettingsCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 24)
                
                Text(category.title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Organization Settings
struct OrganizationSettingsView: View {
    @State private var organizationName = "ЦУМ"
    @State private var organizationDomain = "tsum.ru"
    @State private var defaultLanguage = "Русский"
    @State private var timeZone = "Moscow (UTC+3)"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Настройки организации")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                SettingsField(
                    title: "Название организации",
                    value: $organizationName
                )
                
                SettingsField(
                    title: "Домен",
                    value: $organizationDomain
                )
                
                SettingsDropdown(
                    title: "Язык по умолчанию",
                    selection: $defaultLanguage,
                    options: ["Русский", "English"]
                )
                
                SettingsDropdown(
                    title: "Часовой пояс",
                    selection: $timeZone,
                    options: ["Moscow (UTC+3)", "London (UTC+0)", "New York (UTC-5)"]
                )
            }
            
            // Logo upload
            VStack(alignment: .leading, spacing: 12) {
                Text("Логотип организации")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Button("Загрузить логотип") {
                            // Upload logo
                        }
                        .buttonStyle(.bordered)
                        
                        Text("PNG, JPG до 5MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            Button("Сохранить изменения") {
                // Save settings
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Integrations Settings
struct IntegrationsSettingsView: View {
    @State private var ldapEnabled = true
    @State private var samlEnabled = false
    @State private var vkidEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Настройки интеграций")
                .font(.title2)
                .fontWeight(.bold)
            
            // LDAP Settings
            IntegrationCard(
                title: "Microsoft Active Directory (LDAP)",
                description: "Синхронизация пользователей с корпоративным каталогом",
                isEnabled: $ldapEnabled,
                icon: "person.2.circle",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsField(title: "LDAP сервер", value: .constant("ldap.tsum.local"))
                    SettingsField(title: "Base DN", value: .constant("dc=tsum,dc=local"))
                    SettingsField(title: "Bind DN", value: .constant("cn=admin,dc=tsum,dc=local"))
                    SettingsSecureField(title: "Bind пароль", value: .constant(""))
                }
            }
            
            // SAML Settings
            IntegrationCard(
                title: "SAML 2.0",
                description: "Единый вход через SAML провайдера",
                isEnabled: $samlEnabled,
                icon: "lock.shield",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsField(title: "Entity ID", value: .constant(""))
                    SettingsField(title: "SSO URL", value: .constant(""))
                    SettingsField(title: "SLO URL", value: .constant(""))
                }
            }
            
            // VK ID Settings
            IntegrationCard(
                title: "VK ID",
                description: "Авторизация через VK ID",
                isEnabled: $vkidEnabled,
                icon: "person.crop.circle.badge.checkmark",
                color: .indigo
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsField(title: "App ID", value: .constant("51234567"))
                    SettingsSecureField(title: "Secure Key", value: .constant(""))
                    SettingsField(title: "Redirect URI", value: .constant("vk51234567://vk.com"))
                }
            }
        }
    }
}

// MARK: - Notification Settings
struct NotificationSettingsView: View {
    @State private var emailEnabled = true
    @State private var pushEnabled = true
    @State private var smsEnabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Настройки уведомлений")
                .font(.title2)
                .fontWeight(.bold)
            
            // Email settings
            SettingsToggleSection(
                title: "Email уведомления",
                isEnabled: $emailEnabled
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsField(title: "SMTP сервер", value: .constant("smtp.tsum.ru"))
                    SettingsField(title: "Порт", value: .constant("587"))
                    SettingsField(title: "От кого", value: .constant("noreply@tsum.ru"))
                    SettingsToggle(title: "Использовать TLS", isOn: .constant(true))
                }
            }
            
            // Push settings
            SettingsToggleSection(
                title: "Push уведомления",
                isEnabled: $pushEnabled
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsField(title: "FCM Server Key", value: .constant(""))
                    SettingsToggle(title: "Отправлять на iOS", isOn: .constant(true))
                    SettingsToggle(title: "Отправлять на Android", isOn: .constant(true))
                }
            }
            
            // SMS settings
            SettingsToggleSection(
                title: "SMS уведомления",
                isEnabled: $smsEnabled
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsDropdown(
                        title: "SMS провайдер",
                        selection: .constant("SMS.ru"),
                        options: ["SMS.ru", "Twilio", "SMS Aero"]
                    )
                    SettingsField(title: "API ключ", value: .constant(""))
                }
            }
            
            // Notification templates
            VStack(alignment: .leading, spacing: 12) {
                Text("Шаблоны уведомлений")
                    .font(.headline)
                
                ForEach(["Регистрация", "Назначение курса", "Напоминание о тесте", "Выдача сертификата"], id: \.self) { template in
                    HStack {
                        Text(template)
                            .font(.subheadline)
                        Spacer()
                        Button("Редактировать") {
                            // Edit template
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Security Settings
struct SecuritySettingsView: View {
    @State private var requireStrongPassword = true
    @State private var sessionTimeout = "30"
    @State private var maxLoginAttempts = "5"
    @State private var enable2FA = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Настройки безопасности")
                .font(.title2)
                .fontWeight(.bold)
            
            // Password policy
            VStack(alignment: .leading, spacing: 16) {
                Text("Политика паролей")
                    .font(.headline)
                
                SettingsToggle(
                    title: "Требовать сложный пароль",
                    isOn: $requireStrongPassword
                )
                
                if requireStrongPassword {
                    VStack(alignment: .leading, spacing: 8) {
                        PasswordRequirement(text: "Минимум 8 символов")
                        PasswordRequirement(text: "Заглавные и строчные буквы")
                        PasswordRequirement(text: "Минимум одна цифра")
                        PasswordRequirement(text: "Минимум один специальный символ")
                    }
                    .padding(.leading, 32)
                }
            }
            
            // Session settings
            VStack(alignment: .leading, spacing: 16) {
                Text("Настройки сессий")
                    .font(.headline)
                
                SettingsField(
                    title: "Таймаут сессии (минуты)",
                    value: $sessionTimeout
                )
                
                SettingsField(
                    title: "Максимум попыток входа",
                    value: $maxLoginAttempts
                )
            }
            
            // 2FA settings
            VStack(alignment: .leading, spacing: 16) {
                Text("Двухфакторная аутентификация")
                    .font(.headline)
                
                SettingsToggle(
                    title: "Включить 2FA для администраторов",
                    isOn: $enable2FA
                )
            }
            
            // Audit log
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Журнал безопасности")
                        .font(.headline)
                    Spacer()
                    Button("Просмотреть журнал") {
                        // View security log
                    }
                    .buttonStyle(.bordered)
                }
                
                Text("Последние события безопасности")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Backup Settings
struct BackupSettingsView: View {
    @State private var autoBackupEnabled = true
    @State private var backupFrequency = "Ежедневно"
    @State private var backupTime = "02:00"
    @State private var retentionDays = "30"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Настройки резервного копирования")
                .font(.title2)
                .fontWeight(.bold)
            
            // Auto backup settings
            SettingsToggleSection(
                title: "Автоматическое резервное копирование",
                isEnabled: $autoBackupEnabled
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsDropdown(
                        title: "Частота",
                        selection: $backupFrequency,
                        options: ["Ежедневно", "Еженедельно", "Ежемесячно"]
                    )
                    
                    SettingsField(
                        title: "Время запуска",
                        value: $backupTime
                    )
                    
                    SettingsField(
                        title: "Хранить копии (дней)",
                        value: $retentionDays
                    )
                }
            }
            
            // Manual backup
            VStack(alignment: .leading, spacing: 12) {
                Text("Ручное резервное копирование")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Последняя копия: Сегодня, 02:00")
                            .font(.subheadline)
                        Text("Размер: 2.3 GB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Создать копию сейчас") {
                        // Create backup
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Backup history
            VStack(alignment: .leading, spacing: 12) {
                Text("История резервных копий")
                    .font(.headline)
                
                ForEach(0..<3) { index in
                    BackupHistoryRow(
                        date: Date().addingTimeInterval(-Double(index) * 86400),
                        size: "2.\(index + 1) GB",
                        status: index == 0 ? .success : .success
                    )
                }
            }
        }
    }
}

// MARK: - System Settings
struct SystemSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Системная информация")
                .font(.title2)
                .fontWeight(.bold)
            
            // System info
            VStack(alignment: .leading, spacing: 12) {
                SystemInfoRow(label: "Версия системы", value: "10.2.0")
                SystemInfoRow(label: "Версия API", value: "2.0")
                SystemInfoRow(label: "База данных", value: "PostgreSQL 14.2")
                SystemInfoRow(label: "Сервер", value: "Ubuntu 22.04 LTS")
                SystemInfoRow(label: "PHP версия", value: "8.1.12")
            }
            
            Divider()
            
            // System maintenance
            VStack(alignment: .leading, spacing: 16) {
                Text("Обслуживание системы")
                    .font(.headline)
                
                MaintenanceAction(
                    title: "Очистить кэш",
                    description: "Удалить временные файлы и кэш",
                    icon: "trash",
                    action: {}
                )
                
                MaintenanceAction(
                    title: "Оптимизировать базу данных",
                    description: "Выполнить оптимизацию таблиц",
                    icon: "cylinder",
                    action: {}
                )
                
                MaintenanceAction(
                    title: "Проверить обновления",
                    description: "Проверить наличие новых версий",
                    icon: "arrow.down.circle",
                    action: {}
                )
            }
            
            Divider()
            
            // System logs
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Системные логи")
                        .font(.headline)
                    Spacer()
                    Button("Скачать логи") {
                        // Download logs
                    }
                    .buttonStyle(.bordered)
                }
                
                Text("Логи за последние 7 дней")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Helper Views
struct SettingsField: View {
    let title: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField(title, text: $value)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct SettingsSecureField: View {
    let title: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            SecureField(title, text: $value)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct SettingsDropdown: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
}

struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(title, isOn: $isOn)
    }
}

struct SettingsToggleSection<Content: View>: View {
    let title: String
    @Binding var isEnabled: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(title, isOn: $isEnabled)
                .font(.headline)
            
            if isEnabled {
                content()
                    .padding(.leading, 32)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct IntegrationCard<Content: View>: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
            }
            
            if isEnabled {
                Divider()
                content()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PasswordRequirement: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct BackupHistoryRow: View {
    let date: Date
    let size: String
    let status: BackupStatus
    
    enum BackupStatus {
        case success, failed, inProgress
        
        var color: Color {
            switch self {
            case .success: return .green
            case .failed: return .red
            case .inProgress: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .failed: return "xmark.circle.fill"
            case .inProgress: return "arrow.triangle.2.circlepath"
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .foregroundColor(status.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Text(size)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Восстановить") {
                // Restore backup
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SystemInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

struct MaintenanceAction: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        AdminSettingsView()
    }
} 