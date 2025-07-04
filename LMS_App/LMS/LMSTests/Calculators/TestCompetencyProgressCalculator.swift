//
//  TestCompetencyProgressCalculator.swift
//  LMSTests
//
//  Created by AI Assistant on 04/07/25.
//

import Foundation

// Test implementation of CompetencyProgressCalculator
// Renamed to TestCompetencyProgressCalculator to avoid naming conflicts
class TestCompetencyProgressCalculator {
    
    // Calculate progress percentage based on completed vs total items
    static func calculateProgress(completed: Int, total: Int) -> Double {
        guard total > 0 else { return 0.0 }
        let progress = Double(completed) / Double(total) * 100.0
        return min(max(progress, 0.0), 100.0) // Ensure between 0-100
    }
    
    // Calculate weighted progress based on item importance
    static func calculateWeightedProgress(items: [(completed: Bool, weight: Double)]) -> Double {
        let totalWeight = items.reduce(0.0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0.0 }
        
        let completedWeight = items
            .filter { $0.completed }
            .reduce(0.0) { $0 + $1.weight }
        
        return (completedWeight / totalWeight) * 100.0
    }
    
    // Calculate level based on progress
    static func calculateLevel(progress: Double) -> String {
        switch progress {
        case 0..<20:
            return "beginner"
        case 20..<40:
            return "elementary"
        case 40..<60:
            return "intermediate"
        case 60..<80:
            return "advanced"
        case 80...100:
            return "expert"
        default:
            return "unknown"
        }
    }
    
    // Calculate estimated time to complete
    static func estimateTimeToComplete(
        totalItems: Int,
        completedItems: Int,
        averageTimePerItem: TimeInterval
    ) -> TimeInterval {
        let remainingItems = max(0, totalItems - completedItems)
        return Double(remainingItems) * averageTimePerItem
    }
}
