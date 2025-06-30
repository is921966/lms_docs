//
//  ValueObject.swift
//  LMS
//
//  Created by AI Assistant on 01/31/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

/// Base protocol for all Value Objects in the domain layer
/// Value Objects are immutable and defined by their attributes
public protocol ValueObject: Equatable, Hashable, Codable {
    associatedtype Value: Equatable
    
    /// The underlying value
    var value: Value { get }
    
    /// Validates the value before creation
    /// - Parameter value: The value to validate
    /// - Returns: true if valid, false otherwise
    static func isValid(_ value: Value) -> Bool
}

// MARK: - Common Extensions

public extension ValueObject {
    /// Default hash implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

// MARK: - String-based Value Object

/// Base protocol for string-based value objects
public protocol StringValueObject: ValueObject where Value == String {
    /// Minimum allowed length
    static var minLength: Int { get }
    
    /// Maximum allowed length
    static var maxLength: Int { get }
    
    /// Pattern for validation (optional)
    static var pattern: String? { get }
}

public extension StringValueObject {
    static func isValid(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check length
        guard trimmed.count >= minLength && trimmed.count <= maxLength else {
            return false
        }
        
        // Check pattern if provided
        if let pattern = pattern {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: trimmed.utf16.count)
            return regex?.firstMatch(in: trimmed, options: [], range: range) != nil
        }
        
        return true
    }
}

// MARK: - Numeric Value Object

/// Base protocol for numeric value objects
public protocol NumericValueObject: ValueObject where Value: Numeric & Comparable {
    /// Minimum allowed value
    static var minValue: Value { get }
    
    /// Maximum allowed value
    static var maxValue: Value { get }
}

public extension NumericValueObject {
    static func isValid(_ value: Value) -> Bool {
        return value >= minValue && value <= maxValue
    }
}

// MARK: - Percentage Value Object

/// Special case for percentage values (0-100)
public struct Percentage: NumericValueObject {
    public let value: Double
    
    public static let minValue: Double = 0.0
    public static let maxValue: Double = 100.0
    
    public init?(_ value: Double) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Formatted string representation
    public var formatted: String {
        return "\(Int(value.rounded()))%"
    }
    
    /// Check if percentage represents completion
    public var isComplete: Bool {
        return value >= 100.0
    }
    
    /// Check if percentage represents zero progress
    public var isEmpty: Bool {
        return value == 0.0
    }
}

// MARK: - NonEmptyString

/// A string that cannot be empty
public struct NonEmptyString: StringValueObject {
    public let value: String
    
    public static let minLength: Int = 1
    public static let maxLength: Int = Int.max
    public static let pattern: String? = nil
    
    public init?(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isValid(trimmed) else { return nil }
        self.value = trimmed
    }
} 