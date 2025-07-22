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
    
    // MARK: - Shared Instance
    
    public static let shared = Cmi5Service()
    
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
    
    private let parser = Cmi5FullParser()
    private let archiveHandler = Cmi5ArchiveHandler()
    private let repository: Cmi5RepositoryProtocol
    private let fileStorage: FileStorageService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        repository: Cmi5RepositoryProtocol? = nil,
        fileStorage: FileStorageService? = nil
    ) {
        self.repository = repository ?? Cmi5Repository()
        self.fileStorage = fileStorage ?? FileStorageService()
        
        // Загружаем пакеты при инициализации
        Task {
            await loadPackages()
        }
    }
    
    // MARK: - Public Methods
    
    /// Загружает все пакеты из хранилища
    public func loadPackages() async {
        print("🔍 [Cmi5Service] loadPackages() started")
        isLoading = true
        error = nil
        
        do {
            packages = try await repository.getAllPackages()
            print("🔍 [Cmi5Service] Loaded \(packages.count) packages:")
            for (index, package) in packages.enumerated() {
                print("   Package \(index + 1): \(package.title) (ID: \(package.id))")
                if let rootBlock = package.manifest.course?.rootBlock {
                    let activityCount = countActivities(in: rootBlock)
                    print("     - Activities: \(activityCount)")
                }
            }
        } catch {
            print("🔍 [Cmi5Service] Failed to load packages: \(error)")
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
    public func validateArchive(at url: URL) async throws -> (isValid: Bool, errors: [String], warnings: [String]) {
        do {
            try archiveHandler.validateArchive(at: url)
            return (isValid: true, errors: [], warnings: [])
        } catch let error as Cmi5ArchiveHandler.ArchiveError {
            return (isValid: false, errors: [error.localizedDescription], warnings: [])
        } catch {
            return (isValid: false, errors: [error.localizedDescription], warnings: [])
        }
    }
    
    /// Импортирует Cmi5 пакет
    public func importPackage(
        from url: URL,
        courseId: UUID? = nil,
        uploadedBy: UUID
    ) async throws -> ImportResult {
        print("🔍 CMI5 SERVICE: Starting import from \(url.lastPathComponent)")
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        // Валидируем архив
        print("🔍 CMI5 SERVICE: Validating archive...")
        let validation = try await validateArchive(at: url)
        if !validation.isValid {
            print("🔍 CMI5 SERVICE: Validation failed: \(validation.errors)")
            throw ServiceError.validationFailed(validation.errors)
        }
        
        // Распаковываем архив
        print("🔍 CMI5 SERVICE: Extracting archive...")
        let extractionResult = try await archiveHandler.extractArchive(from: url)
        
        // Очищаем временные файлы после завершения импорта
        defer {
            archiveHandler.cleanupPackage(packageId: extractionResult.packageId)
        }
        
        // Читаем и парсим манифест
        print("🔍 CMI5 SERVICE: Reading manifest from: \(extractionResult.cmi5ManifestPath.path)")
        var manifestData = try Data(contentsOf: extractionResult.cmi5ManifestPath)
        
        // Проверяем и удаляем BOM (Byte Order Mark) если есть
        if manifestData.count >= 3 {
            let bomBytes = [UInt8](manifestData.prefix(3))
            if bomBytes == [0xEF, 0xBB, 0xBF] {
                print("⚠️ CMI5 SERVICE: Found UTF-8 BOM, removing it")
                manifestData = manifestData.dropFirst(3)
            } else if manifestData.count >= 2 {
                let bomBytes2 = [UInt8](manifestData.prefix(2))
                if bomBytes2 == [0xFF, 0xFE] || bomBytes2 == [0xFE, 0xFF] {
                    print("⚠️ CMI5 SERVICE: Found UTF-16 BOM, need to convert")
                    // Пробуем конвертировать из UTF-16
                    if let utf16String = String(data: manifestData, encoding: .utf16),
                       let utf8Data = utf16String.data(using: .utf8) {
                        manifestData = utf8Data
                    }
                }
            }
        }
        
        // Проверяем содержимое для диагностики
        if let xmlString = String(data: manifestData, encoding: .utf8) {
            print("🔍 CMI5 SERVICE: Manifest content preview (first 300 chars):")
            print(String(xmlString.prefix(300)))
            
            // Проверяем наличие основных элементов
            if !xmlString.contains("<courseStructure") {
                print("❌ CMI5 SERVICE: Manifest missing <courseStructure> element")
            }
            if !xmlString.contains("xmlns=") {
                print("⚠️ CMI5 SERVICE: Manifest missing xmlns attribute")
            }
        } else {
            print("❌ CMI5 SERVICE: Failed to decode manifest as UTF-8")
            // Пробуем другие кодировки
            for encoding in [String.Encoding.windowsCP1251, .isoLatin1, .utf16] {
                if let xmlString = String(data: manifestData, encoding: encoding) {
                    print("✅ CMI5 SERVICE: Successfully decoded with \(encoding)")
                    if let utf8Data = xmlString.data(using: .utf8) {
                        manifestData = utf8Data
                    }
                    break
                }
            }
        }
        
        let xmlParser = Cmi5XMLParser()
        let parseResult = try xmlParser.parseManifest(manifestData, baseURL: extractionResult.coursePath)
        let manifest = parseResult.manifest
        
        // Получаем размер пакета
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        // Создаем пакет
        var package = Cmi5Package(
            packageId: manifest.identifier,
            title: manifest.title,
            description: manifest.description,
            courseId: courseId,
            manifest: manifest,
            filePath: extractionResult.extractedPath.path,
            size: fileSize,
            uploadedBy: uploadedBy,
            version: manifest.version ?? "1.0",
            isValid: validation.isValid,
            validationErrors: validation.errors
        )
        
        print("🔍 CMI5 SERVICE: Created package: \(package.title) (ID: \(package.id))")
        
        // Обновляем packageId для всех активностей в манифесте
        if var course = package.manifest.course,
           var rootBlock = course.rootBlock {
            updateActivityPackageIds(in: &rootBlock, packageId: package.id)
            course.rootBlock = rootBlock
            package.manifest.course = course
        }
        
        // Сохраняем в хранилище
        print("🔍 CMI5 SERVICE: Saving package files...")
        let storageUrl = try await savePackageFiles(package: package, from: extractionResult.extractedPath)
        
        // Обновляем путь к файлам
        package.filePath = storageUrl.path
        
        // Сохраняем в БД
        print("🔍 CMI5 SERVICE: Saving to repository...")
        let savedPackage = try await repository.createPackage(package)
        
        // Создаем управляемый курс из Cmi5 пакета
        print("🔍 CMI5 SERVICE: Creating managed course from Cmi5 package...")
        print("   - Package ID: \(savedPackage.id)")
        print("   - Package Title: \(savedPackage.title)")
        let managedCourse = Cmi5CourseConverter.convertToManagedCourse(from: savedPackage)
        print("🔍 CMI5 SERVICE: Converted course:")
        print("   - Course ID: \(managedCourse.id)")
        print("   - Course Title: \(managedCourse.title)")
        print("   - cmi5PackageId: \(String(describing: managedCourse.cmi5PackageId))")
        print("   - Modules: \(managedCourse.modules.count)")
        for (index, module) in managedCourse.modules.enumerated() {
            print("     Module \(index + 1): \(module.title)")
            print("       - contentType: \(module.contentType)")
            print("       - contentUrl: \(String(describing: module.contentUrl))")
        }
        
        // Сохраняем курс через CourseService
        do {
            let courseService = CourseService()
            print("🔍 CMI5 SERVICE: Calling courseService.createCourse()...")
            let createdCourse = try await courseService.createCourse(managedCourse)
            print("🔍 CMI5 SERVICE: Created managed course: \(createdCourse.title) (ID: \(createdCourse.id))")
            
            // Проверяем что курс действительно сохранен
            let allCourses = try await courseService.fetchCourses()
            print("🔍 CMI5 SERVICE: Total courses after creation: \(allCourses.count)")
            if allCourses.contains(where: { $0.id == createdCourse.id }) {
                print("🔍 CMI5 SERVICE: ✅ Course found in storage!")
            } else {
                print("🔍 CMI5 SERVICE: ❌ Course NOT found in storage!")
            }
            
            // Отправляем уведомление об успешном импорте
            print("🔍 CMI5 SERVICE: Posting Cmi5CourseImported notification...")
            await MainActor.run {
                // Небольшая задержка для надежности UI обновления
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
                    // Отправляем уведомление с информацией о созданном курсе
                    NotificationCenter.default.post(
                        name: NSNotification.Name("Cmi5CourseImported"), 
                        object: nil,
                        userInfo: ["courseId": createdCourse.id, "courseTitle": createdCourse.title]
                    )
                    print("🔍 CMI5 SERVICE: Posted Cmi5CourseImported notification from MainActor with course info")
                }
            }
            
            // Обновляем пакет с ID созданного курса
            package.courseId = createdCourse.id
            let updatedPackage = try await repository.updatePackage(package)
            
            // Обновляем список пакетов
            packages.append(updatedPackage)
            print("🔍 CMI5 SERVICE: Package imported successfully! Total packages: \(packages.count)")
            
            return ImportResult(
                package: updatedPackage,
                warnings: validation.warnings,
                storageUrl: storageUrl
            )
        } catch {
            print("🔍 CMI5 SERVICE: Failed to create managed course: \(error)")
            // Даже если не удалось создать управляемый курс, пакет всё равно импортирован
            packages.append(savedPackage)
            
            var warnings = validation.warnings
            warnings.append("Не удалось создать курс в системе управления: \(error.localizedDescription)")
            
            return ImportResult(
                package: savedPackage,
                warnings: warnings,
                storageUrl: storageUrl
            )
        }
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
        
        // Парсим активности из манифеста
        var activities: [Cmi5Activity] = []
        
        func parseBlock(_ block: Cmi5Block, parentId: String? = nil) {
            for activity in block.activities {
                activities.append(activity)
            }
            
            for childBlock in block.blocks {
                parseBlock(childBlock, parentId: block.id)
            }
        }
        
        if let rootBlock = package.manifest.rootBlock {
            parseBlock(rootBlock)
        }
        
        return activities
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
    
    private func savePackageFiles(package: Cmi5Package, from extractedPath: URL) async throws -> URL {
        // Сохраняем в постоянное хранилище
        // extractedPath уже является распакованной папкой, не нужно распаковывать снова
        let storageURL = try await fileStorage.savePackage(
            id: package.id,
            from: extractedPath
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
        let actor: [String: Any] = [
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
    
    private func countActivities(in block: Cmi5Block) -> Int {
        var count = block.activities.count
        for subBlock in block.blocks {
            count += countActivities(in: subBlock)
        }
        return count
    }
    
    private func updateActivityPackageIds(in block: inout Cmi5Block, packageId: UUID) {
        // Обновляем активности создавая новые с правильным packageId
        var updatedActivities: [Cmi5Activity] = []
        for activity in block.activities {
            var updatedActivity = activity
            updatedActivity.packageId = packageId
            updatedActivities.append(updatedActivity)
        }
        
        // Обновляем блок
        block = Cmi5Block(
            id: block.id,
            title: block.title,
            description: block.description,
            blocks: block.blocks.map { childBlock in
                var updatedChild = childBlock
                updateActivityPackageIds(in: &updatedChild, packageId: packageId)
                return updatedChild
            },
            activities: updatedActivities
        )
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
    
    // Статический ID для демо пакета AI Fluency
    static let aiFlencyPackageId = UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!
    
    init() {
        // Создаем демо-пакеты для тестирования
        createDemoPackages()
    }
    
    private func createDemoPackages() {
        print("🔍 CMI5 REPO: Creating demo packages...")
        
        // AI Fluency demo package
        let aiPackageId = Self.aiFlencyPackageId // Используем статический ID
        let aiActivities = [
            Cmi5Activity(
                id: UUID(),
                packageId: aiPackageId,
                activityId: "intro_to_ai",
                title: "Introduction to AI",
                description: "Learn the basics of artificial intelligence",
                launchUrl: "content/intro/index.html",
                launchMethod: .anyWindow,
                moveOn: .completedOrPassed,
                masteryScore: 0.8,
                activityType: "http://adlnet.gov/expapi/activities/lesson",
                duration: "PT30M"
            ),
            Cmi5Activity(
                id: UUID(),
                packageId: aiPackageId,
                activityId: "ai_applications",
                title: "AI Applications",
                description: "Explore real-world AI applications",
                launchUrl: "content/applications/index.html",
                launchMethod: .anyWindow,
                moveOn: .completedOrPassed,
                masteryScore: 0.8,
                activityType: "http://adlnet.gov/expapi/activities/lesson",
                duration: "PT45M"
            )
        ]
        
        let aiBlock = Cmi5Block(
            id: "ai_block_1",
            title: [Cmi5LangString(lang: "en", value: "AI Fundamentals")],
            description: [Cmi5LangString(lang: "en", value: "Core concepts of AI")],
            activities: aiActivities
        )
        
        let aiCourse = Cmi5Course(
            id: "ai_fluency_course",
            title: [Cmi5LangString(lang: "en", value: "AI Fluency")],
            description: [Cmi5LangString(lang: "en", value: "Comprehensive AI education course")],
            auCount: aiActivities.count,
            rootBlock: aiBlock
        )
        
        let aiManifest = Cmi5Manifest(
            identifier: "ai_fluency_v1",
            title: "AI Fluency",
            description: "Learn artificial intelligence fundamentals",
            course: aiCourse
        )
        
        let aiPackage = Cmi5Package(
            id: aiPackageId,
            packageId: aiManifest.identifier,
            title: aiManifest.title,
            description: aiManifest.description,
            manifest: aiManifest,
            filePath: "/demo/ai_fluency.zip",
            size: 1024 * 1024, // 1MB
            uploadedBy: UUID()
        )
        
        packages.append(aiPackage)
        print("🔍 CMI5 REPO: Created demo package: \(aiPackage.title)")
    }
    
    public func getAllPackages() async throws -> [Cmi5Package] {
        print("🔍 CMI5 REPO: getAllPackages() called")
        
        // Загружаем пакеты из файловой системы
        await loadPackagesFromFileSystem()
        
        // Симуляция задержки сети
        try await Task.sleep(nanoseconds: 500_000_000)
        print("🔍 CMI5 REPO: Returning \(packages.count) packages")
        return packages
    }
    
    @MainActor
    private func loadPackagesFromFileSystem() async {
        // Получаем путь к Cmi5Storage
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ CMI5 REPO: Could not find documents directory")
            return
        }
        
        let cmi5StoragePath = documentsPath.appendingPathComponent("Cmi5Storage")
        
        // Проверяем существование директории
        guard fileManager.fileExists(atPath: cmi5StoragePath.path) else {
            print("❌ CMI5 REPO: Cmi5Storage directory does not exist")
            return
        }
        
        print("📁 CMI5 REPO: Loading packages from: \(cmi5StoragePath.path)")
        
        do {
            // Получаем список всех папок пакетов
            let packageDirs = try fileManager.contentsOfDirectory(at: cmi5StoragePath, 
                                                                 includingPropertiesForKeys: [.isDirectoryKey],
                                                                 options: .skipsHiddenFiles)
            
            print("📁 CMI5 REPO: Found \(packageDirs.count) package directories")
            
            for packageDir in packageDirs {
                // Проверяем что это директория
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: packageDir.path, isDirectory: &isDirectory), isDirectory.boolValue {
                    // Пробуем загрузить cmi5.xml
                    let cmi5XmlPath = packageDir.appendingPathComponent("cmi5.xml")
                    if fileManager.fileExists(atPath: cmi5XmlPath.path) {
                        print("📁 CMI5 REPO: Found cmi5.xml in \(packageDir.lastPathComponent)")
                        
                        // Парсим XML файл
                        if let xmlData = try? Data(contentsOf: cmi5XmlPath) {
                            do {
                                let parser = Cmi5XMLParser()
                                let parseResult = try parser.parseManifest(xmlData, baseURL: packageDir)
                                let parsedManifest = parseResult.manifest
                                
                                // Получаем ID пакета из имени папки
                                if let packageId = UUID(uuidString: packageDir.lastPathComponent) {
                                    // Проверяем, не загружен ли уже этот пакет
                                    if !packages.contains(where: { $0.id == packageId }) {
                                        let package = Cmi5Package(
                                            id: packageId,
                                            packageId: parsedManifest.identifier,
                                            title: parsedManifest.title,
                                            description: parsedManifest.description,
                                            manifest: parsedManifest,
                                            filePath: packageDir.path,
                                            size: 0,
                                            uploadedBy: UUID()
                                        )
                                        
                                        packages.append(package)
                                        print("✅ CMI5 REPO: Loaded package: \(package.title) (ID: \(packageId))")
                                    }
                                }
                            } catch {
                                print("❌ CMI5 REPO: Error parsing cmi5.xml: \(error)")
                            }
                        }
                    }
                }
            }
            
        } catch {
            print("❌ CMI5 REPO: Error loading packages: \(error)")
        }
    }
    
    public func getPackage(id: UUID) async throws -> Cmi5Package {
        print("🔍 CMI5 REPO: getPackage(id: \(id)) called")
        guard let package = packages.first(where: { $0.id == id }) else {
            throw Cmi5Service.ServiceError.packageNotFound
        }
        return package
    }
    
    public func createPackage(_ package: Cmi5Package) async throws -> Cmi5Package {
        print("🔍 CMI5 REPO: createPackage() - \(package.title)")
        packages.append(package)
        print("🔍 CMI5 REPO: Package saved. Total packages: \(packages.count)")
        return package
    }
    
    public func updatePackage(_ package: Cmi5Package) async throws -> Cmi5Package {
        print("🔍 CMI5 REPO: updatePackage() - \(package.title)")
        guard let index = packages.firstIndex(where: { $0.id == package.id }) else {
            throw Cmi5Service.ServiceError.packageNotFound
        }
        packages[index] = package
        return package
    }
    
    public func deletePackage(id: UUID) async throws {
        print("🔍 CMI5 REPO: deletePackage(id: \(id)) called")
        packages.removeAll { $0.id == id }
    }
}

// MARK: - File Storage Service

/// Сервис для работы с файловым хранилищем
public final class FileStorageService {
    private let fileManager = FileManager.default
    private let storageURL: URL
    
    public init() {
        // Используем Documents directory для постоянного хранения
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.storageURL = documentsPath.appendingPathComponent("Cmi5Storage", isDirectory: true)
        
        try? fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
        print("📁 [FileStorageService] Storage directory: \(storageURL.path)")
    }
    
    public func savePackage(id: UUID, from sourceURL: URL) async throws -> URL {
        let packageURL = storageURL.appendingPathComponent(id.uuidString, isDirectory: true)
        
        print("💾 [FileStorageService] Saving package:")
        print("   - From: \(sourceURL.path)")
        print("   - To: \(packageURL.path)")
        
        if fileManager.fileExists(atPath: packageURL.path) {
            try fileManager.removeItem(at: packageURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: packageURL)
        print("✅ [FileStorageService] Package saved successfully")
        
        // Логируем структуру сохраненных файлов
        if let enumerator = fileManager.enumerator(at: packageURL, includingPropertiesForKeys: [.isRegularFileKey]) {
            print("📂 [FileStorageService] Saved files:")
            for case let fileURL as URL in enumerator {
                let relativePath = fileURL.path.replacingOccurrences(of: packageURL.path + "/", with: "")
                print("   - \(relativePath)")
            }
        }
        
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