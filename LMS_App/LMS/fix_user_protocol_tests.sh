#!/bin/bash

# Fix PositionListViewTests.swift
sed -i '' 's/struct MockUser: UserProtocol {/struct MockUser {/' LMSTests/Views/PositionListViewTests.swift
sed -i '' 's/var id: String = UUID().uuidString/var id: UUID = UUID()/' LMSTests/Views/PositionListViewTests.swift
sed -i '' 's/var role: UserRole/var role: User.Role/' LMSTests/Views/PositionListViewTests.swift
sed -i '' 's/var isActive: Bool = true/var avatarURL: URL? = nil/' LMSTests/Views/PositionListViewTests.swift
sed -i '' 's/var department: String? = "IT"/init(role: User.Role) { self.role = role }/' LMSTests/Views/PositionListViewTests.swift

# Fix CompetencyListViewTests.swift
sed -i '' 's/struct MockUser: UserProtocol {/struct MockUser {/' LMSTests/Views/CompetencyListViewTests.swift
sed -i '' 's/var id: String = UUID().uuidString/var id: UUID = UUID()/' LMSTests/Views/CompetencyListViewTests.swift
sed -i '' 's/var role: UserRole/var role: User.Role/' LMSTests/Views/CompetencyListViewTests.swift
sed -i '' 's/var isActive: Bool = true/var avatarURL: URL? = nil/' LMSTests/Views/CompetencyListViewTests.swift
sed -i '' 's/var department: String? = "IT"/init(role: User.Role) { self.role = role }/' LMSTests/Views/CompetencyListViewTests.swift

# Fix StudentDashboardViewTests.swift
sed -i '' 's/struct MockUser: UserProtocol {/struct MockUser {/' LMSTests/Views/StudentDashboardViewTests.swift
sed -i '' 's/var id: String = UUID().uuidString/var id: UUID = UUID()/' LMSTests/Views/StudentDashboardViewTests.swift
sed -i '' 's/var role: UserRole/var role: User.Role/' LMSTests/Views/StudentDashboardViewTests.swift
sed -i '' 's/var isActive: Bool = true/var avatarURL: URL? = nil/' LMSTests/Views/StudentDashboardViewTests.swift
sed -i '' 's/var department: String? = "IT"/init(role: User.Role) { self.role = role }/' LMSTests/Views/StudentDashboardViewTests.swift

echo "Fixed UserProtocol references in test files"
