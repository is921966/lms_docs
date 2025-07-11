//
//  SessionManager.swift
//  LMS
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import Foundation
import UIKit
import os

/// Делегат для уведомлений о событиях сессии
public protocol SessionManagerDelegate: AnyObject {
    func sessionDidStart(_ sessionId: String)
    func sessionWillExpire(in seconds: TimeInterval)
    func sessionDidExpire()
    func sessionDidRefresh()
}

/// Конфигурация для SessionManager
public struct SessionConfiguration {
    let defaultTimeout: TimeInterval
    let warningThreshold: TimeInterval
    let enablePersistence: Bool
    let maxSessionDuration: TimeInterval
    
    public static let `default` = SessionConfiguration(
        defaultTimeout: 3600,        // 1 час
        warningThreshold: 300,       // 5 минут до истечения
        enablePersistence: true,
        maxSessionDuration: 86400    // 24 часа максимум
    )
}

/// Информация о сессии
public struct SessionInfo: Codable {
    public let sessionId: String
    public let userId: String
    public let userInfo: [String: String]
    public let startTime: Date
    public let lastActivityTime: Date
    public let expiryTime: Date
    
    public var isExpired: Bool {
        return Date() > expiryTime
    }
    
    public var remainingTime: TimeInterval {
        return max(0, expiryTime.timeIntervalSinceNow)
    }
}

/// Менеджер для управления пользовательскими сессиями с расширенной функциональностью
public final class SessionManager {
    
    // MARK: - Properties
    
    /// Singleton instance
    public static let shared = SessionManager()
    
    /// Конфигурация
    private let configuration: SessionConfiguration
    
    /// Логгер
    private let logger = os.Logger(subsystem: "com.lms.app", category: "Session")
    
    /// Текущая информация о сессии
    private var sessionInfo: SessionInfo?
    
    /// Таймеры
    private var expiryTimer: Timer?
    private var warningTimer: Timer?
    private var activityTimer: Timer?
    
    /// Делегаты
    private var delegates = NSHashTable<AnyObject>.weakObjects()
    
    /// Очередь для thread-safe доступа
    private let queue = DispatchQueue(label: "com.lms.session", attributes: .concurrent)
    
    /// Ключ для UserDefaults
    private let persistenceKey = "com.lms.session.current"
    
    // MARK: - Initialization
    
    private init(configuration: SessionConfiguration = .default) {
        self.configuration = configuration
        
        // Восстанавливаем сессию если включена persistence
        if configuration.enablePersistence {
            restoreSession()
        }
        
        // Отслеживаем активность приложения
        setupActivityTracking()
    }
    
    // MARK: - Public Methods
    
    /// Начинает новую сессию
    @discardableResult
    public func startSession(
        userId: String,
        userInfo: [String: String] = [:],
        timeout: TimeInterval? = nil
    ) -> String {
        return queue.sync(flags: .barrier) {
            // Завершаем существующую сессию
            endSessionInternal()
            
            // Создаем новую сессию
            let sessionId = UUID().uuidString
            let effectiveTimeout = min(
                timeout ?? configuration.defaultTimeout,
                configuration.maxSessionDuration
            )
            
            let now = Date()
            sessionInfo = SessionInfo(
                sessionId: sessionId,
                userId: userId,
                userInfo: userInfo,
                startTime: now,
                lastActivityTime: now,
                expiryTime: now.addingTimeInterval(effectiveTimeout)
            )
            
            // Сохраняем если включена persistence
            if configuration.enablePersistence {
                saveSession()
            }
            
            // Запускаем таймеры
            setupTimers(timeout: effectiveTimeout)
            
            // Уведомляем делегаты
            notifyDelegates { $0.sessionDidStart(sessionId) }
            
            // Отправляем метрику
            MetricsCollector.shared.track(
                event: "session_started",
                type: .custom,
                parameters: [
                    "user_id": userId,
                    "timeout": effectiveTimeout
                ]
            )
            
            logger.info("Session started: \(sessionId) for user: \(userId)")
            return sessionId
        }
    }
    
