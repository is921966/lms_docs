//
//  ContentView.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    // TEMPORARY: Use mock service for TestFlight testing
    // TODO: Change back to VKIDAuthService when VK ID is fully integrated
    @StateObject private var authService = MockAuthService.shared
    
    @State private var showingLogin = false
    
    var body: some View {
        NavigationView {
            if authService.isAuthenticated {
                if authService.isApprovedByAdmin {
                    // Пользователь авторизован и одобрен - показываем основное приложение
                    MainTabView()
                } else {
                    // Пользователь авторизован, но ожидает одобрения
                    MockPendingApprovalView()
                }
            } else {
                // Пользователь не авторизован
                VStack(spacing: 20) {
                    Spacer()
                    
                    // App icon
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    // App title
                    Text("TSUM LMS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Корпоративный университет")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Login button
                    Button(action: {
                        showingLogin = true
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                            Text("Войти (Demo)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color(red: 0/255, green: 119/255, blue: 255/255))
                        .cornerRadius(10)
                    }
                    
                    // Info text
                    VStack(spacing: 5) {
                        Text("Демо версия")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                        
                        Text("VK ID будет доступен позже")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // Version info
                    Text("Version 2.0.1 - TestFlight Demo")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
                .padding()
                .sheet(isPresented: $showingLogin) {
                    MockLoginView()
                }
            }
        }
        .onAppear {
            // Проверяем статус одобрения при запуске
            if authService.isAuthenticated {
                // Mock service doesn't need to check approval
            }
        }
    }
}

// MARK: - Mock Pending Approval View
struct MockPendingApprovalView: View {
    @StateObject private var authService = MockAuthService.shared
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            // Title
            Text("Ожидание одобрения")
                .font(.title)
                .fontWeight(.bold)
            
            // User info
            if let user = authService.currentUser {
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.headline)
                    
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            
            // Description
            VStack(spacing: 10) {
                Text("Ваша учетная запись создана")
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Text("Администратор должен одобрить вашу заявку для доступа к курсам")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Mock approve button (for development)
            Button(action: {
                authService.mockApprove()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Одобрить себя (Dev)")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Logout button
            Button(action: {
                authService.logout()
            }) {
                Text("Выйти")
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        TabView {
            // Main screen
            NavigationStack {
                MainDashboardView()
            }
            .tabItem {
                Label("Главная", systemImage: "house")
            }
            
            // Learning
            NavigationStack {
                CourseListView()
            }
            .tabItem {
                Label("Обучение", systemImage: "book")
            }
            
            // Competencies
            NavigationStack {
                CompetencyListView()
            }
            .tabItem {
                Label("Компетенции", systemImage: "star")
            }
            
            // Tests
            NavigationStack {
                TestListView()
            }
            .tabItem {
                Label("Тесты", systemImage: "doc.text.magnifyingglass")
            }
            
            // Onboarding
            NavigationStack {
                OnboardingDashboard()
            }
            .tabItem {
                Label("Онбординг", systemImage: "person.badge.clock")
            }
            
            // Analytics
            NavigationStack {
                AnalyticsDashboard()
            }
            .tabItem {
                Label("Аналитика", systemImage: "chart.bar.fill")
            }
            
            // Profile
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Профиль", systemImage: "person.circle")
            }
        }
        .environmentObject(authViewModel)
    }
}

// MARK: - Main Dashboard View
struct MainDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Добро пожаловать!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let userName = authViewModel.currentUser?.firstName {
                        Text("Привет, \(userName)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Quick stats
                HStack(spacing: 16) {
                    DashboardCard(
                        title: "Курсов",
                        value: "12",
                        icon: "book.fill",
                        color: .blue
                    )
                    
                    DashboardCard(
                        title: "Компетенций",
                        value: "8",
                        icon: "star.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Recent activities
                VStack(alignment: .leading, spacing: 16) {
                    Text("Последняя активность")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ActivityRow(
                            title: "Завершен курс iOS разработка",
                            time: "2 часа назад",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        ActivityRow(
                            title: "Новая компетенция: SwiftUI",
                            time: "Вчера",
                            icon: "star.fill",
                            color: .orange
                        )
                        
                        ActivityRow(
                            title: "Начат курс по архитектуре",
                            time: "3 дня назад",
                            icon: "play.circle.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.vertical)
        }
        .navigationTitle("Главная")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
