//
//  MetricsCollector.swift
//  LMS
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import Foundation
import os

/// Типы событий для аналитики
public enum MetricEventType: String {
    case userAction = "user_action"
    case screenView = "screen_view"
    case performance = "performance"
    case error = "error"
    case custom = "custom"
}

/// Структура для хранения события
public struct MetricEvent {
    public let type: MetricEventType
    public let name: String
    public let parameters: [String: Any]
    public let timestamp: Date
    public let sessionId: String
}

/// Структура для хранения просмотра экрана
public struct ScreenView {
    public let name: String
    public let startTime: Date
    public var endTime: Date?
    public let parameters: [String: Any]
    
    public var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}

/// Структура для хранения метрик производительности
public struct PerformanceMetric {
    public let operation: String
    public let duration: TimeInterval
    public let timestamp: Date
    public let success: Bool
    public let metadata: [String: Any]
}

/// Конфигурация для MetricsCollector
public struct MetricsConfiguration {
    let maxEventsCount: Int
    let sessionTimeout: TimeInterval
    let enableDebugLogging: Bool
    let automaticScreenTracking: Bool
    
    public static let `default` = MetricsConfiguration(
        maxEventsCount: 1000,
        sessionTimeout: 1800, // 30 минут
        enableDebugLogging: false,
        automaticScreenTracking: true
    )
}

/// Протокол для экспорта метрик
public protocol MetricsExporter {
    func export(events: [MetricEvent]) async throws
    func export(screenViews: [ScreenView]) async throws
    func export(performanceMetrics: [PerformanceMetric]) async throws
}

/// Сервис для сбора метрик использования приложения с расширенной функциональностью
public final class MetricsCollector {
    
    // MARK: - Properties
    
    /// Singleton instance
    public static let shared = MetricsCollector()
    
    /// Конфигурация
    private let configuration: MetricsConfiguration
    
    /// Логгер
    private let logger = os.Logger(subsystem: "com.lms.app", category: "Metrics")
    
    /// Хранилище событий
    private var events: [MetricEvent] = []
    private var screenViews: [ScreenView] = []
    private var activeScreenViews: [String: (startTime: Date, parameters: [String: Any])] = [:]
    private var performanceMetrics: [PerformanceMetric] = []
    
    /// Сессия
    private var currentSessionId: String
    private var sessionStartTime: Date
    
    /// Очередь для thread-safe доступа
    private let queue = DispatchQueue(label: "com.lms.metrics", attributes: .concurrent)
    
    /// Экспортеры метрик
    private var exporters: [MetricsExporter] = []
    
    /// Метаданные пользователя
    private var userProperties: [String: Any] = [:]
    
    // MARK: - Initialization
    
