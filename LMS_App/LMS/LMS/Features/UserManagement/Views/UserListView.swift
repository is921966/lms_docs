import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    @State private var showingCreateUser = false
    @State private var showingFilters = false
    @State private var selectedUser: DomainUser?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterSection
                
                // Statistics Header (if users loaded)
                if !viewModel.users.isEmpty {
                    statisticsSection
                }
                
                // Users List
                usersListSection
            }
            .navigationTitle("Пользователи")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    filterButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
        }
        .task {
            await viewModel.loadUsers()
        }
        .refreshable {
            await viewModel.refreshUsers()
        }
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Поиск пользователей...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button("Очистить") {
                        viewModel.searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        let stats = viewModel.userStatistics
        
        return VStack(spacing: 8) {
            HStack {
                StatisticCard(
                    title: "Всего",
                    value: "\(stats.totalUsers)",
                    subtitle: "",
                    color: .blue
                )
                
                StatisticCard(
                    title: "Активных",
                    value: "\(stats.activeUsers)",
                    subtitle: "",
                    color: .green
                )
                
                StatisticCard(
                    title: "Неактивных",
                    value: "\(stats.inactiveUsers)",
                    subtitle: "",
                    color: .orange
                )
                
                StatisticCard(
                    title: "Активность",
                    value: "\(Int(stats.activationRate * 100))%",
                    subtitle: "",
                    color: .purple
                )
            }
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Users List Section
    private var usersListSection: some View {
        Group {
            if viewModel.isLoading && viewModel.users.isEmpty {
                loadingView
            } else if viewModel.filteredUsers.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                usersList
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загрузка пользователей...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(viewModel.hasActiveFilters ? "Пользователи не найдены" : "Нет пользователей")
                .font(.headline)
                .foregroundColor(.gray)
            
            if viewModel.hasActiveFilters {
                Text("Попробуйте изменить критерии поиска")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button("Очистить фильтры") {
                    viewModel.clearAllFilters()
                }
                .foregroundColor(.blue)
            } else {
                Button("Добавить первого пользователя") {
                    showingCreateUser = true
                }
                .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var usersList: some View {
        List {
            ForEach(viewModel.filteredUsers, id: \.id) { user in
                UserRowView(user: user)
                    .onTapGesture {
                        selectedUser = user
                    }
            }
            
            // Load more section
            if viewModel.hasMorePages {
                loadMoreSection
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var loadMoreSection: some View {
        HStack {
            if viewModel.isLoadingMore {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Загрузка...")
                    .foregroundColor(.gray)
            } else {
                Button("Загрузить еще") {
                    Task {
                        await viewModel.loadMoreUsers()
                    }
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            if !viewModel.isLoadingMore {
                Task {
                    await viewModel.loadMoreUsers()
                }
            }
        }
    }
    
    // MARK: - Navigation Bar Items
    private var filterButton: some View {
        Button(action: { showingFilters = true }) {
            HStack {
                Image(systemName: "line.horizontal.3.decrease.circle")
                if viewModel.activeFiltersCount > 0 {
                    Text("\(viewModel.activeFiltersCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var addButton: some View {
        Button(action: { showingCreateUser = true }) {
            Image(systemName: "plus")
        }
    }
}

// MARK: - Supporting Views

struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct UserRowView: View {
    let user: DomainUser
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text(user.initials)
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.fullName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    // Role badge
                    Text(user.role.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(user.role.color.opacity(0.2))
                        .foregroundColor(user.role.color)
                        .cornerRadius(4)
                    
                    // Status badge
                    Text(user.isActive ? "Активен" : "Неактивен")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(user.isActive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundColor(user.isActive ? .green : .red)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

extension DomainUserRole {
    var color: Color {
        switch self {
        case .student: return .blue
        case .teacher: return .green
        case .admin: return .red
        case .manager: return .orange
        case .hr: return .purple
        case .superAdmin: return .pink
        }
    }
}

// MARK: - Preview

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
