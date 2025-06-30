//
//  Certificate.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI

// MARK: - Certificate Template
struct CertificateTemplate: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var backgroundImageName: String?
    var logoImageName: String?
    var primaryColor: String
    var secondaryColor: String
    var fontName: String
    var signatureImageName: String?
    var signerName: String
    var signerTitle: String
    var organizationName: String
    var isActive: Bool = true
    var createdAt = Date()
    var updatedAt = Date()

    // Text templates with placeholders
    var titleTemplate: String = "Сертификат о прохождении курса"
    var bodyTemplate: String = "Настоящим подтверждается, что {userName} успешно прошел(а) курс \"{courseName}\" с результатом {score}%"
    var footerTemplate: String = "Дата выдачи: {date}"

    // Computed properties
    var primarySwiftUIColor: Color {
        Color(hex: primaryColor) ?? .blue
    }

    var secondarySwiftUIColor: Color {
        Color(hex: secondaryColor) ?? .gray
    }
}

// MARK: - Certificate
struct Certificate: Identifiable, Codable {
    let id = UUID()
    let userId: UUID
    let courseId: UUID
    let templateId: UUID
    let certificateNumber: String

    // Course data (denormalized for display)
    let courseName: String
    let courseDescription: String
    let courseDuration: String

    // User data (denormalized for display)
    let userName: String
    let userEmail: String

    // Achievement data
    let completedAt: Date
    let score: Double
    let totalScore: Double
    let percentage: Double
    let isPassed: Bool

    // Certificate data
    let issuedAt: Date
    let expiresAt: Date?
    let verificationCode: String
    let pdfUrl: String?

    // Metadata
    var isRevoked: Bool = false
    var revokedAt: Date?
    var revokedReason: String?

    // Computed properties
    var isValid: Bool {
        if isRevoked { return false }
        if let expires = expiresAt, Date() > expires { return false }
        return true
    }

    var formattedCertificateNumber: String {
        "CERT-\(certificateNumber)"
    }

    var shareText: String {
        "Я успешно прошел курс \"\(courseName)\" в ЦУМ с результатом \(Int(percentage))%! 🎉"
    }

    // Generate verification code
    static func generateVerificationCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in letters.randomElement()! })
    }

    // Generate certificate number
    static func generateCertificateNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        let randomNum = String(format: "%04d", Int.random(in: 0...9_999))
        return "\(dateString)-\(randomNum)"
    }
}

// MARK: - Certificate Generation Request
struct CertificateGenerationRequest {
    let userId: UUID
    let courseId: UUID
    let templateId: UUID
    let courseName: String
    let courseDescription: String
    let courseDuration: String
    let userName: String
    let userEmail: String
    let score: Double
    let totalScore: Double
    let completedAt: Date
}

// MARK: - Mock Certificate Templates
extension CertificateTemplate {
    static let mockTemplates = [
        CertificateTemplate(
            name: "Стандартный сертификат",
            description: "Базовый шаблон для всех курсов",
            primaryColor: "#2196F3",
            secondaryColor: "#757575",
            fontName: "SF Pro Display",
            signerName: "Иван Иванов",
            signerTitle: "Директор по обучению",
            organizationName: "ЦУМ"
        ),
        CertificateTemplate(
            name: "Премиум сертификат",
            description: "Для специальных курсов и программ",
            backgroundImageName: "certificate_premium_bg",
            primaryColor: "#FFD700",
            secondaryColor: "#B8860B",
            fontName: "SF Pro Display",
            signerName: "Мария Петрова",
            signerTitle: "HR Директор",
            organizationName: "ЦУМ"
        ),
        CertificateTemplate(
            name: "Сертификат достижения",
            description: "Для курсов с высоким проходным баллом",
            primaryColor: "#4CAF50",
            secondaryColor: "#2E7D32",
            fontName: "SF Pro Display",
            signerName: "Алексей Сидоров",
            signerTitle: "Руководитель учебного центра",
            organizationName: "ЦУМ"
        )
    ]
}
