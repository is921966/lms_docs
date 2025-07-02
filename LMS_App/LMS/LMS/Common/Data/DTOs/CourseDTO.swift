//
//  CourseDTO.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Course DTO

/// Data Transfer Object for Course entity
public struct CourseDTO: DataTransferObject {
    public let id: String
    public let title: String
    public let description: String
    public let shortDescription: String?
    public let imageUrl: String?
    public let category: String
    public let difficulty: String
    public let duration: Int // Duration in minutes
    public let language: String
    public let price: Double?
    public let currency: String?
    public let isPublished: Bool
    public let isFree: Bool
    public let enrollmentCount: Int
    public let rating: Double?
    public let reviewCount: Int
    public let instructorId: String
    public let instructorName: String
    public let tags: [String]
    public let prerequisites: [String]
    public let learningOutcomes: [String]
    public let createdAt: String // ISO 8601 date string
    public let updatedAt: String // ISO 8601 date string
    public let publishedAt: String? // ISO 8601 date string
    
    public init(
        id: String,
        title: String,
        description: String,
        shortDescription: String? = nil,
        imageUrl: String? = nil,
        category: String,
        difficulty: String,
        duration: Int,
        language: String = "ru",
        price: Double? = nil,
        currency: String? = nil,
        isPublished: Bool = false,
        isFree: Bool = true,
        enrollmentCount: Int = 0,
        rating: Double? = nil,
        reviewCount: Int = 0,
        instructorId: String,
        instructorName: String,
        tags: [String] = [],
        prerequisites: [String] = [],
        learningOutcomes: [String] = [],
        createdAt: String,
        updatedAt: String,
        publishedAt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.shortDescription = shortDescription
        self.imageUrl = imageUrl
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.language = language
        self.price = price
        self.currency = currency
        self.isPublished = isPublished
        self.isFree = isFree
        self.enrollmentCount = enrollmentCount
        self.rating = rating
        self.reviewCount = reviewCount
        self.instructorId = instructorId
        self.instructorName = instructorName
        self.tags = tags
        self.prerequisites = prerequisites
        self.learningOutcomes = learningOutcomes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        // Basic field validation
        if id.isEmpty {
            errors.append("Course ID cannot be empty")
        }
        
        if title.isEmpty {
            errors.append("Course title cannot be empty")
        } else if title.count > 200 {
            errors.append("Course title cannot exceed 200 characters")
        }
        
        if description.isEmpty {
            errors.append("Course description cannot be empty")
        } else if description.count > 5000 {
            errors.append("Course description cannot exceed 5000 characters")
        }
        
        if category.isEmpty {
            errors.append("Course category cannot be empty")
        }
        
        // Difficulty validation
        let validDifficulties = ["beginner", "intermediate", "advanced", "expert"]
        if !validDifficulties.contains(difficulty.lowercased()) {
            errors.append("Invalid difficulty: \(difficulty). Must be one of: \(validDifficulties.joined(separator: ", "))")
        }
        
        // Duration validation
        if duration <= 0 {
            errors.append("Course duration must be greater than 0 minutes")
        } else if duration > 10080 { // 1 week in minutes
            errors.append("Course duration cannot exceed 1 week (10080 minutes)")
        }
        
        // Language validation
        let validLanguages = ["ru", "en", "es", "fr", "de"]
        if !validLanguages.contains(language.lowercased()) {
            errors.append("Invalid language: \(language). Must be one of: \(validLanguages.joined(separator: ", "))")
        }
        
        // Price validation
        if let price = price {
            if price < 0 {
                errors.append("Course price cannot be negative")
            }
            
            if !isFree && price == 0 {
                errors.append("Paid course must have price greater than 0")
            }
            
            if isFree && price > 0 {
                errors.append("Free course cannot have a price")
            }
            
            // Currency validation for paid courses
            if price > 0 && (currency == nil || currency!.isEmpty) {
                errors.append("Currency is required for paid courses")
            }
        }
        
        // Enrollment validation
        if enrollmentCount < 0 {
            errors.append("Enrollment count cannot be negative")
        }
        
        // Rating validation
        if let rating = rating {
            if rating < 0 || rating > 5 {
                errors.append("Rating must be between 0 and 5")
            }
        }
        
        // Review count validation
        if reviewCount < 0 {
            errors.append("Review count cannot be negative")
        }
        
        // Instructor validation
        if instructorId.isEmpty {
            errors.append("Instructor ID cannot be empty")
        }
        
        if instructorName.isEmpty {
            errors.append("Instructor name cannot be empty")
        }
        
        // Image URL validation
        if let imageUrl = imageUrl, !imageUrl.isEmpty, !isValidURL(imageUrl) {
            errors.append("Course image URL is invalid")
        }
        
        // Date validation
        if !isValidISO8601Date(createdAt) {
            errors.append("Created date format is invalid")
        }
        
        if !isValidISO8601Date(updatedAt) {
            errors.append("Updated date format is invalid")
        }
        
        if let publishedAt = publishedAt, !isValidISO8601Date(publishedAt) {
            errors.append("Published date format is invalid")
        }
        
        // Business logic validation
        if isPublished && publishedAt == nil {
            errors.append("Published course must have published date")
        }
        
        return errors
    }
    