    private init(configuration: MetricsConfiguration = .default) {
        self.configuration = configuration
        self.currentSessionId = UUID().uuidString
        self.sessionStartTime = Date()
        
        setupSessionManagement()
        
        if configuration.enableDebugLogging {
            logger.debug("MetricsCollector initialized with session: \(self.currentSessionId)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Отслеживает событие с параметрами
    public func track(
        event: String,
        type: MetricEventType = .userAction,
        parameters: [String: Any] = [:]
    ) {
        queue.async(flags: .barrier) {
            let metricEvent = MetricEvent(
                type: type,
                name: event,
                parameters: self.enrichParameters(parameters),
                timestamp: Date(),
                sessionId: self.currentSessionId
            )
            
            self.events.append(metricEvent)
            self.pruneEventsIfNeeded()
            
            if self.configuration.enableDebugLogging {
                self.logger.debug("Tracked event: \(event) with parameters: \(parameters)")
            }
        }
    }
    
    /// Начинает отслеживание просмотра экрана
    public func trackScreenView(_ screenName: String, parameters: [String: Any] = [:]) {
        queue.async(flags: .barrier) {
            self.activeScreenViews[screenName] = (Date(), parameters)
            
            // Также трекаем как событие
            self.track(
                event: "screen_view_start",
                type: .screenView,
                parameters: ["screen": screenName].merging(parameters) { $1 }
            )
        }
    }
    
    /// Завершает отслеживание просмотра экрана
    public func endScreenView(_ screenName: String) -> TimeInterval? {
        return queue.sync(flags: .barrier) {
            guard let screenData = activeScreenViews[screenName] else { return nil }
            
            let screenView = ScreenView(
                name: screenName,
                startTime: screenData.startTime,
                endTime: Date(),
                parameters: screenData.parameters
            )
            
            screenViews.append(screenView)
            activeScreenViews.removeValue(forKey: screenName)
            
            // Трекаем завершение как событие
            if let duration = screenView.duration {
                track(
                    event: "screen_view_end",
                    type: .screenView,
                    parameters: [
                        "screen": screenName,
                        "duration": duration
                    ].merging(screenData.parameters) { $1 }
                )
            }
            
            return screenView.duration
        }
    }
    
    /// Измеряет производительность операции
    public func measurePerformance<T>(
        operation: String,
        metadata: [String: Any] = [:],
        block: () async throws -> T
    ) async rethrows -> T {
        let startTime = Date()
        var success = true
        
        do {
            let result = try await block()
            
            let duration = Date().timeIntervalSince(startTime)
            recordPerformanceMetric(
                operation: operation,
                duration: duration,
                success: success,
                metadata: metadata
            )
            
            return result
        } catch {
            success = false
            let duration = Date().timeIntervalSince(startTime)
            recordPerformanceMetric(
                operation: operation,
                duration: duration,
                success: success,
                metadata: metadata.merging(["error": error.localizedDescription]) { $1 }
            )
            throw error
        }
    }
    
    /// Устанавливает свойства пользователя
    public func setUserProperties(_ properties: [String: Any]) {
        queue.async(flags: .barrier) {
            self.userProperties = self.userProperties.merging(properties) { $1 }
        }
    }
    
    /// Добавляет экспортер метрик
    public func addExporter(_ exporter: MetricsExporter) {
        queue.async(flags: .barrier) {
            self.exporters.append(exporter)
        }
    }
    
    /// Экспортирует все метрики
    public func exportMetrics() async {
        let (eventsToExport, screenViewsToExport, performanceToExport) = queue.sync {
            (events, screenViews, performanceMetrics)
        }
        
        for exporter in exporters {
            do {
                await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        try await exporter.export(events: eventsToExport)
                    }
                    group.addTask {
                        try await exporter.export(screenViews: screenViewsToExport)
                    }
                    group.addTask {
                        try await exporter.export(performanceMetrics: performanceToExport)
                    }
                }
            } catch {
                logger.error("Failed to export metrics: \(error)")
            }
        }
    }
    
    /// Получает события по имени
    public func getEvents(for name: String) -> [MetricEvent] {
        return queue.sync {
            events.filter { $0.name == name }
        }
    }
    
    /// Получает все просмотры экранов
    public func getScreenViews() -> [ScreenView] {
        return queue.sync { screenViews }
    }
    
    /// Получает метрики производительности для операции
    public func getPerformanceMetrics(for operation: String) -> [PerformanceMetric] {
        return queue.sync {
            performanceMetrics.filter { $0.operation == operation }
        }
    }
    
    /// Получает сводную статистику
    public func getSummaryStats() -> MetricsSummary {
        return queue.sync {
            MetricsSummary(
                totalEvents: events.count,
                totalScreenViews: screenViews.count,
                totalPerformanceMetrics: performanceMetrics.count,
                averageScreenDuration: calculateAverageScreenDuration(),
                topEvents: getTopEvents(limit: 5),
                sessionDuration: Date().timeIntervalSince(sessionStartTime)
            )
        }
    }
    
    /// Очищает все метрики
    public func clearAll() {
        queue.async(flags: .barrier) {
            self.events.removeAll()
            self.screenViews.removeAll()
            self.activeScreenViews.removeAll()
            self.performanceMetrics.removeAll()
            
            // Начинаем новую сессию
            self.currentSessionId = UUID().uuidString
            self.sessionStartTime = Date()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSessionManagement() {
        // Проверяем таймаут сессии каждые 5 минут
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.checkSessionTimeout()
        }
    }
    
    private func checkSessionTimeout() {
        queue.async(flags: .barrier) {
            let timeSinceLastEvent = Date().timeIntervalSince(
                self.events.last?.timestamp ?? self.sessionStartTime
            )
            
            if timeSinceLastEvent > self.configuration.sessionTimeout {
                // Начинаем новую сессию
                self.currentSessionId = UUID().uuidString
                self.sessionStartTime = Date()
                self.logger.info("Started new session due to timeout: \(self.currentSessionId)")
            }
        }
    }
    
    private func enrichParameters(_ parameters: [String: Any]) -> [String: Any] {
        var enriched = parameters
        
        // Добавляем метаданные устройства
        enriched["device_model"] = UIDevice.current.model
        enriched["os_version"] = UIDevice.current.systemVersion
        enriched["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        // Добавляем свойства пользователя
        enriched = enriched.merging(userProperties) { current, _ in current }
        
        return enriched
    }
    
    private func recordPerformanceMetric(
        operation: String,
        duration: TimeInterval,
        success: Bool,
        metadata: [String: Any]
    ) {
        queue.async(flags: .barrier) {
            let metric = PerformanceMetric(
                operation: operation,
                duration: duration,
                timestamp: Date(),
                success: success,
                metadata: metadata
            )
            
            self.performanceMetrics.append(metric)
            
            // Также трекаем как событие
            self.track(
                event: "performance_metric",
                type: .performance,
                parameters: [
                    "operation": operation,
                    "duration": duration,
                    "success": success
                ].merging(metadata) { $1 }
            )
        }
    }
    
    private func pruneEventsIfNeeded() {
        if events.count > configuration.maxEventsCount {
            let countToRemove = events.count - configuration.maxEventsCount
            events.removeFirst(countToRemove)
            logger.warning("Pruned \(countToRemove) old events")
        }
    }
    
    private func calculateAverageScreenDuration() -> TimeInterval {
        let durations = screenViews.compactMap { $0.duration }
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }
    
    private func getTopEvents(limit: Int) -> [(name: String, count: Int)] {
        let eventCounts = Dictionary(grouping: events, by: { $0.name })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(limit)
        
        return eventCounts.map { (name: $0.key, count: $0.value) }
    }
}

/// Сводная статистика метрик
public struct MetricsSummary {
    public let totalEvents: Int
    public let totalScreenViews: Int
    public let totalPerformanceMetrics: Int
    public let averageScreenDuration: TimeInterval
    public let topEvents: [(name: String, count: Int)]
    public let sessionDuration: TimeInterval
}

// MARK: - UIKit Integration

#if canImport(UIKit)
import UIKit

extension MetricsCollector {
    /// Автоматически отслеживает жизненный цикл приложения
    public func startAutomaticTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        track(event: "app_became_active", type: .custom)
    }
    
    @objc private func appWillResignActive() {
        track(event: "app_will_resign_active", type: .custom)
        Task {
            await exportMetrics()
        }
    }
    
    @objc private func appDidReceiveMemoryWarning() {
        track(event: "memory_warning", type: .error)
    }
}
#endif 