//
//  UserServiceProtocol.swift
//  LMS
//
//  Created on 06/07/2025.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
    func fetchUser(id: UUID) async throws -> User
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(_ id: UUID) async throws
} 