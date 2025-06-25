//
//  ContentView.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = VKIDAuthService.shared
    @State private var showingLogin = false
    
    var body: some View {
        NavigationView {
            if authService.isAuthenticated {
                if authService.isApprovedByAdmin {
                    // Пользователь авторизован и одобрен - показываем основное приложение
                    MainTabView()
                } else {
                    // Пользователь авторизован, но ожидает одобрения
                    PendingApprovalView()
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
                            Image(systemName: "v.circle.fill")
                            Text("Войти через VK ID")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color(red: 0/255, green: 119/255, blue: 255/255))
                        .cornerRadius(10)
                    }
                    
                    // Info text
                    VStack(spacing: 5) {
                        Text("Для доступа к курсам требуется")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("одобрение администратора")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // Version info
                    Text("Version 2.0.0 - VK ID Integration")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
                .padding()
                .sheet(isPresented: $showingLogin) {
                    VKLoginView()
                }
            }
        }
        .onAppear {
            // Проверяем статус одобрения при запуске
            if authService.isAuthenticated {
                authService.checkAdminApproval()
            }
        }
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