    // MARK: - Private Validation Methods
    
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
    
    private func isValidISO8601Date(_ dateString: String) -> Bool {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) != nil
    }
}

// MARK: - Course Summary DTO

/// Simplified DTO for course listing
public struct CourseSummaryDTO: DataTransferObject {
    public let id: String
    public let title: String
    public let shortDescription: String?
    public let imageUrl: String?
    public let category: String
    public let difficulty: String
    public let duration: Int
    public let rating: Double?
    public let enrollmentCount: Int
    public let isFree: Bool
    public let price: Double?
    public let currency: String?
    public let instructorName: String
    
    public init(
        id: String,
        title: String,
        shortDescription: String? = nil,
        imageUrl: String? = nil,
        category: String,
        difficulty: String,
        duration: Int,
        rating: Double? = nil,
        enrollmentCount: Int = 0,
        isFree: Bool = true,
        price: Double? = nil,
        currency: String? = nil,
        instructorName: String
    ) {
        self.id = id
        self.title = title
        self.shortDescription = shortDescription
        self.imageUrl = imageUrl
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.rating = rating
        self.enrollmentCount = enrollmentCount
        self.isFree = isFree
        self.price = price
        self.currency = currency
        self.instructorName = instructorName
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if id.isEmpty {
            errors.append("Course ID cannot be empty")
        }
        
        if title.isEmpty {
            errors.append("Course title cannot be empty")
        }
        
        if category.isEmpty {
            errors.append("Course category cannot be empty")
        }
        
        if instructorName.isEmpty {
            errors.append("Instructor name cannot be empty")
        }
        
        return errors
    }
}

// MARK: - Create Course DTO

/// DTO for creating new courses
public struct CreateCourseDTO: DataTransferObject {
    public let title: String
    public let description: String
    public let shortDescription: String?
    public let category: String
    public let difficulty: String
    public let duration: Int
    public let language: String
    public let price: Double?
    public let currency: String?
    public let isFree: Bool
    public let tags: [String]
    public let prerequisites: [String]
    public let learningOutcomes: [String]
    
    public init(
        title: String,
        description: String,
        shortDescription: String? = nil,
        category: String,
        difficulty: String,
        duration: Int,
        language: String = "ru",
        price: Double? = nil,
        currency: String? = nil,
        isFree: Bool = true,
        tags: [String] = [],
        prerequisites: [String] = [],
        learningOutcomes: [String] = []
    ) {
        self.title = title
        self.description = description
        self.shortDescription = shortDescription
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.language = language
        self.price = price
        self.currency = currency
        self.isFree = isFree
        self.tags = tags
        self.prerequisites = prerequisites
        self.learningOutcomes = learningOutcomes
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if title.isEmpty {
            errors.append("Course title cannot be empty")
        }
        
        if description.isEmpty {
            errors.append("Course description cannot be empty")
        }
        
        if category.isEmpty {
            errors.append("Course category cannot be empty")
        }
        
        if difficulty.isEmpty {
            errors.append("Course difficulty cannot be empty")
        }
        
        if duration <= 0 {
            errors.append("Course duration must be greater than 0")
        }
        
        // Price validation
        if let price = price {
            if price < 0 {
                errors.append("Course price cannot be negative")
            }
            
            if !isFree && price == 0 {
                errors.append("Paid course must have price greater than 0")
            }
        }
        
        return errors
    }
}

// MARK: - Course Progress DTO

/// DTO for course enrollment and progress
public struct CourseProgressDTO: DataTransferObject {
    public let courseId: String
    public let userId: String
    public let enrolledAt: String
    public let lastAccessedAt: String?
    public let completedAt: String?
    public let progressPercentage: Double
    public let completedLessons: Int
    public let totalLessons: Int
    public let timeSpentMinutes: Int
    public let certificateIssued: Bool
    
    public init(
        courseId: String,
        userId: String,
        enrolledAt: String,
        lastAccessedAt: String? = nil,
        completedAt: String? = nil,
        progressPercentage: Double = 0.0,
        completedLessons: Int = 0,
        totalLessons: Int,
        timeSpentMinutes: Int = 0,
        certificateIssued: Bool = false
    ) {
        self.courseId = courseId
        self.userId = userId
        self.enrolledAt = enrolledAt
        self.lastAccessedAt = lastAccessedAt
        self.completedAt = completedAt
        self.progressPercentage = progressPercentage
        self.completedLessons = completedLessons
        self.totalLessons = totalLessons
        self.timeSpentMinutes = timeSpentMinutes
        self.certificateIssued = certificateIssued
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if courseId.isEmpty {
            errors.append("Course ID cannot be empty")
        }
        
        if userId.isEmpty {
            errors.append("User ID cannot be empty")
        }
        
        if progressPercentage < 0 || progressPercentage > 100 {
            errors.append("Progress percentage must be between 0 and 100")
        }
        
        if completedLessons < 0 {
            errors.append("Completed lessons cannot be negative")
        }
        
        if totalLessons < 0 {
            errors.append("Total lessons cannot be negative")
        }
        
        if completedLessons > totalLessons {
            errors.append("Completed lessons cannot exceed total lessons")
        }
        
        if timeSpentMinutes < 0 {
            errors.append("Time spent cannot be negative")
        }
        
        return errors
    }
} 