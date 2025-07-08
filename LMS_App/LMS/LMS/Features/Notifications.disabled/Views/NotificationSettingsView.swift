//
//  NotificationSettingsView.swift
//  LMS
//
//  Created on Sprint 41 Day 2 - Notification Settings View
//

import SwiftUI
import UserNotifications

/// View для настроек уведомлений
struct NotificationSettingsView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = NotificationSettingsViewModel(
        repository: MockNotificationRepository()
    )
    @Environment(\.dismiss) private var dismiss
    @State private var showingQuietHoursSetup = false
    @State private var showingResetAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // Master toggle
                masterToggleSection
                
                // Notification types
                if viewModel.preferences.isEnabled {
                    notificationTypesSection
                    
                    // Quiet hours
                    quietHoursSection
                    
                    // Frequency limits
                    frequencySection
                }
                
                // Push notifications
                pushNotificationsSection
            }
            .navigationTitle("Настройки уведомлений")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveSettings()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingQuietHoursSetup) {
                QuietHoursSetupView(quietHours: $viewModel.preferences.quietHours)
            }
            .onAppear {
                viewModel.loadPreferences()
            }
        }
    }
    
    // MARK: - Sections
    
    private var masterToggleSection: some View {
        Section {
            Toggle(isOn: $viewModel.preferences.isEnabled) {
                Label("Получать уведомления", systemImage: "bell")
            }
        } footer: {
            Text("Отключение уведомлений остановит все оповещения")
        }
    }
    
    private var notificationTypesSection: some View {
        Section {
            ForEach(NotificationType.allCases, id: \.self) { type in
                NotificationTypeRow(
                    type: type,
                    channels: binding(for: type)
                )
            }
        } header: {
            Text("Типы уведомлений")
        } footer: {
            Text("Выберите способы получения для каждого типа уведомлений")
        }
    }
    
    private var quietHoursSection: some View {
        Section {
            Toggle(isOn: quietHoursEnabled) {
                Label("Тихие часы", systemImage: "moon")
            }
            
            if viewModel.preferences.quietHours?.isEnabled == true {
                Button {
                    showingQuietHoursSetup = true
                } label: {
                    HStack {
                        Text("Настроить время")
                        Spacer()
                        if let quietHours = viewModel.preferences.quietHours {
                            Text(quietHoursTimeRange(quietHours))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Toggle(isOn: allowUrgentBinding) {
                    Text("Разрешить срочные")
                        .font(.subheadline)
                }
            }
        } header: {
            Text("Тихие часы")
        } footer: {
            Text("В тихие часы вы не будете получать push-уведомления")
        }
    }
    
    private var frequencySection: some View {
        Section {
            ForEach(FrequencyLimitType.allCases, id: \.self) { limitType in
                HStack {
                    Text(limitType.title)
                    Spacer()
                    Menu {
                        ForEach(limitType.options, id: \.self) { option in
                            Button {
                                updateFrequencyLimit(limitType, value: option)
                            } label: {
                                Text(formatFrequencyOption(option, type: limitType))
                            }
                        }
                    } label: {
                        HStack {
                            Text(currentFrequencyText(for: limitType))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text("Ограничение частоты")
        } footer: {
            Text("Ограничьте количество уведомлений за период времени")
        }
    }
    
    private var pushNotificationsSection: some View {
        Section {
            HStack {
                Label("Push уведомления", systemImage: "bell.badge.fill")
                Spacer()
                if viewModel.pushNotificationStatus == UNAuthorizationStatus.notDetermined {
                    Button("Включить") {
                        viewModel.requestPushPermission()
                    }
                } else {
                    Text(pushStatusText)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.pushNotificationStatus == .denied {
                Button {
                    openSettings()
                } label: {
                    Label("Открыть настройки", systemImage: "gear")
                }
            }
        } header: {
            Text("Push-уведомления")
        } footer: {
            if viewModel.pushNotificationStatus == .denied {
                Text("Включите push-уведомления в настройках устройства")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var pushStatusText: String {
        switch viewModel.pushNotificationStatus {
        case .authorized:
            return "Включены"
        case .denied:
            return "Отключены"
        case .provisional:
            return "Временные"
        case .ephemeral:
            return "Эфемерные"
        case .notDetermined:
            return "Не определено"
        @unknown default:
            return "Неизвестно"
        }
    }
    
    private func binding(for type: NotificationType) -> Binding<Set<NotificationChannel>> {
        Binding(
            get: {
                viewModel.preferences.channelPreferences[type] ?? []
            },
            set: { newValue in
                viewModel.preferences.channelPreferences[type] = newValue
            }
        )
    }
    
    private var quietHoursEnabled: Binding<Bool> {
        Binding(
            get: {
                viewModel.preferences.quietHours?.isEnabled ?? false
            },
            set: { enabled in
                if viewModel.preferences.quietHours == nil {
                    viewModel.preferences.quietHours = QuietHours()
                }
                viewModel.preferences.quietHours?.isEnabled = enabled
            }
        )
    }
    
    private var allowUrgentBinding: Binding<Bool> {
        Binding(
            get: {
                viewModel.preferences.quietHours?.allowUrgent ?? true
            },
            set: { value in
                viewModel.preferences.quietHours?.allowUrgent = value
            }
        )
    }
    
    private func quietHoursTimeRange(_ quietHours: QuietHours) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let startTime = calendar.date(from: quietHours.startTime),
              let endTime = calendar.date(from: quietHours.endTime) else {
            return "Не настроено"
        }
        
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    private func updateFrequencyLimit(_ type: FrequencyLimitType, value: Int?) {
        // Update the appropriate frequency limit
        // This would be implemented based on your needs
    }
    
    private func currentFrequencyText(for type: FrequencyLimitType) -> String {
        // Return current limit text
        return "Без ограничений"
    }
    
    private func formatFrequencyOption(_ option: Int?, type: FrequencyLimitType) -> String {
        guard let option = option else {
            return "Без ограничений"
        }
        return "\(option) в \(type.unit)"
    }
    
    private func saveSettings() {
        Task {
            await viewModel.savePreferences()
            dismiss()
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Notification Type Row

struct NotificationTypeRow: View {
    let type: NotificationType
    @Binding var channels: Set<NotificationChannel>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: type.icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack(spacing: 12) {
                ForEach(NotificationChannel.allCases, id: \.self) { channel in
                    ChannelToggle(
                        channel: channel,
                        isSelected: channels.contains(channel),
                        action: {
                            if channels.contains(channel) {
                                channels.remove(channel)
                            } else {
                                channels.insert(channel)
                            }
                        }
                    )
                }
            }
            .padding(.leading, 32)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Channel Toggle

struct ChannelToggle: View {
    let channel: NotificationChannel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(channel.displayName)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
        }
    }
    
    private var iconName: String {
        switch channel {
        case .push:
            return "app.badge"
        case .email:
            return "envelope"
        case .inApp:
            return "bell"
        case .sms:
            return "message"
        }
    }
}

// MARK: - Frequency Limit Type

enum FrequencyLimitType: String, CaseIterable {
    case hourly = "hourly"
    case daily = "daily"
    case weekly = "weekly"
    
    var title: String {
        switch self {
        case .hourly: return "В час"
        case .daily: return "В день"
        case .weekly: return "В неделю"
        }
    }
    
    var unit: String {
        switch self {
        case .hourly: return "час"
        case .daily: return "день"
        case .weekly: return "неделю"
        }
    }
    
    var options: [Int?] {
        switch self {
        case .hourly:
            return [nil, 1, 3, 5, 10]
        case .daily:
            return [nil, 5, 10, 20, 50]
        case .weekly:
            return [nil, 20, 50, 100, 200]
        }
    }
}

// MARK: - Quiet Hours Setup View

struct QuietHoursSetupView: View {
    @Binding var quietHours: QuietHours?
    @Environment(\.dismiss) private var dismiss
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Начало", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Конец", selection: $endTime, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Время тихих часов")
                }
            }
            .navigationTitle("Тихие часы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        saveQuietHours()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentTimes()
            }
        }
    }
    
    private func loadCurrentTimes() {
        let calendar = Calendar.current
        let now = Date()
        
        if let quietHours = quietHours,
           let start = calendar.date(from: quietHours.startTime),
           let end = calendar.date(from: quietHours.endTime) {
            startTime = start
            endTime = end
        } else {
            // Default: 22:00 - 08:00
            startTime = calendar.date(from: DateComponents(hour: 22, minute: 0)) ?? now
            endTime = calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? now
        }
    }
    
    private func saveQuietHours() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        if quietHours == nil {
            quietHours = QuietHours()
        }
        
        quietHours?.startTime = startComponents
        quietHours?.endTime = endComponents
    }
}

// MARK: - Preview

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
} 