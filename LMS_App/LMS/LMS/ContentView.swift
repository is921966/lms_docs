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
    var body: some View {
        TabView {
            // Learning tab
            NavigationView {
                LearningListView()
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Обучение")
            }
            
            // Profile tab
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            
            // More tab
            NavigationView {
                MoreView()
            }
            .tabItem {
                Image(systemName: "ellipsis")
                Text("Ещё")
            }
        }
    }
}

#Preview {
    ContentView()
}
