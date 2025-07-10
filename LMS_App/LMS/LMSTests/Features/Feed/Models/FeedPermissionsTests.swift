//
//  FeedPermissionsTests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
@testable import LMS

final class FeedPermissionsTests: XCTestCase {
    
    // MARK: - Default Permissions Tests
    
    func testStudentDefaultPermissions() {
        let permissions = FeedPermissions.studentDefault
        
        XCTAssertFalse(permissions.canPost)
        XCTAssertTrue(permissions.canComment)
        XCTAssertTrue(permissions.canLike)
        XCTAssertTrue(permissions.canShare)
        XCTAssertFalse(permissions.canDelete)
        XCTAssertFalse(permissions.canEdit)
        XCTAssertFalse(permissions.canModerate)
        XCTAssertEqual(permissions.visibilityOptions, [])
    }
    
    func testInstructorDefaultPermissions() {
        let permissions = FeedPermissions.instructorDefault
        
        XCTAssertTrue(permissions.canPost)
        XCTAssertTrue(permissions.canComment)
        XCTAssertTrue(permissions.canLike)
        XCTAssertTrue(permissions.canShare)
        XCTAssertTrue(permissions.canDelete)
        XCTAssertTrue(permissions.canEdit)
        XCTAssertFalse(permissions.canModerate)
        XCTAssertEqual(permissions.visibilityOptions, [.everyone, .students])
    }
    
    func testAdminDefaultPermissions() {
        let permissions = FeedPermissions.adminDefault
        
        XCTAssertTrue(permissions.canPost)
        XCTAssertTrue(permissions.canComment)
        XCTAssertTrue(permissions.canLike)
        XCTAssertTrue(permissions.canShare)
        XCTAssertTrue(permissions.canDelete)
        XCTAssertTrue(permissions.canEdit)
        XCTAssertTrue(permissions.canModerate)
        XCTAssertEqual(permissions.visibilityOptions.count, 4)
        XCTAssertTrue(permissions.visibilityOptions.contains(.everyone))
        XCTAssertTrue(permissions.visibilityOptions.contains(.students))
        XCTAssertTrue(permissions.visibilityOptions.contains(.admins))
        XCTAssertTrue(permissions.visibilityOptions.contains(.specific))
    }
    
    func testManagerDefaultPermissions() {
        let permissions = FeedPermissions.managerDefault
        
        XCTAssertTrue(permissions.canPost)
        XCTAssertTrue(permissions.canComment)
        XCTAssertTrue(permissions.canLike)
        XCTAssertTrue(permissions.canShare)
        XCTAssertTrue(permissions.canDelete)
        XCTAssertTrue(permissions.canEdit)
        XCTAssertTrue(permissions.canModerate)
        XCTAssertEqual(permissions.visibilityOptions.count, 3)
        XCTAssertTrue(permissions.visibilityOptions.contains(.everyone))
        XCTAssertTrue(permissions.visibilityOptions.contains(.students))
        XCTAssertTrue(permissions.visibilityOptions.contains(.specific))
    }
    
    // MARK: - Custom Permissions Tests
    
    func testCustomPermissionsCreation() {
        let customPermissions = FeedPermissions(
            canPost: true,
            canComment: false,
            canLike: true,
            canShare: false,
            canDelete: true,
            canEdit: false,
            canModerate: true,
            visibilityOptions: [.everyone, .admins]
        )
        
        XCTAssertTrue(customPermissions.canPost)
        XCTAssertFalse(customPermissions.canComment)
        XCTAssertTrue(customPermissions.canLike)
        XCTAssertFalse(customPermissions.canShare)
        XCTAssertTrue(customPermissions.canDelete)
        XCTAssertFalse(customPermissions.canEdit)
        XCTAssertTrue(customPermissions.canModerate)
        XCTAssertEqual(customPermissions.visibilityOptions.count, 2)
    }
    
    func testAllPermissionsEnabled() {
        let allEnabled = FeedPermissions(
            canPost: true,
            canComment: true,
            canLike: true,
            canShare: true,
            canDelete: true,
            canEdit: true,
            canModerate: true,
            visibilityOptions: [.everyone, .students, .admins, .specific]
        )
        
        XCTAssertTrue(allEnabled.canPost)
        XCTAssertTrue(allEnabled.canComment)
        XCTAssertTrue(allEnabled.canLike)
        XCTAssertTrue(allEnabled.canShare)
        XCTAssertTrue(allEnabled.canDelete)
        XCTAssertTrue(allEnabled.canEdit)
        XCTAssertTrue(allEnabled.canModerate)
        XCTAssertEqual(allEnabled.visibilityOptions.count, 4)
    }
    
