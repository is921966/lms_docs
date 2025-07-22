//
//  Student.swift
//  LMS
//
//  Created on Sprint 40 - Course Management Enhancement
//

import Foundation

struct Student: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let position: String?
    let department: String?
    let enrolledCourses: [UUID]
    let completedCourses: [UUID]
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first ?? Character(" ")
        let lastInitial = components.count > 1 ? components[1].first ?? Character(" ") : Character(" ")
        return String(firstInitial) + String(lastInitial)
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        position: String? = nil,
        department: String? = nil,
        enrolledCourses: [UUID] = [],
        completedCourses: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.position = position
        self.department = department
        self.enrolledCourses = enrolledCourses
        self.completedCourses = completedCourses
    }
}

// MARK: - Mock Data

extension Student {
    static let mockStudents: [Student] = [
        Student(
            name: "Анна Иванова",
            email: "anna.ivanova@company.com",
            position: "iOS Developer",
            department: "Mobile Development"
        ),
        Student(
            name: "Петр Петров",
            email: "petr.petrov@company.com",
            position: "Junior Developer",
            department: "Mobile Development"
        ),
        Student(
            name: "Мария Сидорова",
            email: "maria.sidorova@company.com",
            position: "QA Engineer",
            department: "Quality Assurance"
        ),
        Student(
            name: "Иван Козлов",
            email: "ivan.kozlov@company.com",
            position: "Backend Developer",
            department: "Backend Development"
        ),
        Student(
            name: "Елена Михайлова",
            email: "elena.mikhailova@company.com",
            position: "Project Manager",
            department: "Management"
        ),
        Student(
            name: "Сергей Николаев",
            email: "sergey.nikolaev@company.com",
            position: "DevOps Engineer",
            department: "Infrastructure"
        ),
        Student(
            name: "Ольга Федорова",
            email: "olga.fedorova@company.com",
            position: "UI/UX Designer",
            department: "Design"
        ),
        Student(
            name: "Дмитрий Соколов",
            email: "dmitry.sokolov@company.com",
            position: "Frontend Developer",
            department: "Frontend Development"
        )
    ]
} 