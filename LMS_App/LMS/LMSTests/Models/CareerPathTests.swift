//
//  CareerPathTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

final class CareerPathTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testCareerPathInitialization() {
        // Given
        let id = UUID()
        let fromPositionId = UUID()
        let toPositionId = UUID()
        let fromPositionName = "iOS Developer Junior"
        let toPositionName = "iOS Developer Middle"
        let estimatedDuration = CareerPathDuration.year1
        
        // When
        let careerPath = CareerPath(
            id: id,
            fromPositionId: fromPositionId,
            toPositionId: toPositionId,
            fromPositionName: fromPositionName,
            toPositionName: toPositionName,
            estimatedDuration: estimatedDuration,
            requirements: [],
            description: "Standard career progression",
            successRate: 0.85
        )
        
        // Then
        XCTAssertEqual(careerPath.id, id)
        XCTAssertEqual(careerPath.fromPositionId, fromPositionId)
        XCTAssertEqual(careerPath.toPositionId, toPositionId)
        XCTAssertEqual(careerPath.fromPositionName, fromPositionName)
        XCTAssertEqual(careerPath.toPositionName, toPositionName)
        XCTAssertEqual(careerPath.estimatedDuration, estimatedDuration)
        XCTAssertEqual(careerPath.successRate, 0.85)
        XCTAssertTrue(careerPath.requirements.isEmpty)
    }
    
    // MARK: - Requirements Tests
    
    func testCareerPathWithRequirements() {
        // Given
        let requirements = [
            CareerPathRequirement(
                title: "iOS Development Level 3",
                description: "Master iOS development",
                type: .competency
            ),
            CareerPathRequirement(
                title: "2+ Years Experience",
                description: "Work experience in iOS",
                type: .experience
            )
        ]
        
        // When
        let careerPath = createCareerPath(requirements: requirements)
        
        // Then
        XCTAssertEqual(careerPath.requirements.count, 2)
        XCTAssertEqual(careerPath.requirements[0].type, .competency)
        XCTAssertEqual(careerPath.requirements[1].type, .experience)
    }
    
    // MARK: - Difficulty Tests
    
    func testCareerPathDifficulty() {
        // Easy path (high success rate)
        let easyPath = createCareerPath(successRate: 0.85)
        XCTAssertEqual(easyPath.difficulty, .easy)
        
        // Moderate path
        let moderatePath = createCareerPath(successRate: 0.65)
        XCTAssertEqual(moderatePath.difficulty, .moderate)
        
        // Hard path (low success rate)
        let hardPath = createCareerPath(successRate: 0.4)
        XCTAssertEqual(hardPath.difficulty, .hard)
    }
    
    // MARK: - Duration Tests
    
    func testCareerPathDuration() {
        XCTAssertEqual(CareerPathDuration.months6.months, 6)
        XCTAssertEqual(CareerPathDuration.year1.months, 12)
        XCTAssertEqual(CareerPathDuration.years2.months, 24)
        XCTAssertEqual(CareerPathDuration.years3.months, 36)
        XCTAssertEqual(CareerPathDuration.years5.months, 60)
        XCTAssertEqual(CareerPathDuration.yearsMore.months, 72)
    }
    
    // MARK: - Success Rate Tests
    
    func testSuccessRateBounds() {
        // Test that success rate is clamped between 0 and 1
        let pathWithHighRate = createCareerPath(successRate: 1.5)
        XCTAssertEqual(pathWithHighRate.successRate, 1.0)
        
        let pathWithLowRate = createCareerPath(successRate: -0.5)
        XCTAssertEqual(pathWithLowRate.successRate, 0.0)
    }
    
    // MARK: - Codable Tests
    
    func testCareerPathEncoding() throws {
        // Given
        let careerPath = createCareerPath(
            requirements: [createRequirement()],
            successRate: 0.75
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(careerPath)
        
        // Then
        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testCareerPathDecoding() throws {
        // Given
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "fromPositionId": "550e8400-e29b-41d4-a716-446655440001",
            "toPositionId": "550e8400-e29b-41d4-a716-446655440002",
            "fromPositionName": "Junior Developer",
            "toPositionName": "Middle Developer",
            "estimatedDuration": "1 год",
            "requirements": [],
            "description": "Career progression path",
            "successRate": 0.8
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let careerPath = try decoder.decode(CareerPath.self, from: json)
        
        // Then
        XCTAssertEqual(careerPath.fromPositionName, "Junior Developer")
        XCTAssertEqual(careerPath.toPositionName, "Middle Developer")
        XCTAssertEqual(careerPath.successRate, 0.8)
    }
    
    // MARK: - Helper Methods
    
    private func createCareerPath(
        id: UUID = UUID(),
        fromPositionId: UUID = UUID(),
        toPositionId: UUID = UUID(),
        fromPositionName: String = "Junior",
        toPositionName: String = "Middle",
        estimatedDuration: CareerPathDuration = .year1,
        requirements: [CareerPathRequirement] = [],
        description: String = "Test Path",
        successRate: Double = 0.7
    ) -> CareerPath {
        return CareerPath(
            id: id,
            fromPositionId: fromPositionId,
            toPositionId: toPositionId,
            fromPositionName: fromPositionName,
            toPositionName: toPositionName,
            estimatedDuration: estimatedDuration,
            requirements: requirements,
            description: description,
            successRate: successRate
        )
    }
    
    private func createRequirement(
        id: UUID = UUID(),
        title: String = "Test Requirement",
        description: String = "Test Description",
        type: RequirementType = .competency,
        isCompleted: Bool = false
    ) -> CareerPathRequirement {
        return CareerPathRequirement(
            id: id,
            title: title,
            description: description,
            type: type,
            isCompleted: isCompleted
        )
    }
}

// MARK: - CareerPathRequirement Tests

final class CareerPathRequirementTests: XCTestCase {
    
    func testRequirementInitialization() {
        // Given
        let id = UUID()
        let title = "iOS Development"
        let description = "Master iOS skills"
        let type = RequirementType.competency
        
        // When
        let requirement = CareerPathRequirement(
            id: id,
            title: title,
            description: description,
            type: type,
            isCompleted: false
        )
        
        // Then
        XCTAssertEqual(requirement.id, id)
        XCTAssertEqual(requirement.title, title)
        XCTAssertEqual(requirement.description, description)
        XCTAssertEqual(requirement.type, type)
        XCTAssertFalse(requirement.isCompleted)
    }
    
    func testRequirementTypes() {
        XCTAssertEqual(RequirementType.competency.rawValue, "Компетенция")
        XCTAssertEqual(RequirementType.experience.rawValue, "Опыт")
        XCTAssertEqual(RequirementType.certification.rawValue, "Сертификация")
        XCTAssertEqual(RequirementType.education.rawValue, "Образование")
        XCTAssertEqual(RequirementType.project.rawValue, "Проект")
        XCTAssertEqual(RequirementType.other.rawValue, "Другое")
    }
    
    func testRequirementTypeIcons() {
        XCTAssertEqual(RequirementType.competency.icon, "star.fill")
        XCTAssertEqual(RequirementType.experience.icon, "clock.fill")
        XCTAssertEqual(RequirementType.certification.icon, "doc.text.fill")
        XCTAssertEqual(RequirementType.education.icon, "graduationcap.fill")
        XCTAssertEqual(RequirementType.project.icon, "folder.fill")
        XCTAssertEqual(RequirementType.other.icon, "ellipsis.circle.fill")
    }
}

// MARK: - CareerPathDifficulty Tests

final class CareerPathDifficultyTests: XCTestCase {
    
    func testDifficultyRawValues() {
        XCTAssertEqual(CareerPathDifficulty.easy.rawValue, "Легкий")
        XCTAssertEqual(CareerPathDifficulty.moderate.rawValue, "Средний")
        XCTAssertEqual(CareerPathDifficulty.hard.rawValue, "Сложный")
    }
    
    func testDifficultyColors() {
        XCTAssertEqual(CareerPathDifficulty.easy.color, .green)
        XCTAssertEqual(CareerPathDifficulty.moderate.color, .orange)
        XCTAssertEqual(CareerPathDifficulty.hard.color, .red)
    }
    
    func testDifficultyIcons() {
        XCTAssertEqual(CareerPathDifficulty.easy.icon, "checkmark.circle.fill")
        XCTAssertEqual(CareerPathDifficulty.moderate.icon, "exclamationmark.circle.fill")
        XCTAssertEqual(CareerPathDifficulty.hard.icon, "xmark.circle.fill")
    }
} 