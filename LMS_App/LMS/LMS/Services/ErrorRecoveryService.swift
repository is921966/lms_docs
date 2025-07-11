//
//  ErrorRecoveryService.swift
//  LMS
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import Foundation
import os

/// Ошибки, которые можно восстановить
public enum RecoverableError: Error, LocalizedError {
    case networkTimeout
    case connectionLost
    case serverError(statusCode: Int)
    case circuitBreakerOpen(resourceId: String)
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .networkTimeout:
            return "Время ожидания истекло"
        case .connectionLost:
            return "Соединение потеряно"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .circuitBreakerOpen(let resourceId):
            return "Сервис временно недоступен: \(resourceId)"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

/// Стратегии повторных попыток
public enum RetryStrategy {
    case exponentialBackoff(initialDelay: TimeInterval = 0.1)
    case linear(delay: TimeInterval = 0.5)
    case immediate
    case custom(delayProvider: (Int) -> TimeInterval)
}

/// Действие восстановления
public struct RecoveryAction {
    public let action: RecoveryActionType
    public let delay: TimeInterval
    public let shouldNotifyUser: Bool
    public let message: String?
}

/// Типы действий восстановления
public enum RecoveryActionType {
    case retry
    case fallback
    case fail
    case waitAndRetry
}

/// Конфигурация сервиса
public struct ErrorRecoveryConfiguration {
    let circuitBreakerThreshold: Int
    let circuitBreakerResetTime: TimeInterval
    let maxRetryAttempts: Int
    let defaultRetryStrategy: RetryStrategy
    
    static let `default` = ErrorRecoveryConfiguration(
        circuitBreakerThreshold: 5,
        circuitBreakerResetTime: 60.0,
        maxRetryAttempts: 3,
        defaultRetryStrategy: .exponentialBackoff()
    )
}

/// Сервис для восстановления после ошибок с расширенной функциональностью
public final class ErrorRecoveryService {
    
    // MARK: - Types
    
    /// Состояние circuit breaker
    private struct CircuitState {
        var failureCount: Int = 0
        var lastFailureTime: Date?
        var isOpen: Bool = false
        var halfOpenAttempts: Int = 0
    }
    
    // MARK: - Properties
    
    /// Singleton instance
    public static let shared = ErrorRecoveryService()
    
    /// Логгер
    private let logger = os.Logger(subsystem: "com.lms.app", category: "ErrorRecovery")
    
    /// Конфигурация
    private let configuration: ErrorRecoveryConfiguration
    
    /// Состояния circuit breaker для ресурсов
    private var circuitStates: [String: CircuitState] = [:]
    
    /// Очередь для thread-safe доступа
    private let queue = DispatchQueue(label: "com.lms.errorrecovery", attributes: .concurrent)
    
    /// Счетчик метрик
    private var metrics = ErrorMetrics()
    
    // MARK: - Initialization
    
    private init(configuration: ErrorRecoveryConfiguration = .default) {
        self.configuration = configuration
        
        // Запускаем периодическую проверку circuit breakers
        startCircuitBreakerResetTimer()
    }
    
    // MARK: - Public Methods
    
