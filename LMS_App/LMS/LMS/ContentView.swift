//
//  ContentView.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showingLogin = false
    
    var body: some View {
        NavigationView {
            if authService.isAuthenticated {
                // Main app content
                MainTabView()
            } else {
                // Welcome screen
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
                        Text("Войти")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    // Version info
                    Text("Version 1.1.0 - Backend Integration")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
                .padding()
                .sheet(isPresented: $showingLogin) {
                    LoginView()
                }
            }
        }
        .onAppear {
            // Check if user token is still valid
            if authService.isAuthenticated {
                authService.getCurrentUser()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &authService.cancellables)
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
