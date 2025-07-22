import Foundation

struct Course: Identifiable, Codable {
    let id: String = UUID().uuidString
    var title: String
    var description: String
    var categoryId: String?
    var status: CourseStatus
    var type: CourseType
    var modules: [Module]
    var duration: String
    var createdBy: UUID
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var lessonsCount: Int {
        modules.reduce(0) { $0 + $1.lessons.count }
    }
    
    // Computed properties for compatibility
    var category: CourseCategory? {
        guard let categoryId = categoryId else { return nil }
        return CourseCategory(rawValue: categoryId)
    }
    
    // Mock data generation
    static func createMockCourses() -> [Course] {
        return [
            Course(
                title: "Основы управления в ЦУМ",
                description: "Базовый курс для новых руководителей",
                categoryId: CourseCategory.business.rawValue,
                status: .published,
                type: .mandatory,
                modules: [
                    Module(
                        title: "Введение в корпоративную культуру",
                        description: "Основы корпоративной культуры ЦУМ",
                        lessons: [
                            Lesson(
                                title: "История ЦУМ",
                                description: "История развития компании",
                                type: .video,
                                content: .video(url: "https://example.com/video1.mp4", subtitlesUrl: nil)
                            )
                        ]
                    )
                ],
                duration: "4 часа",
                createdBy: UUID()
            ),
            Course(
                title: "Клиентский сервис premium",
                description: "Продвинутые техники работы с VIP клиентами",
                categoryId: CourseCategory.soft.rawValue,
                status: .published,
                type: .optional,
                modules: [],
                duration: "8 часов",
                createdBy: UUID()
            )
        ]
    }
    
    static var mockCourses: [Course] {
        createMockCourses()
    }
} 