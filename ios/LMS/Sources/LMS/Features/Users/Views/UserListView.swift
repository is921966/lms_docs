import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var showingFilters = false
    @State private var selectedUser: User?
    @AppStorage("isAdminMode") private var isAdminMode = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filters
                if showingFilters {
                    filterBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Selection Mode Bar
                if viewModel.isSelectionMode {
                    selectionBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Users List
                if viewModel.isLoading && viewModel.users.isEmpty {
                    LoadingView(message: "Loading users...")
                } else if viewModel.filteredUsers.isEmpty {
                    emptyView
                } else {
                    usersList
                }
            }
            .navigationTitle("Users")
            .toolbar {
                toolbarContent
            }
            .task {
                await viewModel.loadUsers()
            }
            .refreshable {
                await viewModel.refreshUsers()
            }
            .sheet(item: $selectedUser) { user in
                UserDetailView(user: user)
            }
            .animation(.easeInOut(duration: 0.2), value: showingFilters)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isSelectionMode)
        }
    }
    
    // MARK: - Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search users...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([nil, User.Role.student, .instructor, .admin, .superAdmin], id: \.self) { role in
                    FilterChip(
                        title: role == nil ? "All" : roleTitle(for: role!),
                        isSelected: viewModel.selectedRole == role,
                        action: { viewModel.selectedRole = role }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var selectionBar: some View {
        HStack {
            Text("\(viewModel.selectedUsers.count) selected")
                .font(.headline)
            
            Spacer()
            
            Button("Select All") {
                viewModel.selectAll()
            }
            .disabled(viewModel.selectedUsers.count == viewModel.filteredUsers.count)
            
            Button("Deselect All") {
                viewModel.deselectAll()
            }
            .disabled(viewModel.selectedUsers.isEmpty)
            
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteSelectedUsers()
                }
            }
            .disabled(viewModel.selectedUsers.isEmpty)
        }
        .padding()
        .background(Color(uiColor: .tertiarySystemBackground))
    }
    
    private var usersList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredUsers) { user in
                    UserCard(
                        user: user,
                        isSelected: viewModel.selectedUsers.contains(user.id),
                        onTap: {
                            if viewModel.isSelectionMode {
                                viewModel.toggleUserSelection(user)
                            } else {
                                selectedUser = user
                            }
                        }
                    )
                    .contextMenu {
                        if isAdminMode {
                            Button(action: { selectedUser = user }) {
                                Label("View Details", systemImage: "eye")
                            }
                            
                            Button(action: {
                                // Navigate to edit
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.question")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No users found")
                .font(.headline)
            
            Text("Try adjusting your search or filters")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { showingFilters.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(showingFilters ? .fill : .none)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            if isAdminMode {
                Menu {
                    Button(action: { viewModel.isSelectionMode.toggle() }) {
                        Label(
                            viewModel.isSelectionMode ? "Cancel Selection" : "Select",
                            systemImage: "checkmark.circle"
                        )
                    }
                    
                    Button(action: {
                        // Navigate to add user
                    }) {
                        Label("Add User", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func roleTitle(for role: User.Role) -> String {
        switch role {
        case .student: return "Students"
        case .instructor: return "Instructors"
        case .admin: return "Admins"
        case .superAdmin: return "Super Admins"
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(uiColor: .systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
} 