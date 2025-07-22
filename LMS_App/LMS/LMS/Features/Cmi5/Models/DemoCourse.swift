//
//  DemoCourse.swift
//  LMS
//
//  Created on 12/07/2025.
//

import Foundation

/// Model representing a demo Cmi5 course
struct DemoCourse: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let filename: String
    let type: CourseType
    let language: String
    
    enum CourseType: String, CaseIterable {
        case singleAU = "Single AU"
        case masteryScore = "Mastery Score"
        case multiAU = "Multiple AU"
        case prePostTest = "Pre/Post Test"
        
        var icon: String {
            switch self {
            case .singleAU: return "doc.text"
            case .masteryScore: return "checkmark.seal"
            case .multiAU: return "square.stack.3d.up"
            case .prePostTest: return "list.bullet.clipboard"
            }
        }
    }
}

// MARK: - Demo Courses Data
extension DemoCourse {
    static let allCourses: [DemoCourse] = [
        // AI Fluency курс (русский)
        DemoCourse(
            name: "AI Fluency: Эффективное взаимодействие с ИИ",
            description: "Комплексный курс по работе с искусственным интеллектом. 4 модуля, 16 активностей. Включает практические упражнения и тесты.",
            filename: "ai_fluency_course_v1.0",
            type: .multiAU,
            language: "Русский"
        ),
        
        // CATAPULT примеры (английский)
        DemoCourse(
            name: "Basic Geology Course",
            description: "Simple single AU course about geology with video content and quiz. Demonstrates basic cmi5 functionality.",
            filename: "single_au_basic_responsive",
            type: .singleAU,
            language: "English"
        ),
        
        DemoCourse(
            name: "Geology Quiz with Mastery Score",
            description: "Course with quiz requiring 30% passing score. Demonstrates mastery score and multiple interactions.",
            filename: "masteryscore_responsive",
            type: .masteryScore,
            language: "English"
        ),
        
        DemoCourse(
            name: "Multi-Module Geology Course",
            description: "Complex course with multiple AUs at top level. Each module has different moveOn criteria.",
            filename: "multi_au_framed",
            type: .multiAU,
            language: "English"
        ),
        
        DemoCourse(
            name: "Geology with Pre/Post Tests",
            description: "Course structure with pre-test, content, and post-test for each block. Demonstrates cmi5 extensions.",
            filename: "pre_post_test_framed",
            type: .prePostTest,
            language: "English"
        )
    ]
} 