    /// Выполняет операцию с повторными попытками и расширенным логированием
    public func retry<T>(
        operation: () async throws -> T,
        maxAttempts: Int? = nil,
        strategy: RetryStrategy? = nil,
        context: String = "Unknown"
    ) async throws -> T {
        let attempts = maxAttempts ?? configuration.maxRetryAttempts
        let retryStrategy = strategy ?? configuration.defaultRetryStrategy
        var lastError: Error?
        
        logger.debug("Starting retry operation: \(context)")
        
        for attempt in 0..<attempts {
            do {
                let result = try await operation()
                
                if attempt > 0 {
                    logger.info("Operation succeeded after \(attempt + 1) attempts: \(context)")
                    recordSuccess(context: context, attempts: attempt + 1)
                }
                
                return result
            } catch {
                lastError = error
                logger.warning("Attempt \(attempt + 1) failed: \(error.localizedDescription)")
                
                if attempt < attempts - 1 {
                    let delay = calculateDelay(
                        attempt: attempt,
                        strategy: retryStrategy
                    )
                    
                    logger.debug("Waiting \(delay) seconds before retry")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        recordFailure(context: context, error: lastError)
        throw lastError ?? RecoverableError.unknown
    }
    
    /// Восстанавливается после ошибки с контекстом
    public func recoverFrom(
        error: Error,
        context: String = "Unknown"
    ) async -> RecoveryAction {
        logger.info("Attempting recovery from error: \(error.localizedDescription) in context: \(context)")
        
        // Проверяем наш тип ошибок
        if let recoverableError = error as? RecoverableError {
            switch recoverableError {
            case .connectionLost:
                return RecoveryAction(
                    action: .retry,
                    delay: 1.0,
                    shouldNotifyUser: true,
                    message: "Проверьте подключение к интернету"
                )
                
            case .networkTimeout:
                return RecoveryAction(
                    action: .retry,
                    delay: 2.0,
                    shouldNotifyUser: false,
                    message: nil
                )
                
            case .serverError(let code) where code >= 500:
                return RecoveryAction(
                    action: .fallback,
                    delay: 5.0,
                    shouldNotifyUser: true,
                    message: "Сервер временно недоступен"
                )
                
            case .circuitBreakerOpen(let resourceId):
                return RecoveryAction(
                    action: .waitAndRetry,
                    delay: configuration.circuitBreakerResetTime,
                    shouldNotifyUser: true,
                    message: "Сервис \(resourceId) временно недоступен"
                )
                
            default:
                return RecoveryAction(
                    action: .fail,
                    delay: 0,
                    shouldNotifyUser: true,
                    message: "Произошла ошибка. Попробуйте позже"
                )
            }
        }
        
        // Обработка NetworkError из NetworkService
        if let networkError = error as? NetworkError {
            switch networkError {
            case .serverError(let code) where code == 429:
                return RecoveryAction(
                    action: .waitAndRetry,
                    delay: 10.0,
                    shouldNotifyUser: true,
                    message: "Слишком много запросов. Подождите немного"
                )
                
            case .serverError(let code) where code >= 500:
                return RecoveryAction(
                    action: .fallback,
                    delay: 5.0,
                    shouldNotifyUser: true,
                    message: "Проблемы на сервере"
                )
                
            case .unknown:
                return RecoveryAction(
                    action: .retry,
                    delay: 1.0,
                    shouldNotifyUser: false,
                    message: nil
                )
                
            default:
                return RecoveryAction(
                    action: .fail,
                    delay: 0,
                    shouldNotifyUser: true,
                    message: "Не удалось выполнить запрос"
                )
            }
        }
        
        // Дефолтная обработка
        return RecoveryAction(
            action: .fail,
            delay: 0,
            shouldNotifyUser: true,
            message: "Неизвестная ошибка"
        )
    }
    
    /// Выполняет операцию с circuit breaker и half-open state
    public func executeWithCircuitBreaker<T>(
        operation: () async throws -> T,
        resourceId: String
    ) async throws -> T {
        let state = getCircuitState(for: resourceId)
        
        // Проверяем состояние circuit breaker
        if state.isOpen {
            // Проверяем, не пора ли попробовать half-open
            if shouldTryHalfOpen(state: state) {
                logger.info("Trying half-open state for: \(resourceId)")
                updateCircuitState(for: resourceId) { state in
                    state.halfOpenAttempts += 1
                }
            } else {
                logger.warning("Circuit breaker is open for: \(resourceId)")
                throw RecoverableError.circuitBreakerOpen(resourceId: resourceId)
            }
        }
        
        do {
            let result = try await operation()
            resetCircuit(for: resourceId)
            logger.debug("Operation succeeded, circuit reset for: \(resourceId)")
            return result
        } catch {
            recordFailure(for: resourceId)
            logger.error("Operation failed for: \(resourceId), error: \(error)")
            throw error
        }
    }
    
    /// Проверяет открыт ли circuit breaker
    public func isCircuitOpen(for resourceId: String) -> Bool {
        return queue.sync {
            circuitStates[resourceId]?.isOpen ?? false
        }
    }
    
    /// Возвращает метрики ошибок
    public func getMetrics() -> ErrorMetrics {
        return queue.sync { metrics }
    }
    
    /// Сбрасывает все circuit breakers
    public func resetAllCircuits() {
        queue.async(flags: .barrier) {
            self.circuitStates.removeAll()
            self.logger.info("All circuit breakers reset")
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateDelay(
        attempt: Int,
        strategy: RetryStrategy
    ) -> TimeInterval {
        switch strategy {
        case .exponentialBackoff(let initialDelay):
            return pow(2.0, Double(attempt)) * initialDelay
        case .linear(let delay):
            return Double(attempt + 1) * delay
        case .immediate:
            return 0.05
        case .custom(let provider):
            return provider(attempt)
        }
    }
    
    private func getCircuitState(for resourceId: String) -> CircuitState {
        return queue.sync {
            circuitStates[resourceId] ?? CircuitState()
        }
    }
    
    private func updateCircuitState(
        for resourceId: String,
        update: @escaping (inout CircuitState) -> Void
    ) {
        queue.async(flags: .barrier) {
            var state = self.circuitStates[resourceId] ?? CircuitState()
            update(&state)
            self.circuitStates[resourceId] = state
        }
    }
    
    private func recordFailure(for resourceId: String) {
        updateCircuitState(for: resourceId) { state in
            state.failureCount += 1
            state.lastFailureTime = Date()
            
            if state.failureCount >= self.configuration.circuitBreakerThreshold {
                state.isOpen = true
                self.logger.warning("Circuit breaker opened for: \(resourceId)")
            }
        }
    }
    
    private func resetCircuit(for resourceId: String) {
        queue.async(flags: .barrier) {
            self.circuitStates[resourceId] = CircuitState()
        }
    }
    
    private func shouldTryHalfOpen(state: CircuitState) -> Bool {
        guard let lastFailure = state.lastFailureTime else { return false }
        let timeSinceFailure = Date().timeIntervalSince(lastFailure)
        return timeSinceFailure >= configuration.circuitBreakerResetTime
    }
    
    private func startCircuitBreakerResetTimer() {
        Task {
            while true {
                try? await Task.sleep(nanoseconds: UInt64(configuration.circuitBreakerResetTime * 1_000_000_000))
                checkAndResetCircuits()
            }
        }
    }
    
    private func checkAndResetCircuits() {
        queue.async(flags: .barrier) {
            let now = Date()
            
            for (resourceId, state) in self.circuitStates {
                guard state.isOpen,
                      let lastFailure = state.lastFailureTime else { continue }
                
                let timeSinceFailure = now.timeIntervalSince(lastFailure)
                if timeSinceFailure >= self.configuration.circuitBreakerResetTime * 2 {
                    self.circuitStates[resourceId] = CircuitState()
                    self.logger.info("Auto-reset circuit breaker for: \(resourceId)")
                }
            }
        }
    }
    
    private func recordSuccess(context: String, attempts: Int) {
        queue.async(flags: .barrier) {
            self.metrics.totalOperations += 1
            self.metrics.successfulRetries += 1
            self.metrics.totalRetryAttempts += attempts - 1
        }
    }
    
    private func recordFailure(context: String, error: Error?) {
        queue.async(flags: .barrier) {
            self.metrics.totalOperations += 1
            self.metrics.failedOperations += 1
        }
    }
}

/// Метрики ошибок
public struct ErrorMetrics {
    var totalOperations: Int = 0
    var successfulRetries: Int = 0
    var failedOperations: Int = 0
    var totalRetryAttempts: Int = 0
    
    var successRate: Double {
        guard totalOperations > 0 else { return 0 }
        return Double(totalOperations - failedOperations) / Double(totalOperations)
    }
    
    var averageRetryAttempts: Double {
        guard successfulRetries > 0 else { return 0 }
        return Double(totalRetryAttempts) / Double(successfulRetries)
    }
} 