//
//  ContentView.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        if authService.isAuthenticated {
            authenticatedView
        } else {
            LoginView()
        }
    }
    
    var authenticatedView: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            NavigationView {
                if authService.currentUser?.role == .admin || authService.currentUser?.role == .moderator {
                    AdminDashboardView()
                } else {
                    StudentDashboardView()
                }
            }
            .tabItem {
                Label("Главная", systemImage: "house.fill")
            }
            .tag(0)
            
            // Learning tab
            NavigationView {
                LearningListView()
            }
            .tabItem {
                Label("Обучение", systemImage: "book.fill")
            }
            .tag(1)
            
            // Analytics tab
            NavigationView {
                AnalyticsDashboard()
            }
            .tabItem {
                Label("Аналитика", systemImage: "chart.bar.fill")
            }
            .tag(2)
            
            // Profile
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Профиль", systemImage: "person.fill")
            }
            .tag(3)
            
            #if DEBUG
            // Debug menu for development
            NavigationView {
                DebugMenuView()
            }
            .tabItem {
                Label("Debug", systemImage: "wrench.fill")
            }
            .tag(4)
            #endif
        }
        .accentColor(.blue)
    }
}

#if DEBUG
struct DebugMenuView: View {
    var body: some View {
        List {
            Section("Feedback System") {
                NavigationLink(destination: FeedbackDebugMenu()) {
                    Label("Feedback Debug", systemImage: "exclamationmark.bubble")
                }
            }
            
            Section("Network") {
                NavigationLink(destination: NetworkDebugView()) {
                    Label("Network Monitor", systemImage: "wifi")
                }
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
        }
        .navigationTitle("Debug Menu")
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

struct NetworkDebugView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        List {
            Section("Status") {
                HStack {
                    Text("Connection")
                    Spacer()
                    Text(networkMonitor.isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(networkMonitor.isConnected ? .green : .red)
                }
                
                HStack {
                    Text("Connection Type")
                    Spacer()
                    Text(networkMonitor.connectionType)
                }
            }
        }
        .navigationTitle("Network Debug")
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthService.shared)
    }
}
