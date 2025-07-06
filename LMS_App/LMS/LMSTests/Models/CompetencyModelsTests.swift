//
//  CompetencyModelsTests.swift
//  LMSTests
//
//  Created on 12/07/2025.
//

import XCTest
@testable import LMS

final class CompetencyModelsTests: XCTestCase {
    
    private var encoder: JSONEncoder!
    private var decoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    override func tearDown() {
        encoder = nil
        decoder = nil
        super.tearDown()
    }
    
    // MARK: - Request Models Tests
    
    func testCompetencyFiltersEncoding() throws {
        // Given
        let filters = CompetencyFilters(
            category: "Technical",
            type: "Hard Skill",
            search: "Swift",
            isActive: true
        )
        
        // When
        let data = try encoder.encode(filters)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["category"] as? String, "Technical")
        XCTAssertEqual(json?["type"] as? String, "Hard Skill")
        XCTAssertEqual(json?["search"] as? String, "Swift")
        XCTAssertEqual(json?["isActive"] as? Bool, true)
    }
    
    func testCompetencyFiltersWithNilValues() throws {
        // Given
        let filters = CompetencyFilters(
            category: nil,
            type: nil,
            search: nil,
            isActive: nil
        )
        
        // When
        let data = try encoder.encode(filters)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertTrue(json?.isEmpty ?? false)
    }
    
    func testCreateCompetencyRequestEncoding() throws {
        // Given
        let levels = [
            CreateCompetencyLevelRequest(
                level: 1,
                name: "Beginner",
                description: "Basic understanding",
                criteria: ["Can read code", "Understands basics"]
            ),
            CreateCompetencyLevelRequest(
                level: 2,
                name: "Intermediate",
                description: "Working knowledge",
                criteria: ["Can write code", "Follows best practices"]
            )
        ]
        
        let request = CreateCompetencyRequest(
            name: "Swift Development",
            description: "iOS development with Swift",
            category: "Technical",
            type: "Hard Skill",
            levels: levels
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["name"] as? String, "Swift Development")
        XCTAssertEqual(json?["description"] as? String, "iOS development with Swift")
        XCTAssertEqual(json?["category"] as? String, "Technical")
        XCTAssertEqual(json?["type"] as? String, "Hard Skill")
        
        let levelsArray = json?["levels"] as? [[String: Any]]
        XCTAssertEqual(levelsArray?.count, 2)
        XCTAssertEqual(levelsArray?[0]["level"] as? Int, 1)
        XCTAssertEqual(levelsArray?[1]["level"] as? Int, 2)
    }
    
    func testUpdateCompetencyRequestEncoding() throws {
        // Given
        let request = UpdateCompetencyRequest(
            name: "Updated Name",
            description: nil,
            category: "Business",
            type: nil,
            isActive: false
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["name"] as? String, "Updated Name")
        XCTAssertNil(json?["description"])
        XCTAssertEqual(json?["category"] as? String, "Business")
        XCTAssertNil(json?["type"])
        XCTAssertEqual(json?["isActive"] as? Bool, false)
    }
    
    func testCompetencyAssignmentRequestEncoding() throws {
        // Given
        let deadline = Date()
        let request = CompetencyAssignmentRequest(
            competencyId: "comp-123",
            userId: "user-456",
            targetLevel: 3,
            deadline: deadline
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["competencyId"] as? String, "comp-123")
        XCTAssertEqual(json?["userId"] as? String, "user-456")
        XCTAssertEqual(json?["targetLevel"] as? Int, 3)
        XCTAssertNotNil(json?["deadline"])
    }
    
    // MARK: - Response Models Tests
    
    func testCompetenciesResponseDecoding() throws {
        // Given
        let json = """
        {
            "competencies": [
                {
                    "id": "1",
                    "name": "Swift",
                    "description": "Swift programming",
                    "category": {
                        "id": "cat-1",
                        "name": "Technical",
                        "description": "Technical skills"
                    },
                    "type": "Hard Skill",
                    "levels": [],
                    "isActive": true,
                    "createdAt": "2025-01-01T00:00:00Z",
                    "updatedAt": "2025-01-01T00:00:00Z"
                }
            ],
            "pagination": {
                "page": 1,
                "limit": 10,
                "total": 1,
                "total_pages": 1
            }
        }
        """.data(using: .utf8)!
        
        // When
        let response = try decoder.decode(CompetenciesResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.competencies.count, 1)
        XCTAssertEqual(response.competencies[0].name, "Swift")
        XCTAssertEqual(response.pagination.total, 1)
    }
    
    func testCompetencyResponseDecoding() throws {
        // Given
        let json = """
        {
            "id": "comp-123",
            "name": "Leadership",
            "description": "Leadership skills",
            "category": {
                "id": "cat-2",
                "name": "Soft Skills",
                "description": "Interpersonal skills"
            },
            "type": "Soft Skill",
            "levels": [
                {
                    "id": "level-1",
                    "level": 1,
                    "name": "Basic",
                    "description": "Basic leadership",
                    "criteria": ["Can lead small teams", "Basic communication"]
                }
            ],
            "isActive": true,
            "createdAt": "2025-01-01T00:00:00Z",
            "updatedAt": "2025-01-02T00:00:00Z"
        }
        """.data(using: .utf8)!
        
        // When
        let competency = try decoder.decode(CompetencyResponse.self, from: json)
        
        // Then
        XCTAssertEqual(competency.id, "comp-123")
        XCTAssertEqual(competency.name, "Leadership")
        XCTAssertEqual(competency.description, "Leadership skills")
        XCTAssertEqual(competency.category.name, "Soft Skills")
        XCTAssertEqual(competency.type, "Soft Skill")
        XCTAssertEqual(competency.levels.count, 1)
        XCTAssertEqual(competency.levels[0].level, 1)
        XCTAssertEqual(competency.levels[0].criteria.count, 2)
        XCTAssertTrue(competency.isActive)
    }
    
    func testUserCompetencyResponseDecoding() throws {
        // Given
        let json = """
        {
            "id": "user-comp-123",
            "competency": {
                "id": "comp-456",
                "name": "Project Management",
                "description": "PM skills",
                "category": {
                    "id": "cat-3",
                    "name": "Management",
                    "description": "Management skills"
                },
                "type": "Hard Skill",
                "levels": [],
                "isActive": true,
                "createdAt": "2025-01-01T00:00:00Z",
                "updatedAt": "2025-01-01T00:00:00Z"
            },
            "currentLevel": 2,
            "targetLevel": 4,
            "progress": 0.5,
            "assessments": [
                {
                    "id": "assess-1",
                    "level": 2,
                    "score": 85.5,
                    "assessedBy": "Manager",
                    "assessedAt": "2025-01-15T00:00:00Z",
                    "comments": "Good progress"
                }
            ],
            "deadline": "2025-12-31T23:59:59Z"
        }
        """.data(using: .utf8)!
        
        // When
        let userCompetency = try decoder.decode(UserCompetencyResponse.self, from: json)
        
        // Then
        XCTAssertEqual(userCompetency.id, "user-comp-123")
        XCTAssertEqual(userCompetency.competency.name, "Project Management")
        XCTAssertEqual(userCompetency.currentLevel, 2)
        XCTAssertEqual(userCompetency.targetLevel, 4)
        XCTAssertEqual(userCompetency.progress, 0.5)
        XCTAssertEqual(userCompetency.assessments.count, 1)
        XCTAssertEqual(userCompetency.assessments[0].score, 85.5)
        XCTAssertNotNil(userCompetency.deadline)
    }
    
    func testCompetencyAssessmentResponseDecoding() throws {
        // Given
        let json = """
        {
            "id": "assess-789",
            "level": 3,
            "score": 92.0,
            "assessedBy": "Senior Manager",
            "assessedAt": "2025-02-01T14:30:00Z",
            "comments": null
        }
        """.data(using: .utf8)!
        
        // When
        let assessment = try decoder.decode(CompetencyAssessmentResponse.self, from: json)
        
        // Then
        XCTAssertEqual(assessment.id, "assess-789")
        XCTAssertEqual(assessment.level, 3)
        XCTAssertEqual(assessment.score, 92.0)
        XCTAssertEqual(assessment.assessedBy, "Senior Manager")
        XCTAssertNil(assessment.comments)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyLevelsArray() throws {
        // Given
        let request = CreateCompetencyRequest(
            name: "Empty Levels",
            description: "No levels",
            category: "Test",
            type: "Test",
            levels: []
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        let levelsArray = json?["levels"] as? [[String: Any]]
        XCTAssertNotNil(levelsArray)
        XCTAssertTrue(levelsArray?.isEmpty ?? false)
    }
    
    func testEmptyCriteriaArray() throws {
        // Given
        let level = CreateCompetencyLevelRequest(
            level: 1,
            name: "Empty",
            description: "No criteria",
            criteria: []
        )
        
        // When
        let data = try encoder.encode(level)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        let criteriaArray = json?["criteria"] as? [String]
        XCTAssertNotNil(criteriaArray)
        XCTAssertTrue(criteriaArray?.isEmpty ?? false)
    }
    
    func testDecodingWithMissingOptionalFields() throws {
        // Given - minimal UserCompetencyResponse without deadline
        let json = """
        {
            "id": "minimal",
            "competency": {
                "id": "comp-min",
                "name": "Minimal",
                "description": "Min desc",
                "category": {
                    "id": "cat-min",
                    "name": "Min Category",
                    "description": "Min cat desc"
                },
                "type": "Minimal",
                "levels": [],
                "isActive": false,
                "createdAt": "2025-01-01T00:00:00Z",
                "updatedAt": "2025-01-01T00:00:00Z"
            },
            "currentLevel": 0,
            "targetLevel": 1,
            "progress": 0.0,
            "assessments": []
        }
        """.data(using: .utf8)!
        
        // When
        let userCompetency = try decoder.decode(UserCompetencyResponse.self, from: json)
        
        // Then
        XCTAssertNil(userCompetency.deadline)
        XCTAssertTrue(userCompetency.assessments.isEmpty)
    }
} 