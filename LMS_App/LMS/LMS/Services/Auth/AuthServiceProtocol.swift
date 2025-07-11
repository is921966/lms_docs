//
//  AuthServiceProtocol.swift
//  LMS
//
//  Created on 06/07/2025.
//

import Foundation

@MainActor
protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func logout() async throws
    func refreshToken() async throws -> String
    func getCurrentUser() async throws -> UserResponse
    func updateProfile(firstName: String, lastName: String) async throws -> UserResponse
    var isAuthenticated: Bool { get }
    var currentUser: UserResponse? { get }
} 