    /// Проверяет активность сессии
    public func isSessionActive() -> Bool {
        return queue.sync {
            guard let info = sessionInfo else { return false }
            
            if info.isExpired {
                // Сессия истекла, завершаем ее
                queue.async(flags: .barrier) {
                    self.endSessionInternal()
                }
                return false
            }
            
            return true
        }
    }
    
    /// Завершает сессию
    public func endSession() {
        queue.async(flags: .barrier) {
            self.endSessionInternal()
        }
    }
    
    /// Обновляет время сессии
    public func refreshSession() {
        queue.async(flags: .barrier) {
            guard var info = self.sessionInfo, !info.isExpired else { return }
            
            let now = Date()
            let newExpiryTime = now.addingTimeInterval(
                min(self.configuration.defaultTimeout, self.configuration.maxSessionDuration)
            )
            
            // Обновляем информацию о сессии
            self.sessionInfo = SessionInfo(
                sessionId: info.sessionId,
                userId: info.userId,
                userInfo: info.userInfo,
                startTime: info.startTime,
                lastActivityTime: now,
                expiryTime: newExpiryTime
            )
            
            // Перезапускаем таймеры
            self.setupTimers(timeout: newExpiryTime.timeIntervalSince(now))
            
            // Сохраняем
            if self.configuration.enablePersistence {
                self.saveSession()
            }
            
            // Уведомляем
            self.notifyDelegates { $0.sessionDidRefresh() }
            
            self.logger.debug("Session refreshed: \(info.sessionId)")
        }
    }
    
    /// Получает ID текущего пользователя
    public func getCurrentUserId() -> String? {
        return queue.sync {
            isSessionActive() ? sessionInfo?.userId : nil
        }
    }
    
    /// Получает информацию о пользователе
    public func getUserInfo() -> [String: String] {
        return queue.sync {
            isSessionActive() ? sessionInfo?.userInfo ?? [:] : [:]
        }
    }
    
    /// Получает ID текущей сессии
    public func getCurrentSessionId() -> String? {
        return queue.sync {
            isSessionActive() ? sessionInfo?.sessionId : nil
        }
    }
    
    /// Получает время начала сессии
    public func getSessionStartTime() -> Date? {
        return queue.sync {
            sessionInfo?.startTime
        }
    }
    
    /// Получает полную информацию о сессии
    public func getSessionInfo() -> SessionInfo? {
        return queue.sync {
            isSessionActive() ? sessionInfo : nil
        }
    }
    
    /// Обновляет информацию о пользователе
    public func updateUserInfo(_ updates: [String: String]) {
        queue.async(flags: .barrier) {
            guard var info = self.sessionInfo, !info.isExpired else { return }
            
            var newUserInfo = info.userInfo
            newUserInfo.merge(updates) { $1 }
            
            self.sessionInfo = SessionInfo(
                sessionId: info.sessionId,
                userId: info.userId,
                userInfo: newUserInfo,
                startTime: info.startTime,
                lastActivityTime: Date(),
                expiryTime: info.expiryTime
            )
            
            if self.configuration.enablePersistence {
                self.saveSession()
            }
        }
    }
    
    /// Добавляет делегат
    public func addDelegate(_ delegate: SessionManagerDelegate) {
        queue.async(flags: .barrier) {
            self.delegates.add(delegate)
        }
    }
    
    /// Удаляет делегат
    public func removeDelegate(_ delegate: SessionManagerDelegate) {
        queue.async(flags: .barrier) {
            self.delegates.remove(delegate)
        }
    }
    
    // MARK: - Private Methods
    
