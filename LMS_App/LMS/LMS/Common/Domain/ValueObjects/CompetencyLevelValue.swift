//
//  CompetencyLevelValue.swift
//  LMS
//
//  Created by AI Assistant on 04/07/25.
//

import Foundation

/// Value object representing competency level
struct CompetencyLevelValue: Equatable, Comparable, Codable, Hashable {
    let level: Int
    
    // Predefined levels
    static let novice = CompetencyLevelValue(level: 1)!
    static let beginner = CompetencyLevelValue(level: 2)!
    static let intermediate = CompetencyLevelValue(level: 3)!
    static let advanced = CompetencyLevelValue(level: 4)!
    static let expert = CompetencyLevelValue(level: 5)!
    
    init?(level: Int) {
        guard level >= 1 && level <= 5 else { return nil }
        self.level = level
    }
    
    // MARK: - Comparable
    
    static func < (lhs: CompetencyLevelValue, rhs: CompetencyLevelValue) -> Bool {
        lhs.level < rhs.level
    }
    
    // MARK: - Convenience Methods
    
    func isHigherThan(_ other: CompetencyLevelValue) -> Bool {
        self > other
    }
    
    var numericValue: Int {
        level
    }
    
    var nextLevel: CompetencyLevelValue? {
        CompetencyLevelValue(level: level + 1)
    }
    
    var displayName: String {
        switch level {
        case 1: return "Новичок"
        case 2: return "Начинающий"
        case 3: return "Средний"
        case 4: return "Продвинутый"
        case 5: return "Эксперт"
        default: return "Неизвестный"
        }
    }
    
    var requiredProgress: Double {
        switch level {
        case 1: return 0.0
        case 2: return 20.0
        case 3: return 40.0
        case 4: return 70.0
        case 5: return 90.0
        default: return 0.0
        }
    }
} 