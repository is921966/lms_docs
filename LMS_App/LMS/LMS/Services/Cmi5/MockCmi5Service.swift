import Foundation
import SwiftUI

/// Mock сервис для Cmi5 тестирования
@MainActor
class MockCmi5Service: ObservableObject {
    static let shared = MockCmi5Service()
    
    @Published var packages: [Cmi5Package] = []
    @Published var isLoading = false
    
    private init() {
        // Инициализируем с тестовыми пакетами в debug режиме
        #if DEBUG
        setupTestPackages()
        #endif
    }
    
    /// Настройка тестовых пакетов
    func setupTestPackages() {
        let packageId1 = UUID()
        let packageId2 = UUID()
        
        packages = [
            Cmi5Package(
                id: UUID(),
                packageId: "ai-fluency-course-v1",
                title: "AI Fluency: Mastering Artificial Intelligence",
                description: "Comprehensive course on AI fundamentals and applications",
                courseId: nil,
                manifest: Cmi5Manifest(
                    identifier: "ai-fluency-course",
                    title: "AI Fluency Course",
                    description: "Learn AI fundamentals",
                    vendor: Cmi5Vendor(
                        name: "LMS Education",
                        contact: "support@lms.edu",
                        url: "https://lms.edu"
                    ),
                    version: "1.0",
                    course: Cmi5Course(
                        id: "ai-course-001",
                        title: [Cmi5LangString(lang: "en", value: "AI Fluency")],
                        description: [Cmi5LangString(lang: "en", value: "Master AI concepts")],
                        auCount: 2
                    )
                ),
                filePath: "/courses/ai-fluency.zip",
                size: 1024 * 1024 * 5, // 5MB
                uploadedBy: UUID(),
                version: "1.0"
            ),
            Cmi5Package(
                id: UUID(),
                packageId: "corporate-culture-tsum-v1",
                title: "Корпоративная культура ЦУМ",
                description: "Введение в корпоративную культуру ЦУМ",
                courseId: nil,
                manifest: Cmi5Manifest(
                    identifier: "corporate-culture-tsum",
                    title: "Корпоративная культура",
                    description: "Основы корпоративной культуры",
                    vendor: Cmi5Vendor(
                        name: "ЦУМ",
                        contact: "hr@tsum.ru"
                    ),
                    version: "1.0",
                    course: Cmi5Course(
                        id: "culture-course-001",
                        title: [Cmi5LangString(lang: "ru", value: "Корпоративная культура")],
                        description: [Cmi5LangString(lang: "ru", value: "Изучение ценностей компании")],
                        auCount: 2
                    )
                ),
                filePath: "/courses/corporate-culture.zip",
                size: 1024 * 1024 * 3, // 3MB
                uploadedBy: UUID(),
                version: "1.0"
            )
        ]
    }
    
    /// Загрузить пакет (mock)
    func uploadPackage(from url: URL) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Эмулируем загрузку
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
        
        // В тестах просто добавляем фейковый пакет
        let newPackage = Cmi5Package(
            id: UUID(),
            packageId: "uploaded-\(UUID().uuidString)",
            title: "Uploaded: \(url.lastPathComponent)",
            description: "Test package uploaded from \(url.lastPathComponent)",
            courseId: nil,
            manifest: Cmi5Manifest.empty(),
            filePath: url.path,
            size: 1024 * 1024, // 1MB
            uploadedBy: UUID(),
            version: "1.0"
        )
        
        packages.append(newPackage)
    }
    
    /// Удалить пакет
    func deletePackage(_ package: Cmi5Package) {
        packages.removeAll { $0.id == package.id }
    }
    
    /// Получить активности для пакета
    func getActivities(for packageId: UUID) -> [Cmi5Activity] {
        // Возвращаем тестовые активности
        return [
            Cmi5Activity(
                id: UUID(),
                packageId: packageId,
                activityId: "activity-1",
                title: "Introduction to AI",
                description: "Basic concepts and history",
                launchUrl: "content/intro.html",
                launchMethod: .anyWindow,
                moveOn: .completed,
                activityType: "http://adlnet.gov/expapi/activities/lesson"
            ),
            Cmi5Activity(
                id: UUID(),
                packageId: packageId,
                activityId: "activity-2",
                title: "Machine Learning Basics",
                description: "Understanding ML algorithms",
                launchUrl: "content/ml-basics.html",
                launchMethod: .anyWindow,
                moveOn: .completedAndPassed,
                masteryScore: 0.8,
                activityType: "http://adlnet.gov/expapi/activities/lesson"
            )
        ]
    }
} 