    private func endSessionInternal() {
        guard let info = sessionInfo else { return }
        
        // Отменяем таймеры
        cancelTimers()
        
        // Очищаем информацию
        sessionInfo = nil
        
        // Удаляем из persistence
        if configuration.enablePersistence {
            UserDefaults.standard.removeObject(forKey: persistenceKey)
        }
        
        // Уведомляем делегаты
        notifyDelegates { $0.sessionDidExpire() }
        
        // Отправляем метрику
        let duration = Date().timeIntervalSince(info.startTime)
        MetricsCollector.shared.track(
            event: "session_ended",
            type: .custom,
            parameters: [
                "user_id": info.userId,
                "duration": duration,
                "reason": info.isExpired ? "timeout" : "manual"
            ]
        )
        
        logger.info("Session ended: \(info.sessionId) after \(duration) seconds")
    }
    
    private func setupTimers(timeout: TimeInterval) {
        cancelTimers()
        
        // Таймер истечения
        expiryTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.queue.async(flags: .barrier) {
                self?.endSessionInternal()
            }
        }
        
        // Таймер предупреждения
        let warningTime = max(0, timeout - configuration.warningThreshold)
        if warningTime > 0 {
            warningTimer = Timer.scheduledTimer(withTimeInterval: warningTime, repeats: false) { [weak self] _ in
                self?.queue.async {
                    guard let remaining = self?.sessionInfo?.remainingTime else { return }
                    self?.notifyDelegates { $0.sessionWillExpire(in: remaining) }
                    self?.logger.warning("Session will expire in \(remaining) seconds")
                }
            }
        }
        
        // Таймер отслеживания активности (каждую минуту)
        activityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.recordActivity()
        }
    }
    
    private func cancelTimers() {
        expiryTimer?.invalidate()
        expiryTimer = nil
        warningTimer?.invalidate()
        warningTimer = nil
        activityTimer?.invalidate()
        activityTimer = nil
    }
    
    private func notifyDelegates(_ block: @escaping (SessionManagerDelegate) -> Void) {
        delegates.allObjects.compactMap { $0 as? SessionManagerDelegate }.forEach { delegate in
            DispatchQueue.main.async {
                block(delegate)
            }
        }
    }
    
    private func saveSession() {
        guard let info = sessionInfo else { return }
        
        do {
            let data = try JSONEncoder().encode(info)
            UserDefaults.standard.set(data, forKey: persistenceKey)
            logger.debug("Session saved to persistence")
        } catch {
            logger.error("Failed to save session: \(error)")
        }
    }
    
    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey) else { return }
        
        do {
            let info = try JSONDecoder().decode(SessionInfo.self, from: data)
            
            if !info.isExpired {
                sessionInfo = info
                
                // Перезапускаем таймеры
                let remainingTime = info.expiryTime.timeIntervalSinceNow
                setupTimers(timeout: remainingTime)
                
                logger.info("Session restored: \(info.sessionId)")
                
                // Уведомляем делегаты
                notifyDelegates { $0.sessionDidStart(info.sessionId) }
            } else {
                // Сессия истекла, удаляем
                UserDefaults.standard.removeObject(forKey: persistenceKey)
                logger.info("Expired session removed from persistence")
            }
        } catch {
            logger.error("Failed to restore session: \(error)")
            UserDefaults.standard.removeObject(forKey: persistenceKey)
        }
    }
    
    private func setupActivityTracking() {
        // Отслеживаем активность приложения
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func appBecameActive() {
        recordActivity()
        
        // Проверяем не истекла ли сессия
        _ = isSessionActive()
    }
    
    @objc private func appWillResignActive() {
        // Сохраняем текущее состояние
        if configuration.enablePersistence {
            saveSession()
        }
    }
    
    private func recordActivity() {
        guard sessionInfo != nil else { return }
        
        MetricsCollector.shared.track(
            event: "session_activity",
            type: .custom,
            parameters: [
                "session_id": sessionInfo?.sessionId ?? "",
                "remaining_time": sessionInfo?.remainingTime ?? 0
            ]
        )
    }
} 