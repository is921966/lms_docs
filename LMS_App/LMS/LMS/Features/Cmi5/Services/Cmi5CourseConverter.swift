//
//  Cmi5CourseConverter.swift
//  LMS
//
//  Service for converting Cmi5 packages to managed courses
//

import Foundation

/// Конвертер Cmi5 пакетов в управляемые курсы
@MainActor
class Cmi5CourseConverter {
    
    /// Конвертирует Cmi5 пакет в управляемый курс
    static func convertToManagedCourse(from package: Cmi5Package) -> ManagedCourse {
        print("🔄 [Cmi5CourseConverter] Converting package: \(package.title)")
        print("   - Package ID: \(package.id)")
        print("   - Has rootBlock: \(package.manifest.rootBlock != nil)")
        
        // Собираем все активности из пакета
        let activities = collectActivities(from: package)
        print("   - Total activities collected: \(activities.count)")
        for (index, activity) in activities.enumerated() {
            print("     Activity \(index + 1): \(activity.title) (ID: \(activity.activityId))")
        }
        
        // Рассчитываем общую продолжительность (по умолчанию 30 минут на активность)
        let duration = max(1, activities.count / 2) // часы
        
        // Создаем модули из блоков или активностей
        let modules = createModules(from: package, activities: activities)
        print("   - Created \(modules.count) modules")
        for (index, module) in modules.enumerated() {
            print("     Module \(index + 1): \(module.title)")
            print("       - contentType: \(module.contentType)")
            print("       - contentUrl: \(String(describing: module.contentUrl))")
        }
        
        return ManagedCourse(
            title: package.title,
            description: package.description ?? "Курс импортирован из Cmi5 пакета",
            duration: duration,
            status: .published, // Cmi5 пакеты считаем готовыми к публикации
            competencies: [], // Компетенции можно добавить позже
            modules: modules,
            createdAt: package.uploadedAt,
            updatedAt: Date(),
            cmi5PackageId: package.id // Сохраняем связь с Cmi5 пакетом
        )
    }
    
    /// Создает модули курса из структуры Cmi5 пакета
    private static func createModules(from package: Cmi5Package, activities: [Cmi5Activity]) -> [ManagedCourseModule] {
        var modules: [ManagedCourseModule] = []
        
        if let rootBlock = package.manifest.rootBlock {
            // Если есть структура блоков, используем её
            modules = createModulesFromBlock(rootBlock, order: 0).modules
        } else if !activities.isEmpty {
            // Если нет блоков, создаем один модуль со всеми активностями
            // Используем activityId первой активности
            let firstActivityId = activities.first?.activityId
            
            let module = ManagedCourseModule(
                id: UUID(),
                title: "Основной контент",
                description: "Все активности курса",
                order: 0,
                contentType: .cmi5,
                contentUrl: firstActivityId,
                duration: activities.count * 30 // 30 минут на активность по умолчанию
            )
            modules.append(module)
        }
        
        // Если модулей нет, создаем хотя бы один
        if modules.isEmpty {
            let module = ManagedCourseModule(
                id: UUID(),
                title: package.title,
                description: package.description ?? "",
                order: 0,
                contentType: .cmi5,
                contentUrl: nil, // Здесь оставляем nil так как нет активностей
                duration: 60 // 1 час по умолчанию
            )
            modules.append(module)
        }
        
        return modules
    }
    
    /// Рекурсивно создает модули из блока
    private static func createModulesFromBlock(_ block: Cmi5Block, order: Int) -> (modules: [ManagedCourseModule], nextOrder: Int) {
        var modules: [ManagedCourseModule] = []
        var currentOrder = order
        
        // Создаем модуль для текущего блока если у него есть активности
        if !block.activities.isEmpty {
            let title = block.title.first?.value ?? "Модуль \(currentOrder + 1)"
            let description = block.description?.first?.value ?? ""
            
            // Используем activityId первой активности блока как contentUrl
            let firstActivityId = block.activities.first?.activityId
            
            let module = ManagedCourseModule(
                id: UUID(),
                title: title,
                description: description,
                order: currentOrder,
                contentType: .cmi5,
                contentUrl: firstActivityId,
                duration: block.activities.count * 30 // 30 минут на активность
            )
            modules.append(module)
            currentOrder += 1
        }
        
        // Обрабатываем вложенные блоки
        for subBlock in block.blocks {
            let result = createModulesFromBlock(subBlock, order: currentOrder)
            modules.append(contentsOf: result.modules)
            currentOrder = result.nextOrder
        }
        
        return (modules, currentOrder)
    }
    
    /// Собирает все активности из пакета
    private static func collectActivities(from package: Cmi5Package) -> [Cmi5Activity] {
        guard let rootBlock = package.manifest.rootBlock else { return [] }
        
        var activities: [Cmi5Activity] = []
        
        func collectFromBlock(_ block: Cmi5Block) {
            activities.append(contentsOf: block.activities)
            for subBlock in block.blocks {
                collectFromBlock(subBlock)
            }
        }
        
        collectFromBlock(rootBlock)
        return activities
    }
    
    /// Связывает модули курса с Cmi5 активностями
    static func linkModulesToActivities(course: ManagedCourse, package: Cmi5Package) -> [(moduleId: UUID, activities: [Cmi5Activity])] {
        var links: [(moduleId: UUID, activities: [Cmi5Activity])] = []
        
        guard let rootBlock = package.manifest.rootBlock else { 
            // Если нет блоков, связываем все активности с первым модулем
            if let firstModule = course.modules.first {
                let activities = collectActivities(from: package)
                links.append((firstModule.id, activities))
            }
            return links
        }
        
        // Сопоставляем модули с блоками по порядку
        var moduleIndex = 0
        
        func linkBlock(_ block: Cmi5Block) {
            if !block.activities.isEmpty && moduleIndex < course.modules.count {
                links.append((course.modules[moduleIndex].id, block.activities))
                moduleIndex += 1
            }
            
            for subBlock in block.blocks {
                linkBlock(subBlock)
            }
        }
        
        linkBlock(rootBlock)
        return links
    }
} 