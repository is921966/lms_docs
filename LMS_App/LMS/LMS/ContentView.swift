//
//  ContentView.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: MockAuthService
    @StateObject private var featureRegistry = FeatureRegistryManager.shared
    @State private var selectedTab = 0
    @AppStorage("isAdminMode") private var isAdminMode = false
    
    // Проверяем запущены ли мы в режиме UI тестирования
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI-Testing")
    }
    
    var body: some View {
        if authService.isAuthenticated {
            authenticatedView
        } else {
            LoginView()
        }
    }
    
    var authenticatedView: some View {
        TabView(selection: $selectedTab) {
            // Автоматическая генерация табов из FeatureRegistry
            // КРИТИЧЕСКИ ВАЖНО: Зависимость на featureRegistry.lastUpdate для TDD
            ForEach(Array(Feature.enabledTabFeatures.enumerated()), id: \.element) { index, feature in
                NavigationStack {
                    feature.view
                }
                .tabItem {
                    Label(feature.rawValue, systemImage: feature.icon)
                }
                .tag(index)
            }
            .id(featureRegistry.lastUpdate) // КРИТИЧЕСКОЕ для обновления UI!
            
            // Profile + Settings combined tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Профиль", systemImage: "person.fill")
            }
            .tag(Feature.enabledTabFeatures.count)
            
            // Debug menu для разработки и тестирования
            // Всегда показываем в симуляторе (для разработки и UI тестов)
            #if targetEnvironment(simulator)
            NavigationStack {
                DebugMenuView()
            }
            .tabItem {
                Label("Debug", systemImage: "wrench.fill")
            }
            .tag(Feature.enabledTabFeatures.count + 1)
            #endif
        }
        .accentColor(.blue)
        // Добавляем индикатор админского режима
        .overlay(alignment: .topTrailing) {
            if isAdminMode {
                AdminModeIndicator()
                    .padding()
            }
        }
    }
}

// Индикатор админского режима
struct AdminModeIndicator: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.caption)
            Text("ADMIN")
                .font(.caption2.bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.red)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Debug меню теперь не обернуто в #if DEBUG
struct DebugMenuView: View {
    @AppStorage("isAdminMode") private var isAdminMode = false
    
    var body: some View {
        List {
            Section("Admin Tools") {
                Toggle("Admin Mode", isOn: $isAdminMode)
                    .tint(.red)
                
                NavigationLink(destination: FeatureToggleSettings()) {
                    Label("Feature Flags", systemImage: "flag.2.crossed")
                }
            }
            
            Section("Feedback System") {
                NavigationLink(destination: FeedbackDebugMenu()) {
                    Label("Feedback Debug", systemImage: "exclamationmark.bubble")
                }
            }
            
            Section("Quick Actions") {
                // Быстрое включение всех готовых модулей
                Button("Enable All Ready Modules") {
                    enableReadyModules()
                }
                .foregroundColor(.blue)
                
                Button("Disable Extra Modules") {
                    disableExtraModules()
                }
                .foregroundColor(.orange)
            }
            
            Section("Data") {
                Button("Clear All Cache") {
                    clearCache()
                }
                .foregroundColor(.red)
                
                Button("Reset User Data") {
                    resetUserData()
                }
                .foregroundColor(.red)
            }
            
            Section("Module Status") {
                ForEach(Feature.allCases, id: \.self) { feature in
                    HStack {
                        Label(feature.rawValue, systemImage: feature.icon)
                        Spacer()
                        if feature.isEnabled {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Debug Menu")
    }
    
    private func enableReadyModules() {
        // Включаем готовые модули
        Feature.enable(.competencies)
        Feature.enable(.positions)
        Feature.enable(.feed)
    }
    
    private func disableExtraModules() {
        // Выключаем дополнительные модули
        Feature.disable(.competencies)
        Feature.disable(.positions)
        Feature.disable(.feed)
        Feature.disable(.certificates)
        Feature.disable(.gamification)
        Feature.disable(.notifications)
    }
    
    private func clearCache() {
        // Clear cache implementation
        print("Cache cleared")
    }
    
    private func resetUserData() {
        // Reset user data implementation
        print("User data reset")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MockAuthService.shared)
    }
}
