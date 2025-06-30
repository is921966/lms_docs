//
//  Logger.swift
//  LMS
//
//  Created by AI Assistant on 01/30/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation
import os.log

/// Централизованный сервис логирования для приложения
public final class Logger {
    // MARK: - Types
    
    public enum Level: String {
        case debug = "🐛 DEBUG"
        case info = "ℹ️ INFO"
        case warning = "⚠️ WARNING"
        case error = "❌ ERROR"
        case success = "✅ SUCCESS"
        case network = "🌐 NETWORK"
    }
    
    public enum Category: String {
        case app = "app"
        case auth = "auth"
        case network = "network"
        case feedback = "feedback"
        case ui = "ui"
        case data = "data"
        case test = "test"
    }
    
    // MARK: - Properties
    
    public static let shared = Logger()
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.lms.app"
    private var osLogs: [Category: OSLog] = [:]
    
    // MARK: - Initialization
    
    private init() {
        // Инициализируем OSLog для каждой категории
        Category.allCases.forEach { category in
            osLogs[category] = OSLog(subsystem: subsystem, category: category.rawValue)
        }
    }
    
    // MARK: - Public Methods
    
    public func debug(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func success(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .success, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func network(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .network, message: message, category: .network, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private func log(level: Level, message: String, category: Category, file: String, function: String, line: Int) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        #if DEBUG
        // В Debug режиме выводим и в консоль для удобства разработки
        print("\(level.rawValue) \(logMessage)")
        #endif
        
        // Используем OSLog для production логирования
        guard let osLog = osLogs[category] else { return }
        
        switch level {
        case .debug:
            os_log(.debug, log: osLog, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: osLog, "%{public}@", logMessage)
        case .warning:
            os_log(.default, log: osLog, "%{public}@", logMessage)
        case .error:
            os_log(.error, log: osLog, "%{public}@", logMessage)
        case .success:
            os_log(.info, log: osLog, "%{public}@", logMessage)
        case .network:
            os_log(.info, log: osLog, "%{public}@", logMessage)
        }
    }
}

// MARK: - Category Extension

extension Logger.Category: CaseIterable {}

// MARK: - Convenience Methods

public extension Logger {
    /// Логирование с измерением времени выполнения
    static func measure<T>(
        _ title: String,
        category: Category = .app,
        operation: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            Logger.shared.info("\(title) completed in \(String(format: "%.2f", duration))s", category: category)
        }
        return try operation()
    }
    
    /// Логирование с измерением времени выполнения (async)
    static func measure<T>(
        _ title: String,
        category: Category = .app,
        operation: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            Logger.shared.info("\(title) completed in \(String(format: "%.2f", duration))s", category: category)
        }
        return try await operation()
    }
}
