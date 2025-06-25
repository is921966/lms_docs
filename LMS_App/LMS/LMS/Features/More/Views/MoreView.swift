import SwiftUI

struct MoreView: View {
    @StateObject private var authService = VKIDAuthService.shared
    @State private var showingPendingUsers = false
    @State private var isAdmin = false
    
    var body: some View {
        List {
            // Admin section
            if isAdmin {
                Section("Администрирование") {
                    NavigationLink(destination: PendingUsersView()) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("Новые студенты")
                            
                            Spacer()
                            
                            // Badge with pending count if needed
                            Text("!")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    
                    NavigationLink(destination: Text("Управление курсами")) {
                        HStack {
                            Image(systemName: "book.closed")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            Text("Управление курсами")
                        }
                    }
                }
            }
            
            // General section
            Section("Общее") {
                NavigationLink(destination: Text("Настройки")) {
                    HStack {
                        Image(systemName: "gearshape")
                            .foregroundColor(.gray)
                            .frame(width: 30)
                        
                        Text("Настройки")
                    }
                }
                
                NavigationLink(destination: Text("О приложении")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Text("О приложении")
                    }
                }
                
                NavigationLink(destination: Text("Помощь")) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        Text("Помощь")
                    }
                }
            }
            
            // Logout
            Section {
                Button(action: logout) {
                    HStack {
                        Image(systemName: "arrow.backward.square")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        
                        Text("Выйти")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Ещё")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            checkAdminStatus()
        }
    }
    
    private func checkAdminStatus() {
        if let user = authService.currentUser {
            isAdmin = user.roles.contains("admin") || user.permissions.contains("manage_users")
        }
    }
    
    private func logout() {
        authService.logout()
    }
}

#Preview {
    NavigationView {
        MoreView()
    }
}
