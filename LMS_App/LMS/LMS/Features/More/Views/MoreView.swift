import SwiftUI

struct MoreView: View {
    // TEMPORARY: Use mock service for TestFlight testing
    @StateObject private var authService = MockAuthService.shared

    @State private var showingPendingUsers = false
    @State private var isAdmin = false

    var body: some View {
        List {
            // Admin section
            if isAdmin {
                Section("Администрирование") {
                    NavigationLink(destination: MockPendingUsersView()) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.blue)
                                .frame(width: 30)

                            Text("Новые студенты")

                            Spacer()

                            // Badge with pending count
                            Text("3")
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

            #if DEBUG
            // Development section
            Section("Разработка") {
                HStack {
                    Image(systemName: "hammer.fill")
                        .foregroundColor(.purple)
                        .frame(width: 30)

                    Text("Режим разработки")

                    Spacer()

                    Text("Включен")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            #endif

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

// MARK: - Mock Pending Users View
struct MockPendingUsersView: View {
    @StateObject private var adminService = MockAdminService.shared
    @State private var selectedUsers = Set<String>()
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""

    var body: some View {
        VStack {
            if adminService.isLoading {
                ProgressView("Загрузка...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if adminService.pendingUsers.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("Нет новых студентов")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Все студенты уже одобрены")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Button("Обновить") {
                        adminService.fetchPendingUsers()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(adminService.pendingUsers) { user in
                    HStack {
                        // Checkbox
                        Button(action: {
                            if selectedUsers.contains(user.id) {
                                selectedUsers.remove(user.id)
                            } else {
                                selectedUsers.insert(user.id)
                            }
                        }) {
                            Image(systemName: selectedUsers.contains(user.id) ? "checkmark.square.fill" : "square")
                                .font(.system(size: 24))
                                .foregroundColor(selectedUsers.contains(user.id) ? .blue : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // User info
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Новые студенты")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Одобрить (\(selectedUsers.count))") {
                    approveSelectedUsers()
                }
                .disabled(selectedUsers.isEmpty)
            }
        }
        .onAppear {
            adminService.fetchPendingUsers()
        }
        .alert("Успешно", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text(successMessage)
        }
    }

    private func approveSelectedUsers() {
        adminService.approveSelectedUsers(userIds: Array(selectedUsers)) { success in
            if success {
                successMessage = "Одобрено пользователей: \(selectedUsers.count)"
                showingSuccessAlert = true
                selectedUsers.removeAll()
            }
        }
    }
}

#Preview {
    NavigationView {
        MoreView()
    }
}
