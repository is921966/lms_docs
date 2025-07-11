//
//  ContactInfo.swift
//  LMS
//
//  Created by AI Assistant on 01/31/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Email

/// Email address value object with validation
public struct Email: StringValueObject {
    public let value: String
    
    public static let minLength: Int = 3
    public static let maxLength: Int = 254 // RFC 5321
    // More comprehensive email regex that requires proper TLD
    public static let pattern: String? = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    
    public init?(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()
        
        // Additional validation checks
        guard !lowercased.isEmpty,
              lowercased.contains("@"),
              !lowercased.hasPrefix("@"),
              !lowercased.hasSuffix("@"),
              !lowercased.contains("@."),
              !lowercased.contains(".@"),
              !lowercased.contains(".."),
              !lowercased.contains(" ") else { return nil }
        
        // Check that domain has at least one dot after @
        let parts = lowercased.split(separator: "@")
        guard parts.count == 2 else { return nil }
        let domainPart = String(parts[1])
        guard domainPart.contains("."),
              !domainPart.hasPrefix("."),
              !domainPart.hasSuffix(".") else { return nil }
        
        guard Self.isValid(lowercased) else { return nil }
        self.value = lowercased
    }
    
    /// Domain part of the email
    public var domain: String {
        return value.split(separator: "@").last.map(String.init) ?? ""
    }
    
    /// Local part of the email (before @)
    public var localPart: String {
        return value.split(separator: "@").first.map(String.init) ?? ""
    }
    
    /// Check if email is from a specific domain
    public func isFromDomain(_ domain: String) -> Bool {
        return self.domain.lowercased() == domain.lowercased()
    }
}

// MARK: - PhoneNumber

/// Phone number value object with validation
public struct PhoneNumber: StringValueObject {
    public let value: String
    
    public static let minLength: Int = 10
    public static let maxLength: Int = 15
    public static let pattern: String? = "^\\+?[0-9]{10,15}$"
    
    /// The original input before normalization
    private let originalValue: String
    
    public init?(_ value: String) {
        self.originalValue = value
        
        // Normalize: remove all non-numeric characters except leading +
        let normalized = Self.normalize(value)
        guard Self.isValid(normalized) else { return nil }
        self.value = normalized
    }
    
    /// Normalize phone number by removing non-numeric characters
    private static func normalize(_ value: String) -> String {
        var normalized = value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Preserve leading + if present
        if value.hasPrefix("+") {
            normalized = "+" + normalized
        }
        
        return normalized
    }
    
    /// Format phone number for display
    public var formatted: String {
        // Russian format example: +7 (999) 123-45-67
        if value.hasPrefix("+7") && value.count == 12 {
            let digits = value.dropFirst(2)
            let areaCode = digits.prefix(3)
            let firstPart = digits.dropFirst(3).prefix(3)
            let secondPart = digits.dropFirst(6).prefix(2)
            let thirdPart = digits.dropFirst(8).prefix(2)
            return "+7 (\(areaCode)) \(firstPart)-\(secondPart)-\(thirdPart)"
        }
        
        // US format example: +1 (555) 123-4567
        if value.hasPrefix("+1") && value.count == 12 {
            let digits = value.dropFirst(2)
            let areaCode = digits.prefix(3)
            let firstPart = digits.dropFirst(3).prefix(3)
            let secondPart = digits.dropFirst(6).prefix(4)
            return "+1 (\(areaCode)) \(firstPart)-\(secondPart)"
        }
        
        // Default: return as is
        return value
    }
    
    /// Check if this is a mobile number (simplified check)
    public var isMobile: Bool {
        // Russian mobile prefixes
        if value.hasPrefix("+79") {
            return true
        }
        
        // Add more country-specific logic as needed
        return false
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
        // Compare only normalized values, not original input
        return lhs.value == rhs.value
    }
}

// MARK: - URL Value Object

/// URL value object with validation
public struct URLValue: ValueObject {
    public let value: URL
    
    public init?(_ string: String) {
        guard let url = URL(string: string),
              Self.isValid(url) else { return nil }
        self.value = url
    }
    
    public init?(_ url: URL) {
        guard Self.isValid(url) else { return nil }
        self.value = url
    }
    
    public static func isValid(_ value: URL) -> Bool {
        // Must have scheme
        guard let scheme = value.scheme else { return false }
        
        // Only allow http(s)
        guard ["http", "https"].contains(scheme.lowercased()) else { return false }
        
        // Must have host
        guard value.host != nil else { return false }
        
        return true
    }
    
    /// Check if URL is secure (https)
    public var isSecure: Bool {
        return value.scheme?.lowercased() == "https"
    }
} 