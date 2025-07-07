//
//  FeatureToggleService.swift
//  LMS
//
//  Created on Sprint 39 - TDD Excellence
//

import Foundation

/// Сервис для управления feature flags в приложении
/// 
/// Позволяет динамически включать/отключать функциональность
/// без перекомпиляции приложения.
/// 
/// Пример использования:
/// ```swift
/// let featureToggle = FeatureToggleService.shared
/// if featureToggle.isFeatureEnabled(.newDashboard) {
///     // Показать новый дашборд
/// }
/// ```
///
/// - Note: Thread-safe реализация
/// - Since: v2.0.0
public final class FeatureToggleService {
    
    // MARK: - Types
    
    /// Доступные feature flags
    public enum Feature: String, CaseIterable {
        case newDashboard = "new-dashboard"
        case experimentalAI = "experimental-ai"
        case analyticsV2 = "analytics-v2"
        case advancedReporting = "advanced-reporting"
        case offlineMode = "offline-mode"
        case betaFeatures = "beta-features"
        case debugMenu = "debug-menu"
    }
    
    // MARK: - Properties
    
    /// Singleton instance
    public static let shared = FeatureToggleService()
    
    /// Thread-safe хранилище включенных функций
    private var enabledFeatures: Set<String> = []
    private let queue = DispatchQueue(label: "com.lms.featuretoggle", attributes: .concurrent)
    
    /// Настройки по умолчанию для различных окружений
    private let defaultEnabledFeatures: Set<String> = {
        #if DEBUG
        // В debug режиме включаем больше функций
        return ["debug-menu", "beta-features"]
        #else
        // В production только стабильные функции
        return []
        #endif
    }()
    
    // MARK: - Initialization
    
    init() {
        // Загружаем настройки по умолчанию
        enabledFeatures = defaultEnabledFeatures
    }
    
    // MARK: - Public Methods
    
    /// Проверяет, включена ли функция
    /// - Parameter feature: Функция для проверки
    /// - Returns: true если функция включена
    public func isFeatureEnabled(_ feature: Feature) -> Bool {
        isFeatureEnabled(feature.rawValue)
    }
    
    /// Проверяет, включена ли функция по строковому идентификатору
    /// - Parameter featureName: Имя функции
    /// - Returns: true если функция включена
    public func isFeatureEnabled(_ featureName: String) -> Bool {
        queue.sync {
            enabledFeatures.contains(featureName)
        }
    }
    
    /// Включает функцию
    /// - Parameter feature: Функция для включения
    public func enableFeature(_ feature: Feature) {
        enableFeature(feature.rawValue)
    }
    
    /// Включает функцию по строковому идентификатору
    /// - Parameter featureName: Имя функции
    public func enableFeature(_ featureName: String) {
        queue.async(flags: .barrier) {
            self.enabledFeatures.insert(featureName)
        }
    }
    
    /// Отключает функцию
    /// - Parameter feature: Функция для отключения
    public func disableFeature(_ feature: Feature) {
        disableFeature(feature.rawValue)
    }
    
    /// Отключает функцию по строковому идентификатору
    /// - Parameter featureName: Имя функции
    public func disableFeature(_ featureName: String) {
        queue.async(flags: .barrier) {
            self.enabledFeatures.remove(featureName)
        }
    }
    
    /// Сбрасывает все настройки к значениям по умолчанию
    public func resetToDefaults() {
        queue.async(flags: .barrier) {
            self.enabledFeatures = self.defaultEnabledFeatures
        }
    }
    
    /// Возвращает список всех включенных функций
    /// - Returns: Массив имен включенных функций
    public func allEnabledFeatures() -> [String] {
        queue.sync {
            Array(enabledFeatures).sorted()
        }
    }
    
    /// Массовое включение функций
    /// - Parameter features: Массив функций для включения
    public func enableFeatures(_ features: [Feature]) {
        queue.async(flags: .barrier) {
            features.forEach { feature in
                self.enabledFeatures.insert(feature.rawValue)
            }
        }
    }
    
    /// Массовое отключение функций
    /// - Parameter features: Массив функций для отключения
    public func disableFeatures(_ features: [Feature]) {
        queue.async(flags: .barrier) {
            features.forEach { feature in
                self.enabledFeatures.remove(feature.rawValue)
            }
        }
    }
} 