//
//  AdminManagementView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct AdminManagementView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showingAddUser = false
    @State private var selectedUser: UserResponse?

    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            Picker("Управление", selection: $selectedTab) {
                Text("Пользователи").tag(0)
                Text("Ожидают одобрения").tag(1)
                Text("Роли и права").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch selectedTab {
            case 0:
                UsersListView(searchText: $searchText)
            case 1:
                PendingUsersView()
            case 2:
                RolesManagementView()
            default:
                EmptyView()
            }
        }
        .navigationTitle("Управление")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddUser = true
                }) {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView()
        }
    }
}

// MARK: - Users List View
struct UsersListView: View {
    @Binding var searchText: String
    @StateObject private var viewModel = UserManagementViewModel()
    @State private var selectedFilter: UserFilter = .all
    @State private var selectedUser: UserResponse?

    enum UserFilter: String, CaseIterable {
        case all = "Все"
        case active = "Активные"
        case blocked = "Заблокированные"
        case admins = "Администраторы"
    }

    var filteredUsers: [UserResponse] {
        var users = viewModel.users

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .active:
            users = users.filter { $0.isActive }
        case .blocked:
            users = users.filter { !$0.isActive }
        case .admins:
            users = users.filter { $0.roles.contains("admin") || $0.roles.contains("superAdmin") }
        }

        // Apply search
        if !searchText.isEmpty {
            users = users.filter { user in
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText) ||
                user.department?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }

        return users
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Поиск пользователей", text: $searchText)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(UserFilter.allCases, id: \.self) { filter in
                        AdminFilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        )                            { selectedFilter = filter }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)

            // Users list
            if filteredUsers.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "person.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Пользователи не найдены")
                        .font(.headline)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredUsers) { user in
                            UserManagementCard(user: user)
                                .onTapGesture {
                                    selectedUser = user
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedUser) { user in
            NavigationView {
                Text("User Details: \(user.fullName)")
                    .navigationTitle(user.fullName)
            }
        }
        .onAppear {
            viewModel.loadUsers()
        }
    }
}

// MARK: - Pending Users View (Updated)
struct PendingUsersView: View {
    @StateObject private var viewModel = UserManagementViewModel()

    var body: some View {
        if viewModel.pendingUsers.isEmpty {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("Нет пользователей, ожидающих одобрения")
                    .font(.headline)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.pendingUsers) { user in
                        PendingUserCard(user: user) {
                            viewModel.approveUser(user)
                        } onReject: {
                            viewModel.rejectUser(user)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Roles Management View
struct RolesManagementView: View {
    @StateObject private var viewModel = RoleManagementViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Role statistics
                RoleStatisticsSection(roles: viewModel.roleStatistics)

                // Role permissions
                ForEach(viewModel.roles) { role in
                    RolePermissionsCard(role: role)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadRoles()
        }
    }
}

// MARK: - Helper Views
struct UserManagementCard: View {
    let user: UserResponse

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(.gray)

            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.headline)

                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    if let department = user.department {
                        Label(department, systemImage: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let position = user.position {
                        Label(position, systemImage: "briefcase")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Status and role
            VStack(alignment: .trailing, spacing: 6) {
                // Role badge
                if user.roles.contains("admin") || user.roles.contains("superAdmin") {
                    Text(user.roles.contains("superAdmin") ? "Супер админ" : "Админ")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .cornerRadius(12)
                }

                // Status
                HStack(spacing: 4) {
                    Circle()
                        .fill(user.isActive ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(user.isActive ? "Активен" : "Заблокирован")
                        .font(.caption)
                        .foregroundColor(user.isActive ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PendingUserCard: View {
    let user: UserResponse
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // User info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName)
                        .font(.headline)

                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let registrationDate = user.registrationDate {
                        Text("Зарегистрирован: \(registrationDate.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Department and position
                VStack(alignment: .trailing, spacing: 4) {
                    if let department = user.department {
                        Text(department)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let position = user.position {
                        Text(position)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: onReject) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Отклонить")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }

                Button(action: onApprove) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Одобрить")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RoleStatisticsSection: View {
    let roles: [RoleStatistic]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Распределение ролей")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(roles) { stat in
                    VStack(spacing: 8) {
                        Text("\(stat.count)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(stat.roleName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct RolePermissionsCard: View {
    let role: Role

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(role.name)
                    .font(.headline)

                Spacer()

                Text("\(role.usersCount) пользователей")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Permissions
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(role.permissions, id: \.self) { permission in
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(permission)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AdminFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
    }
}

// MARK: - Placeholder Views
struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Добавление пользователя")
                    .font(.title)
            }
            .navigationTitle("Новый пользователь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Data Models
struct RoleStatistic: Identifiable {
    let id = UUID()
    let roleName: String
    let count: Int
}

struct Role: Identifiable {
    let id = UUID()
    let name: String
    var permissions: [String]
    let usersCount: Int
}

#Preview {
    NavigationView {
        AdminManagementView()
    }
}