    func testAllPermissionsDisabled() {
        let allDisabled = FeedPermissions(
            canPost: false,
            canComment: false,
            canLike: false,
            canShare: false,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: []
        )
        
        XCTAssertFalse(allDisabled.canPost)
        XCTAssertFalse(allDisabled.canComment)
        XCTAssertFalse(allDisabled.canLike)
        XCTAssertFalse(allDisabled.canShare)
        XCTAssertFalse(allDisabled.canDelete)
        XCTAssertFalse(allDisabled.canEdit)
        XCTAssertFalse(allDisabled.canModerate)
        XCTAssertTrue(allDisabled.visibilityOptions.isEmpty)
    }
    
    // MARK: - Visibility Options Tests
    
    func testEmptyVisibilityOptions() {
        let permissions = FeedPermissions(
            canPost: true,
            canComment: true,
            canLike: true,
            canShare: true,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: []
        )
        
        XCTAssertTrue(permissions.visibilityOptions.isEmpty)
    }
    
    func testSingleVisibilityOption() {
        let permissions = FeedPermissions(
            canPost: true,
            canComment: true,
            canLike: true,
            canShare: true,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: [.everyone]
        )
        
        XCTAssertEqual(permissions.visibilityOptions.count, 1)
        XCTAssertEqual(permissions.visibilityOptions.first, .everyone)
    }
    
    func testDuplicateVisibilityOptions() {
        // Testing that duplicates are allowed (no Set behavior)
        let permissions = FeedPermissions(
            canPost: true,
            canComment: true,
            canLike: true,
            canShare: true,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: [.everyone, .everyone, .students, .students]
        )
        
        XCTAssertEqual(permissions.visibilityOptions.count, 4)
    }
    
    // MARK: - Permission Combinations Tests
    
    func testReadOnlyPermissions() {
        let readOnly = FeedPermissions(
            canPost: false,
            canComment: false,
            canLike: true,
            canShare: true,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: []
        )
        
        XCTAssertFalse(readOnly.canPost)
        XCTAssertFalse(readOnly.canComment)
        XCTAssertTrue(readOnly.canLike)
        XCTAssertTrue(readOnly.canShare)
    }
    
    func testModeratorPermissions() {
        let moderator = FeedPermissions(
            canPost: true,
            canComment: true,
            canLike: true,
            canShare: true,
            canDelete: true,
            canEdit: false,
            canModerate: true,
            visibilityOptions: [.everyone, .students, .admins]
        )
        
        XCTAssertTrue(moderator.canModerate)
        XCTAssertTrue(moderator.canDelete)
        XCTAssertFalse(moderator.canEdit)
    }
    
    // MARK: - Codable Tests
    
    func testPermissionsEncoding() throws {
        let permissions = FeedPermissions.adminDefault
        let encoder = JSONEncoder()
        
        XCTAssertNoThrow(try encoder.encode(permissions))
        
        let data = try encoder.encode(permissions)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testPermissionsDecoding() throws {
        let permissions = FeedPermissions(
            canPost: true,
            canComment: false,
            canLike: true,
            canShare: false,
            canDelete: true,
            canEdit: false,
            canModerate: true,
            visibilityOptions: [.everyone, .students]
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(permissions)
        let decodedPermissions = try decoder.decode(FeedPermissions.self, from: data)
        
        XCTAssertEqual(decodedPermissions.canPost, permissions.canPost)
        XCTAssertEqual(decodedPermissions.canComment, permissions.canComment)
        XCTAssertEqual(decodedPermissions.canLike, permissions.canLike)
        XCTAssertEqual(decodedPermissions.canShare, permissions.canShare)
        XCTAssertEqual(decodedPermissions.canDelete, permissions.canDelete)
        XCTAssertEqual(decodedPermissions.canEdit, permissions.canEdit)
        XCTAssertEqual(decodedPermissions.canModerate, permissions.canModerate)
        XCTAssertEqual(decodedPermissions.visibilityOptions.count, permissions.visibilityOptions.count)
    }
} 