//
//  EmailValidator.swift
//  LMSTests
//
//  Created by AI Assistant on 04/07/25.
//

import Foundation

// Test implementation of EmailValidator
// Renamed to TestEmailValidator to avoid naming conflicts
struct TestEmailValidator {
    
    // Basic email validation
    static func isValid(_ email: String) -> Bool {
        // Basic regex for email validation
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Validate multiple emails
    static func validateEmails(_ emails: [String]) -> [String: Bool] {
        return emails.reduce(into: [:]) { result, email in
            result[email] = isValid(email)
        }
    }
    
    // Extract domain from email
    static func extractDomain(from email: String) -> String? {
        guard isValid(email) else { return nil }
        let components = email.split(separator: "@")
        return components.count == 2 ? String(components[1]) : nil
    }
    
    // Check if email is from allowed domain
    static func isFromAllowedDomain(_ email: String, allowedDomains: [String]) -> Bool {
        guard let domain = extractDomain(from: email) else { return false }
        return allowedDomains.contains(domain)
    }
    
    // Normalize email (lowercase, trim whitespace)
    static func normalize(_ email: String) -> String {
        return email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    static func validate(_ email: String) throws {
        guard !email.isEmpty else {
            throw ValidationError.empty
        }
        
        guard isValid(email) else {
            throw ValidationError.invalidFormat
        }
    }
    
    enum ValidationError: LocalizedError {
        case empty
        case invalidFormat
        
        var errorDescription: String? {
            switch self {
            case .empty:
                return "Email cannot be empty"
            case .invalidFormat:
                return "Invalid email format"
            }
        }
    }
} 