//  Cmi5Models+Extensions.swift
//  LMS
//
//  Created by LMS on 17.01.2025.
//

import Foundation

// MARK: - Cmi5Activity Extensions

extension Cmi5Activity {
    /// Преобразует Cmi5Activity в XAPIActivity для использования в statements
    func toXAPIActivity() -> XAPIActivity {
        var definition = XAPIActivityDefinition(
            name: ["en": title],
            description: description.map { ["en": $0] }
        )
        
        // Установить тип активности
        definition.type = activityType
        
        // Добавить расширения Cmi5
        var extensions: [String: Any] = [:]
        
        extensions["https://w3id.org/xapi/cmi5/context/extensions/launchmethod"] = launchMethod.rawValue
        extensions["https://w3id.org/xapi/cmi5/context/extensions/moveon"] = moveOn.rawValue
        
        if let masteryScore = masteryScore {
            extensions["https://w3id.org/xapi/cmi5/context/extensions/masteryscore"] = masteryScore
        }
        
        if !extensions.isEmpty {
            definition.extensions = extensions
        }
        
        return XAPIActivity(
            id: launchUrl,
            definition: definition
        )
    }
}

// MARK: - Cmi5Block Extensions

extension Cmi5Block {
    /// Преобразует Cmi5Block в XAPIActivity
    func toXAPIActivity() -> XAPIActivity {
        let names = Dictionary(uniqueKeysWithValues: title.map { ($0.lang, $0.value) })
        let descriptions = description?.isEmpty == false 
            ? Dictionary(uniqueKeysWithValues: description!.map { ($0.lang, $0.value) })
            : nil
            
        let definition = XAPIActivityDefinition(
            name: names,
            description: descriptions,
            type: "http://adlnet.gov/expapi/activities/course"
        )
        
        return XAPIActivity(
            id: "urn:uuid:\(id)",
            definition: definition
        )
    }
    
    /// Получает все активности из блока рекурсивно
    func getAllActivities() -> [Cmi5Activity] {
        var activities: [Cmi5Activity] = []
        
        // Добавить активности текущего блока
        activities.append(contentsOf: self.activities)
        
        // Рекурсивно добавить активности из вложенных блоков
        for block in blocks {
            activities.append(contentsOf: block.getAllActivities())
        }
        
        return activities
    }
    
    /// Находит активность по ID
    func findActivity(byId id: String) -> Cmi5Activity? {
        // Проверить активности текущего блока
        if let activity = activities.first(where: { $0.activityId == id }) {
            return activity
        }
        
        // Рекурсивно искать во вложенных блоках
        for block in blocks {
            if let activity = block.findActivity(byId: id) {
                return activity
            }
        }
        
        return nil
    }
}

// MARK: - Cmi5Package Extensions

extension Cmi5Package {
    /// Получает все активности из пакета
    func getAllActivities() -> [Cmi5Activity] {
        return manifest.course?.rootBlock?.getAllActivities() ?? []
    }
    
    /// Находит активность по ID
    func findActivity(byId id: String) -> Cmi5Activity? {
        return manifest.course?.rootBlock?.findActivity(byId: id)
    }
    
    /// Проверяет валидность пакета
    func validate() -> [String] {
        var errors: [String] = []
        
        // Проверить наличие обязательных полей
        if let course = manifest.course {
            if course.id.isEmpty {
                errors.append("Course ID is required")
            }
            
            if course.title?.isEmpty != false {
                errors.append("Course title is required")
            }
        } else {
            errors.append("Manifest must contain a course")
        }
        
        // Проверить наличие активностей
        let activities = getAllActivities()
        if activities.isEmpty {
            errors.append("Package must contain at least one activity")
        }
        
        // Проверить URL активностей
        for activity in activities {
            if activity.launchUrl.isEmpty {
                errors.append("Activity '\(activity.activityId)' has no URL")
            }
            
            // Проверить, что URL валидный
            if URL(string: activity.launchUrl) == nil {
                errors.append("Activity '\(activity.activityId)' has invalid URL: \(activity.launchUrl)")
            }
        }
        
        return errors
    }
    
    /// Создает структуру курса для импорта
    func toCourseStructure() -> CourseStructure {
        guard let rootBlock = manifest.course?.rootBlock else {
            return CourseStructure(
                id: UUID(),
                title: title,
                description: description ?? "",
                modules: []
            )
        }
        
        return CourseStructure(
            id: UUID(),
            title: manifest.course?.title?.first?.value ?? title,
            description: manifest.course?.description?.first?.value ?? description ?? "",
            modules: rootBlock.blocks.map { block in
                CourseModule(
                    id: UUID(),
                    title: block.title.first?.value ?? "Module",
                    description: block.description?.first?.value ?? "",
                    lessons: block.activities.map { activity in
                        CourseLesson(
                            id: UUID(),
                            title: activity.title,
                            description: activity.description ?? "",
                            contentType: .cmi5,
                            cmi5ActivityId: activity.activityId,
                            duration: 0, // Will be updated from xAPI data
                            order: 0
                        )
                    },
                    order: 0
                )
            }
        )
    }
}

// MARK: - Supporting Types

struct CourseStructure {
    let id: UUID
    let title: String
    let description: String
    let modules: [CourseModule]
}

struct CourseModule {
    let id: UUID
    let title: String
    let description: String
    let lessons: [CourseLesson]
    let order: Int
}

struct CourseLesson {
    let id: UUID
    let title: String
    let description: String
    let contentType: ContentType
    let cmi5ActivityId: String?
    let duration: Int
    let order: Int
}

enum ContentType: String {
    case video = "video"
    case document = "document"
    case quiz = "quiz"
    case scorm = "scorm"
    case cmi5 = "cmi5"
} 