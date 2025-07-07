#!/bin/bash

# Create a shared MockAuthUser file
cat > LMSTests/Helpers/MockAuthUser.swift << 'EOFILE'
import Foundation
@testable import LMS

struct MockAuthUser {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole
    
    init(
        id: String = UUID().uuidString,
        email: String = "test@example.com",
        firstName: String = "Test",
        lastName: String = "User",
        role: UserRole = .student
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
    }
    
    func toAuthUser() -> AuthUser {
        let userResponse = UserResponse(
            id: id,
            email: email,
            name: "\(firstName) \(lastName)",
            role: role,
            firstName: firstName,
            lastName: lastName,
            avatar: nil,
            lastLogin: nil,
            status: "active"
        )
        return AuthUser(from: userResponse)
    }
}
EOFILE

echo "Created MockAuthUser helper"

# Fix PositionListViewTests
sed -i '' '/struct MockUser {/,/}/d' LMSTests/Views/PositionListViewTests.swift
sed -i '' 's/MockUser(role: \(.*\))/MockAuthUser(role: \1).toAuthUser()/' LMSTests/Views/PositionListViewTests.swift

# Fix CompetencyListViewTests  
sed -i '' '/struct MockUser {/,/}/d' LMSTests/Views/CompetencyListViewTests.swift
sed -i '' 's/MockUser(role: \(.*\))/MockAuthUser(role: \1).toAuthUser()/' LMSTests/Views/CompetencyListViewTests.swift

# Fix StudentDashboardViewTests
sed -i '' '/struct MockUser {/,/}/d' LMSTests/Views/StudentDashboardViewTests.swift
sed -i '' 's/MockUser(role: \(.*\))/MockAuthUser(role: \1).toAuthUser()/' LMSTests/Views/StudentDashboardViewTests.swift

echo "Fixed all test files to use MockAuthUser"
