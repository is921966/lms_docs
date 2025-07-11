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
        let category = CompetencyCategory.technical
        let color = CompetencyColor.blue
        let levels = CompetencyLevel.defaultLevels()
        
        // When
        let competency = Competency(
            id: id,
            name: name,
            description: description,
            category: category,
            color: color,
            levels: levels
        )
        
        // Then
        XCTAssertEqual(competency.id, id)
        XCTAssertEqual(competency.name, name)
        XCTAssertEqual(competency.description, description)
        XCTAssertEqual(competency.category, category)
        XCTAssertEqual(competency.color, color)
        XCTAssertEqual(competency.levels.count, levels.count)
        XCTAssertTrue(competency.isActive)
        XCTAssertTrue(competency.relatedPositions.isEmpty)
    }
    
    func testCompetencyWithRelatedPositions() {
        // Given
        let positions = ["ios-developer", "mobile-lead", "tech-lead"]
        
        // When
        let competency = Competency(
            name: "iOS Developer",
            description: "iOS app development",
            category: .technical,
            relatedPositions: positions
        )
        
        // Then
        XCTAssertEqual(competency.relatedPositions.count, 3)
        XCTAssertTrue(competency.relatedPositions.contains("ios-developer"))
        XCTAssertTrue(competency.relatedPositions.contains("mobile-lead"))
    }
    
    // MARK: - Level Tests
    
    func testCompetencyLevelsValidation() {
        // Test default levels
        let competency = Competency(
            name: "Test",
            description: "Test"
        )
        
        // Default should have 5 levels
        XCTAssertEqual(competency.levels.count, 5)
        XCTAssertEqual(competency.maxLevel, 5)
        
        // Test custom levels
        let customLevels = [
            CompetencyLevel(level: 1, name: "Beginner", description: "Just starting"),
            CompetencyLevel(level: 2, name: "Advanced", description: "Experienced")
        ]
        
        let customCompetency = Competency(
            name: "Custom",
            description: "Custom levels",
            levels: customLevels
        )
        
        XCTAssertEqual(customCompetency.levels.count, 2)
        XCTAssertEqual(customCompetency.maxLevel, 2)
    }
    
    func testCompetencyColorProperties() {
        let competency1 = createCompetency(color: .blue)
        XCTAssertEqual(competency1.colorHex, "#2196F3")
        
        let competency2 = createCompetency(color: .green)
        XCTAssertEqual(competency2.colorHex, "#4CAF50")
        
        let competency3 = createCompetency(color: .red)
        XCTAssertEqual(competency3.colorHex, "#F44336")
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
            "category": "technical",
            "color": "blue",
            "levels": [
                {
                    "id": "550e8400-e29b-41d4-a716-446655440001",
                    "level": 1,
                    "name": "Начальный",
                    "description": "Базовые знания"
                }
            ],
            "isActive": true,
            "relatedPositions": ["pos1", "pos2"],
            "createdAt": "2025-01-01T00:00:00Z",
            "updatedAt": "2025-01-01T00:00:00Z",
            "currentLevel": 1,
            "requiredLevel": 3,
            "usageCount": 0,
            "coursesCount": 0
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let competency = try decoder.decode(Competency.self, from: json)
        
        // Then
        XCTAssertEqual(competency.name, "Test Competency")
        XCTAssertEqual(competency.category, .technical)
        XCTAssertEqual(competency.color, .blue)
        XCTAssertEqual(competency.levels.count, 1)
        XCTAssertEqual(competency.relatedPositions.count, 2)
    }
    
    func testCompetencyRoundTripCoding() throws {
        // Given
        let original = createCompetency(
            relatedPositions: ["ios-developer", "mobile-lead"]
        )
        
        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Competency.self, from: data)
        
        // Then
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.name, decoded.name)
        XCTAssertEqual(original.description, decoded.description)
        XCTAssertEqual(original.category, decoded.category)
        XCTAssertEqual(original.color, decoded.color)
        XCTAssertEqual(original.levels.count, decoded.levels.count)
        XCTAssertEqual(original.relatedPositions, decoded.relatedPositions)
    }
    
    // MARK: - Hashable Tests
    
    func testCompetencyEquality() {
        // Given
        let id = UUID()
        let competency1 = Competency(
            id: id,
            name: "Test",
            description: "Test"
        )
        let competency2 = Competency(
            id: id,
            name: "Different Name",
            description: "Different Description",
            category: .softSkills,
            color: .red
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
        category: CompetencyCategory = .technical,
        color: CompetencyColor = .blue,
        levels: [CompetencyLevel] = CompetencyLevel.defaultLevels(),
        relatedPositions: [String] = []
    ) -> Competency {
        return Competency(
            id: id,
            name: name,
            description: description,
            category: category,
            color: color,
            levels: levels,
            relatedPositions: relatedPositions
        )
    }
} 