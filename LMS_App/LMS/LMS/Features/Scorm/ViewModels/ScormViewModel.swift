import SwiftUI
import Combine

class ScormViewModel: ObservableObject {
    @Published var packages: [ScormPackage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadPackages()
    }
    
    // MARK: - Load Packages
    func loadPackages() {
        // В реальном приложении здесь будет загрузка из базы данных
        // Сейчас загружаем демо-данные
        packages = [
            ScormPackage(
                title: "Основы продаж в ЦУМ",
                description: "Базовый курс по технике продаж для новых сотрудников",
                version: "SCORM 2004 4th Edition",
                organization: "ЦУМ Академия",
                scoCount: 5,
                fileSize: 25 * 1024 * 1024, // 25 MB
                importDate: Date().addingTimeInterval(-7 * 24 * 60 * 60), // Неделю назад
                manifestPath: "/scorm/sales-basics/imsmanifest.xml",
                contentPath: "/scorm/sales-basics/"
            ),
            ScormPackage(
                title: "Клиентский сервис Premium",
                description: "Продвинутый курс по работе с VIP клиентами",
                version: "SCORM 2004 3rd Edition",
                organization: "ЦУМ Академия",
                scoCount: 8,
                fileSize: 45 * 1024 * 1024, // 45 MB
                importDate: Date().addingTimeInterval(-3 * 24 * 60 * 60), // 3 дня назад
                manifestPath: "/scorm/premium-service/imsmanifest.xml",
                contentPath: "/scorm/premium-service/"
            )
        ]
    }
    
    // MARK: - Import SCORM Package
    func importScormPackage(from url: URL, completion: @escaping (Bool, String) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Симуляция асинхронной операции
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Создаем новый пакет
            let newPackage = ScormPackage(
                title: "Импортированный курс",
                description: "Курс импортирован из \(url.lastPathComponent)",
                version: "SCORM 2004",
                organization: "Неизвестная организация",
                scoCount: 1,
                fileSize: Int64.random(in: 1024*1024...100*1024*1024),
                importDate: Date(),
                manifestPath: "/scorm/imported/imsmanifest.xml",
                contentPath: "/scorm/imported/"
            )
            
            self.packages.append(newPackage)
            self.isLoading = false
            
            // Логируем событие
            ComprehensiveLogger.shared.log(.data, .info, "SCORM package imported", details: [
                "packageId": newPackage.id.uuidString,
                "title": newPackage.title,
                "fileSize": newPackage.fileSize
            ])
            
            completion(true, "SCORM пакет успешно импортирован")
        }
    }
    
    // MARK: - Delete Package
    func deletePackage(_ package: ScormPackage) {
        packages.removeAll { $0.id == package.id }
        
        // Логируем событие
        ComprehensiveLogger.shared.log(.data, .info, "SCORM package deleted", details: [
            "packageId": package.id.uuidString,
            "title": package.title
        ])
    }
    
    // MARK: - Create Course from Package
    func createCourseFromPackage(_ package: ScormPackage) {
        // В реальном приложении здесь будет создание курса
        // и уведомление CourseService
        
        ComprehensiveLogger.shared.log(.data, .info, "Course created from SCORM package", details: [
            "packageId": package.id.uuidString,
            "title": package.title
        ])
        
        // Показываем временное сообщение об успехе
        errorMessage = nil
    }
} 