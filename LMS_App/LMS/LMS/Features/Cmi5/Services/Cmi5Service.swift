//
//  Cmi5Service.swift
//  LMS
//
//  Created on Sprint 40 Day 3 - Service Layer
//

import Foundation
import Combine

/// Сервис для работы с Cmi5 пакетами
@MainActor
public final class Cmi5Service: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var packages: [Cmi5Package] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    
    // MARK: - Types
    
    public enum ServiceError: LocalizedError {
        case invalidFile
        case uploadFailed(String)
        case validationFailed([String])
        case importFailed(String)
        case packageNotFound
        case storageError(String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidFile:
                return "Недействительный файл. Проверьте формат и содержимое."
            case .uploadFailed(let reason):
                return "Ошибка загрузки: \(reason)"
            case .validationFailed(let errors):
                return "Ошибки валидации: \(errors.joined(separator: ", "))"
            case .importFailed(let reason):
                return "Ошибка импорта: \(reason)"
            case .packageNotFound:
                return "Пакет не найден"
            case .storageError(let reason):
                return "Ошибка хранилища: \(reason)"
            }
        }
    }
    
    /// Результат импорта пакета
    public struct ImportResult {
        public let package: Cmi5Package
        public let warnings: [String]
        public let storageUrl: URL
    }
    
    // MARK: - Properties
    
    private let parser = Cmi5Parser()
    private let archiveHandler = Cmi5ArchiveHandler()
    private let repository: Cmi5Repository
    private let fileStorage: FileStorageService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        repository: Cmi5Repository = Cmi5Repository(),
        fileStorage: FileStorageService = FileStorageService()
    ) {
        self.repository = repository
        self.fileStorage = fileStorage
        
        // Загружаем пакеты при инициализации
        Task {
            await loadPackages()
        }
    }
    
    // MARK: - Public Methods
    
    /// Загружает все пакеты из репозитория
    public func loadPackages() async {
        isLoading = true
        error = nil
        
        do {
            packages = try await repository.getAllPackages()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Загружает пакет по ID
    public func loadPackage(id: UUID) async throws -> Cmi5Package {
        if let cached = packages.first(where: { $0.id == id }) {
            return cached
        }
        
        let package = try await repository.getPackage(id: id)
        
        // Обновляем кэш
        if let index = packages.firstIndex(where: { $0.id == id }) {
            packages[index] = package
        } else {
            packages.append(package)
        }
        
        return package
    }
    
    /// Валидирует Cmi5 архив
    public func validateArchive(at url: URL) async throws -> Cmi5ArchiveHandler.ValidationResult {
        return try await archiveHandler.performFullValidation(at: url)
    }
    
    /// Импортирует Cmi5 пакет
    public func importPackage(
        from url: URL,
        courseId: UUID? = nil,
        uploadedBy: UUID
    ) async throws -> ImportResult {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        // Валидируем архив
        let validation = try await validateArchive(at: url)
        if !validation.isValid {
            throw ServiceError.validationFailed(validation.errors)
        }
        
        // Парсим пакет
        var package = try await parser.parsePackage(from: url)
        
        // Обновляем данные пакета
        package.courseId = courseId
        package.uploadedBy = uploadedBy
        package.status = validation.isValid ? .valid : .invalid
        
        // Сохраняем в хранилище
        let storageUrl = try await savePackageFiles(package: package, from: url)
        
        // Сохраняем в БД
        let savedPackage = try await repository.createPackage(package)
        
        // Обновляем список пакетов
        packages.append(savedPackage)
        
        return ImportResult(
            package: savedPackage,
            warnings: validation.warnings,
            storageUrl: storageUrl
        )
    }
    
    /// Привязывает пакет к курсу
    public func assignPackageToCourse(packageId: UUID, courseId: UUID) async throws {
        guard var package = packages.first(where: { $0.id == packageId }) else {
            throw ServiceError.packageNotFound
        }
        
        package.courseId = courseId
        
        let updated = try await repository.updatePackage(package)
        
        // Обновляем в кэше
        if let index = packages.firstIndex(where: { $0.id == packageId }) {
            packages[index] = updated
        }
    }
    
    /// Удаляет пакет
    public func deletePackage(id: UUID) async throws {
        // Удаляем файлы
        try await fileStorage.deletePackageFiles(packageId: id)
        
        // Удаляем из БД
        try await repository.deletePackage(id: id)
        
        // Удаляем из кэша
        packages.removeAll { $0.id == id }
    }
    
    /// Получает активности пакета
    public func getActivities(for packageId: UUID) async throws -> [Cmi5Activity] {
        let package = try await loadPackage(id: packageId)
        return package.activities
    }
    
    /// Создает URL для запуска активности
    public func getLaunchURL(
        for activity: Cmi5Activity,
        studentId: UUID,
        sessionId: UUID
    ) async throws -> URL {
        // Получаем базовый URL из хранилища
        let baseURL = try await fileStorage.getPackageURL(packageId: activity.packageId)
        
        // Создаем полный URL с параметрами
        let launchURL = baseURL.appendingPathComponent(activity.launchUrl)
        
        // Добавляем параметры Cmi5
        var components = URLComponents(url: launchURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "endpoint", value: getLRSEndpoint()),
            URLQueryItem(name: "fetch", value: getFetchURL(sessionId: sessionId).absoluteString),
            URLQueryItem(name: "registration", value: sessionId.uuidString),
            URLQueryItem(name: "activityId", value: activity.activityId),
            URLQueryItem(name: "actor", value: getActorJSON(studentId: studentId))
        ]
        
        return components.url!
    }
    
    // MARK: - Private Methods
    
    private func savePackageFiles(package: Cmi5Package, from archiveURL: URL) async throws -> URL {
        // Распаковываем во временную папку
        let extraction = try await archiveHandler.extractArchive(from: archiveURL)
        
        defer {
            archiveHandler.cleanupPackage(at: extraction.extractedPath)
        }
        
        // Сохраняем в постоянное хранилище
        let storageURL = try await fileStorage.savePackage(
            id: package.id,
            from: extraction.extractedPath
        )
        
        return storageURL
    }
    
    private func getLRSEndpoint() -> String {
        // В реальном приложении это будет из конфигурации
        return "https://lrs.example.com/xapi"
    }
    
    private func getFetchURL(sessionId: UUID) -> URL {
        // URL для получения auth token
        return URL(string: "https://api.example.com/cmi5/fetch/\(sessionId)")!
    }
    
    private func getActorJSON(studentId: UUID) -> String {
        // Создаем JSON для actor
        let actor = [
            "objectType": "Agent",
            "account": [
                "name": studentId.uuidString,
                "homePage": "https://lms.example.com"
            ]
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: actor),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        
        return "{}"
    }
}

