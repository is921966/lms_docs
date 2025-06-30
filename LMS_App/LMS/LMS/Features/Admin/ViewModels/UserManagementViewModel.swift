//
//  UserManagementViewModel.swift
//  LMS
//
//  Created on 27/01/2025.
//

import Foundation
import SwiftUI

class UserManagementViewModel: ObservableObject {
    @Published var users: [UserResponse] = []
    @Published var pendingUsers: [UserResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = MockAuthService.shared

    init() {
        loadUsers()
        loadPendingUsers()
    }

    func loadUsers() {
        isLoading = true

        // In real app this would be an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // Mock data - simplified for now
            self?.users = []
            self?.isLoading = false
        }
    }

    func loadPendingUsers() {
        // In real app this would be an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.pendingUsers = []
        }
    }

    func approveUser(_ user: UserResponse) {
        // In real app this would be an API call
        pendingUsers.removeAll { $0.id == user.id }
        users.append(user)
    }

    func rejectUser(_ user: UserResponse) {
        pendingUsers.removeAll { $0.id == user.id }
    }

    func toggleUserStatus(_ user: UserResponse) {
        // In real app this would update user status
    }

    func deleteUser(_ user: UserResponse) {
        users.removeAll { $0.id == user.id }
    }

    func updateUserRole(_ user: UserResponse, newRoles: [String]) {
        // In real app this would update user roles
    }
}

// Extension to add computed properties to UserResponse
extension UserResponse {
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var isActive: Bool {
        isApproved
    }
}
