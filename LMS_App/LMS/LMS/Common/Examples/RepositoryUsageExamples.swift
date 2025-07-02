//
//  RepositoryUsageExamples.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation
import Combine

// MARK: - Repository Usage Examples

/// Comprehensive examples showing how to use the Repository layer
/// This file serves as documentation and reference for the development team
public final class RepositoryUsageExamples {
    
    private let repositoryFactory: RepositoryFactory
    private var cancellables = Set<AnyCancellable>()
    
    public init(repositoryFactory: RepositoryFactory = RepositoryFactoryManager.shared.getFactory()) {
        self.repositoryFactory = repositoryFactory
    }
    
    // MARK: - Basic CRUD Operations
    
    /// Example 1: Creating a new user
    public func createUserExample() async throws {
        print("=== Example 1: Creating a User ===")
        
        let userRepository = repositoryFactory.createUserRepository()
        
        // Create DTO with user data
        let createDTO = CreateUserDTO(
            email: "john.doe@company.com",
            firstName: "John",
            lastName: "Doe",
            role: "student",
            phoneNumber: "+1234567890",
            department: "Engineering"
        )
        
        do {
            // Create user through repository
            let createdUser = try await userRepository.createUser(createDTO)
            
            print("✅ User created successfully:")
            print("   ID: \(createdUser.id)")
            print("   Name: \(createdUser.fullName)")
            print("   Email: \(createdUser.email)")
            print("   Role: \(createdUser.role.rawValue)")
            print("   Active: \(createdUser.isActive)")
            
        } catch RepositoryError.validationError(let errors) {
            print("❌ Validation failed: \(errors.joined(separator: ", "))")
        } catch RepositoryError.invalidData(let message) {
            print("❌ Invalid data: \(message)")
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    /// Run all examples in sequence
    public func runAllExamples() async throws {
        print("🚀 Starting Repository Usage Examples")
        print("=====================================")
        
        try await createUserExample()
        
        print("\n🎉 All Repository examples completed successfully!")
        print("=====================================")
    }
}

// MARK: - Quick Start Guide

/// Quick start guide for new developers
public struct RepositoryQuickStartGuide {
    
    public static func printQuickStart() {
        print("""
        
        📚 REPOSITORY LAYER QUICK START GUIDE
        ====================================
        
        1. 🏗️ SETUP
        -----------
        // Configure repository factory
        RepositoryFactoryManager.shared.configureForDevelopment()
        
        2. 📝 BASIC USAGE
        -----------------
        let userRepository = RepositoryFactoryManager.shared.userRepository
        
        // Create user
        let createDTO = CreateUserDTO(email: "user@example.com", firstName: "John", lastName: "Doe", role: "student")
        let user = try await userRepository.createUser(createDTO)
        
        // Find user
        let foundUser = try await userRepository.findByEmail("user@example.com")
        
        // Update user
        let updateDTO = UpdateUserDTO(firstName: "Jane")
        let updatedUser = try await userRepository.updateUser(user.id, with: updateDTO)
        
        """)
    }
}