// MARK: - Repository Protocol

/// Протокол репозитория для Cmi5
public protocol Cmi5RepositoryProtocol {
    func getAllPackages() async throws -> [Cmi5Package]
    func getPackage(id: UUID) async throws -> Cmi5Package
    func createPackage(_ package: Cmi5Package) async throws -> Cmi5Package
    func updatePackage(_ package: Cmi5Package) async throws -> Cmi5Package
    func deletePackage(id: UUID) async throws
}

// MARK: - Mock Repository

/// Mock репозиторий для тестирования
public final class Cmi5Repository: Cmi5RepositoryProtocol {
    private var packages: [Cmi5Package] = []
    
    public func getAllPackages() async throws -> [Cmi5Package] {
        // Симуляция задержки сети
        try await Task.sleep(nanoseconds: 500_000_000)
        return packages
    }
    
    public func getPackage(id: UUID) async throws -> Cmi5Package {
        guard let package = packages.first(where: { $0.id == id }) else {
            throw Cmi5Service.ServiceError.packageNotFound
        }
        return package
    }
    
    public func createPackage(_ package: Cmi5Package) async throws -> Cmi5Package {
        packages.append(package)
        return package
    }
    
    public func updatePackage(_ package: Cmi5Package) async throws -> Cmi5Package {
        guard let index = packages.firstIndex(where: { $0.id == package.id }) else {
            throw Cmi5Service.ServiceError.packageNotFound
        }
        packages[index] = package
        return package
    }
    
    public func deletePackage(id: UUID) async throws {
        packages.removeAll { $0.id == id }
    }
}

// MARK: - File Storage Service

/// Сервис для работы с файловым хранилищем
public final class FileStorageService {
    private let fileManager = FileManager.default
    private let storageURL: URL
    
    public init() {
        // В реальном приложении это будет Documents directory
        self.storageURL = fileManager.temporaryDirectory
            .appendingPathComponent("cmi5_storage", isDirectory: true)
        
        try? fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
    }
    
    public func savePackage(id: UUID, from sourceURL: URL) async throws -> URL {
        let packageURL = storageURL.appendingPathComponent(id.uuidString, isDirectory: true)
        
        if fileManager.fileExists(atPath: packageURL.path) {
            try fileManager.removeItem(at: packageURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: packageURL)
        
        return packageURL
    }
    
    public func getPackageURL(packageId: UUID) async throws -> URL {
        let packageURL = storageURL.appendingPathComponent(packageId.uuidString, isDirectory: true)
        
        guard fileManager.fileExists(atPath: packageURL.path) else {
            throw Cmi5Service.ServiceError.packageNotFound
        }
        
        return packageURL
    }
    
    public func deletePackageFiles(packageId: UUID) async throws {
        let packageURL = storageURL.appendingPathComponent(packageId.uuidString, isDirectory: true)
        
        if fileManager.fileExists(atPath: packageURL.path) {
            try fileManager.removeItem(at: packageURL)
        }
    }
} 