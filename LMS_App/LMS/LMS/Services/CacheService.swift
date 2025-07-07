//
//  CacheService.swift
//  LMS
//
//  Created on Sprint 39 - TDD Excellence
//

import Foundation

/// Сервис для кеширования данных в памяти с поддержкой TTL и thread-safety
/// 
/// Основные возможности:
/// - Thread-safe операции чтения/записи
/// - Автоматическое удаление просроченных записей
/// - Ограничение размера кеша
/// - Поддержка generic типов
///
/// - Note: Использует concurrent queue для оптимизации производительности
/// - Since: v2.0.0
public final class CacheService {
    
    // MARK: - Types
    
    private struct CacheEntry {
        let value: Any
        let expiry: Date?
        let size: Int
        
        var isExpired: Bool {
            guard let expiry = expiry else { return false }
            return expiry < Date()
        }
    }
    
    // MARK: - Properties
    
    private var storage: [String: CacheEntry] = [:]
    private let queue = DispatchQueue(label: "com.lms.cache", attributes: .concurrent)
    
    /// Максимальный размер кеша в элементах
    public let maxCacheSize: Int
    
    /// Стандартное время жизни записей (если не указано явно)
    public let defaultTTL: TimeInterval
    
    /// Текущий размер кеша (количество элементов)
    public var cacheSize: Int {
        queue.sync { storage.count }
    }
    
    /// Текущий размер кеша в байтах (приблизительный)
    public var cacheSizeInBytes: Int {
        queue.sync { 
            storage.values.reduce(0) { $0 + $1.size }
        }
    }
    
    // MARK: - Initialization
    
    /// Инициализирует сервис кеширования
    /// - Parameters:
    ///   - maxCacheSize: Максимальное количество элементов в кеше (по умолчанию 1000)
    ///   - defaultTTL: Время жизни записей по умолчанию в секундах (по умолчанию 3600 = 1 час)
    public init(maxCacheSize: Int = 1000, defaultTTL: TimeInterval = 3600) {
        self.maxCacheSize = maxCacheSize
        self.defaultTTL = defaultTTL
        
        // Запускаем периодическую очистку просроченных записей
        startExpirationTimer()
    }
    
    // MARK: - Public Methods
    
    /// Сохраняет значение в кеш
    /// - Parameters:
    ///   - value: Значение для сохранения
    ///   - key: Ключ для доступа к значению
    ///   - ttl: Время жизни в секундах (nil = используется defaultTTL)
    public func set<T>(_ value: T, for key: String, ttl: TimeInterval? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let effectiveTTL = ttl ?? self.defaultTTL
            let expiry = Date().addingTimeInterval(effectiveTTL)
            
            // Оцениваем размер объекта (упрощенно)
            let size = MemoryLayout<T>.size
            
            // Создаем запись
            let entry = CacheEntry(value: value, expiry: expiry, size: size)
            
            // Проверяем лимит кеша
            if self.storage.count >= self.maxCacheSize {
                self.evictOldestEntry()
            }
            
            self.storage[key] = entry
        }
    }
    
    /// Получает значение из кеша
    /// - Parameters:
    ///   - type: Тип ожидаемого значения
    ///   - key: Ключ для поиска
    /// - Returns: Значение из кеша или nil если не найдено/просрочено
    public func get<T>(_ type: T.Type, for key: String) -> T? {
        queue.sync {
            guard let entry = storage[key] else { return nil }
            
            // Проверяем срок действия
            if entry.isExpired {
                // Удаляем просроченное значение асинхронно
                queue.async(flags: .barrier) { [weak self] in
                    self?.storage.removeValue(forKey: key)
                }
                return nil
            }
            
            return entry.value as? T
        }
    }
    
    /// Удаляет значение из кеша
    /// - Parameter key: Ключ для удаления
    public func remove(for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.storage.removeValue(forKey: key)
        }
    }
    
    /// Очищает весь кеш
    public func clearAll() {
        queue.async(flags: .barrier) { [weak self] in
            self?.storage.removeAll()
        }
    }
    
    /// Проверяет наличие ключа в кеше
    /// - Parameter key: Ключ для проверки
    /// - Returns: true если ключ существует и не просрочен
    public func contains(_ key: String) -> Bool {
        queue.sync {
            guard let entry = storage[key] else { return false }
            return !entry.isExpired
        }
    }
    
    // MARK: - Private Methods
    
    private func evictOldestEntry() {
        // Удаляем самую старую запись (простая LRU стратегия)
        if let oldestKey = storage.keys.first {
            storage.removeValue(forKey: oldestKey)
        }
    }
    
    private func startExpirationTimer() {
        // Запускаем таймер для периодической очистки просроченных записей
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.removeExpiredEntries()
        }
    }
    
    private func removeExpiredEntries() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let expiredKeys = self.storage.compactMap { key, entry in
                entry.isExpired ? key : nil
            }
            
            expiredKeys.forEach { key in
                self.storage.removeValue(forKey: key)
            }
        }
    }
} 