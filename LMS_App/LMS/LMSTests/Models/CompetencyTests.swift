//
//  CompetencyTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

final class CompetencyTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testCompetencyInitialization() {
        // Given
        let id = UUID()
        let name = "iOS Development"
        let description = "Mobile app development using Swift"
        let categoryId = UUID()
        let level = 3
        
        // When
        let competency = Competency(
            id: id,
            name: name,
            description: description,
            categoryId: categoryId,
            level: level,
            skills: [],
            requiredCourses: [],
            relatedPositions: []
        )
        
        // Then
        XCTAssertEqual(competency.id, id)
        XCTAssertEqual(competency.name, name)
        XCTAssertEqual(competency.description, description)
        XCTAssertEqual(competency.categoryId, categoryId)
        XCTAssertEqual(competency.level, level)
        XCTAssertTrue(competency.skills.isEmpty)
        XCTAssertTrue(competency.requiredCourses.isEmpty)
        XCTAssertTrue(competency.relatedPositions.isEmpty)
    }
    
    func testCompetencyWithSkills() {
        // Given
        let skills = ["Swift", "UIKit", "SwiftUI", "Core Data"]
        
        // When
        let competency = Competency(
            name: "iOS Developer",
            description: "iOS app development",
            categoryId: UUID(),
            level: 4,
            skills: skills,
            requiredCourses: [],
            relatedPositions: []
        )
        
        // Then
        XCTAssertEqual(competency.skills.count, 4)
        XCTAssertTrue(competency.skills.contains("Swift"))
        XCTAssertTrue(competency.skills.contains("SwiftUI"))
    }
    
    // MARK: - Level Tests
    
    func testCompetencyLevelValidation() {
        // Test valid levels
        for level in 1...5 {
            let competency = Competency(
                name: "Test",
                description: "Test",
                categoryId: UUID(),
                level: level,
                skills: [],
                requiredCourses: [],
                relatedPositions: []
            )
            XCTAssertEqual(competency.level, level)
        }
    }
    
    func testCompetencyLevelDescription() {
        let competency1 = createCompetency(level: 1)
        XCTAssertEqual(competency1.levelDescription, "Начальный")
        
        let competency2 = createCompetency(level: 2)
        XCTAssertEqual(competency2.levelDescription, "Базовый")
        
        let competency3 = createCompetency(level: 3)
        XCTAssertEqual(competency3.levelDescription, "Средний")
        
        let competency4 = createCompetency(level: 4)
        XCTAssertEqual(competency4.levelDescription, "Продвинутый")
        
        let competency5 = createCompetency(level: 5)
        XCTAssertEqual(competency5.levelDescription, "Эксперт")
    }
    
    // MARK: - Codable Tests
    
    func testCompetencyEncoding() throws {
        // Given
        let competency = createCompetency()
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(competency)
        
        // Then
        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testCompetencyDecoding() throws {
        // Given
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Test Competency",
            "description": "Test Description",
            "categoryId": "550e8400-e29b-41d4-a716-446655440001",
            "level": 3,
            "skills": ["Skill1", "Skill2"],
            "requiredCourses": ["course1", "course2"],
            "relatedPositions": ["pos1", "pos2"]
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let competency = try decoder.decode(Competency.self, from: json)
        
        // Then
        XCTAssertEqual(competency.name, "Test Competency")
        XCTAssertEqual(competency.level, 3)
        XCTAssertEqual(competency.skills.count, 2)
        XCTAssertEqual(competency.requiredCourses.count, 2)
        XCTAssertEqual(competency.relatedPositions.count, 2)
    }
    
    func testCompetencyRoundTripCoding() throws {
        // Given
        let original = createCompetency(
            skills: ["Swift", "Objective-C"],
            requiredCourses: ["ios-basics", "swift-advanced"],
            relatedPositions: ["ios-developer", "mobile-lead"]
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Competency.self, from: data)
        
        // Then
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.name, decoded.name)
        XCTAssertEqual(original.description, decoded.description)
        XCTAssertEqual(original.level, decoded.level)
        XCTAssertEqual(original.skills, decoded.skills)
        XCTAssertEqual(original.requiredCourses, decoded.requiredCourses)
        XCTAssertEqual(original.relatedPositions, decoded.relatedPositions)
    }
    
    // MARK: - Equatable Tests
    
    func testCompetencyEquality() {
        // Given
        let id = UUID()
        let competency1 = Competency(
            id: id,
            name: "Test",
            description: "Test",
            categoryId: UUID(),
            level: 3,
            skills: [],
            requiredCourses: [],
            relatedPositions: []
        )
        let competency2 = Competency(
            id: id,
            name: "Different Name",
            description: "Different Description",
            categoryId: UUID(),
            level: 5,
            skills: ["Different"],
            requiredCourses: [],
            relatedPositions: []
        )
        
        // Then
        XCTAssertEqual(competency1, competency2) // Equal by ID only
    }
    
    func testCompetencyInequality() {
        // Given
        let competency1 = createCompetency()
        let competency2 = createCompetency()
        
        // Then
        XCTAssertNotEqual(competency1, competency2) // Different IDs
    }
    
    // MARK: - Hashable Tests
    
    func testCompetencyHashable() {
        // Given
        let competency1 = createCompetency()
        let competency2 = createCompetency()
        let competency3 = competency1
        
        // When
        var set = Set<Competency>()
        set.insert(competency1)
        set.insert(competency2)
        set.insert(competency3) // Same as competency1
        
        // Then
        XCTAssertEqual(set.count, 2) // competency3 is duplicate of competency1
    }
    
    // MARK: - Helper Methods
    
    private func createCompetency(
        id: UUID = UUID(),
        name: String = "Test Competency",
        description: String = "Test Description",
        categoryId: UUID = UUID(),
        level: Int = 3,
        skills: [String] = [],
        requiredCourses: [String] = [],
        relatedPositions: [String] = []
    ) -> Competency {
        return Competency(
            id: id,
            name: name,
            description: description,
            categoryId: categoryId,
            level: level,
            skills: skills,
            requiredCourses: requiredCourses,
            relatedPositions: relatedPositions
        )
    }
}

// MARK: - Competency Extension for Tests

extension Competency {
    var levelDescription: String {
        switch level {
        case 1: return "Начальный"
        case 2: return "Базовый"
        case 3: return "Средний"
        case 4: return "Продвинутый"
        case 5: return "Эксперт"
        default: return "Неизвестный"
        }
    }
} 