import Foundation
import SwiftUI
import CoreData

// MARK: - Log Entry Model
struct LogEntry {
    let id: UUID = UUID()
    let timestamp: Date = Date()
    let category: LogCategory
    let level: LogLevel
    let event: String
    let details: [String: Any]
    let context: LogContext
    var isUploaded: Bool = false
    var retryCount: Int = 0
}

// MARK: - Log Categories
enum LogCategory: String, Codable {
    case ui = "UI"
    case navigation = "Navigation"
    case network = "Network"
    case data = "Data"
    case performance = "Performance"
    case error = "Error"
    case user = "User"
    case system = "System"
    case auth = "Auth"
}

// MARK: - Log Levels
enum LogLevel: String, Codable, Comparable {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"  
    case error = "ERROR"
    
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        let order: [LogLevel] = [.verbose, .debug, .info, .warning, .error]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Log Context
struct LogContext {
    let screen: String
    let module: String
    let userId: String?
    let sessionId: String
    let deviceInfo: LogDeviceInfo
    let navigationStack: [String]
}

// MARK: - Device Info (renamed to avoid conflict)
struct LogDeviceInfo {
    let model: String
    let osVersion: String
    let appVersion: String
    let screenSize: String
    let orientation: String
}

// MARK: - Comprehensive Logger
class ComprehensiveLogger: ObservableObject {
    static let shared = ComprehensiveLogger()
    
    @Published private(set) var logs: [LogEntry] = []
    private let logQueue = DispatchQueue(label: "com.lms.logger", qos: .background)
    private let maxLogsInMemory = 10000
    private var sessionId = UUID().uuidString
    
    // Public getter for sessionId
    var currentSessionId: String {
        return sessionId
    }
    
    // Core Data context for persistence
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LoggingModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load log store: \(error)")
            }
        }
        return container
    }()
    
    private init() {
        setupCrashHandler()
        startPerformanceMonitoring()
    }
    
    // MARK: - Main Logging Function
    func log(_ category: LogCategory, 
             _ level: LogLevel = .info,
             _ event: String,
             details: [String: Any] = [:],
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
        
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            var enrichedDetails = details
            enrichedDetails["file"] = URL(fileURLWithPath: file).lastPathComponent
            enrichedDetails["function"] = function
            enrichedDetails["line"] = line
            
            let context = self.getCurrentContext()
            let entry = LogEntry(
                category: category,
                level: level,
                event: event,
                details: enrichedDetails,
                context: context
            )
            
            self.addLog(entry)
        }
    }
    
    // MARK: - Specialized Logging Methods
    
    func logUIEvent(_ event: String, view: String, action: String, details: [String: Any] = [:]) {
        var uiDetails = details
        uiDetails["view"] = view
        uiDetails["action"] = action
        uiDetails["timestamp"] = Date().timeIntervalSince1970
        
        log(.ui, .info, event, details: uiDetails)
    }
    
    func logNavigation(from: String, to: String, method: String, details: [String: Any] = [:]) {
        var navDetails = details
        navDetails["from"] = from
        navDetails["to"] = to
        navDetails["method"] = method
        // NavigationTracker.shared.currentStack не существует - закомментировано
        // navDetails["navigationStack"] = NavigationTracker.shared.currentStack
        
        log(.navigation, .info, "Navigation: \(from) → \(to)", details: navDetails)
    }
    
    func logNetworkRequest(_ request: URLRequest, response: URLResponse?, data: Data?, error: Error?) {
        var networkDetails: [String: Any] = [
            "url": request.url?.absoluteString ?? "",
            "method": request.httpMethod ?? "GET",
            "headers": request.allHTTPHeaderFields ?? [:],
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let body = request.httpBody {
            networkDetails["requestBody"] = String(data: body, encoding: .utf8) ?? "Binary data"
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            networkDetails["statusCode"] = httpResponse.statusCode
            networkDetails["responseHeaders"] = httpResponse.allHeaderFields
        }
        
        if let data = data {
            networkDetails["responseData"] = String(data: data, encoding: .utf8) ?? "Binary data"
        }
        
        if let error = error {
            networkDetails["error"] = error.localizedDescription
        }
        
        let level: LogLevel = error != nil ? .error : .info
        log(.network, level, "Network: \(request.httpMethod ?? "GET") \(request.url?.path ?? "")", details: networkDetails)
    }
    
    func logDataChange(_ entity: String, operation: String, before: Any?, after: Any?) {
        let details: [String: Any] = [
            "entity": entity,
            "operation": operation,
            "before": String(describing: before),
            "after": String(describing: after),
            "timestamp": Date().timeIntervalSince1970
        ]
        
        log(.data, .info, "Data Change: \(entity).\(operation)", details: details)
    }
    
    func logPerformance(_ metric: String, value: Double, unit: String = "ms") {
        let details: [String: Any] = [
            "metric": metric,
            "value": value,
            "unit": unit,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        log(.performance, .debug, "Performance: \(metric) = \(value)\(unit)", details: details)
    }
    
    // MARK: - Context Management
    
    private func getCurrentContext() -> LogContext {
        LogContext(
            screen: NavigationTracker.shared.currentScreen,
            module: "Unknown", // NavigationTracker.shared.currentModule не существует
            userId: nil, // Don't access MockAuthService here to avoid main actor issues
            sessionId: sessionId,
            deviceInfo: LogDeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                screenSize: "\(UIScreen.main.bounds.width)x\(UIScreen.main.bounds.height)",
                orientation: UIDevice.current.orientation.isPortrait ? "Portrait" : "Landscape"
            ),
            navigationStack: [] // NavigationTracker.shared.currentStack не существует
        )
    }
    
    // Helper to add user ID context when available
    func logWithUser(_ category: LogCategory, 
                     _ level: LogLevel, 
                     _ event: String, 
                     userId: String? = nil,
                     details: [String: Any]? = nil) {
        var enrichedDetails = details ?? [:]
        if let userId = userId {
            enrichedDetails["userId"] = userId
        }
        log(category, level, event, details: enrichedDetails)
    }
    
    // MARK: - Log Management
    
    private func addLog(_ entry: LogEntry) {
        DispatchQueue.main.async {
            self.logs.append(entry)
            
            // Keep memory usage under control
            if self.logs.count > self.maxLogsInMemory {
                self.logs.removeFirst(self.logs.count - self.maxLogsInMemory)
            }
        }
        
        // Persist to Core Data
        persistLog(entry)
        
        // Also write to file
        writeToFile(entry)
    }
    
    // MARK: - Persistence
    
    private func sanitizeForJSON(_ value: Any) -> Any {
        if let date = value as? Date {
            return ISO8601DateFormatter().string(from: date)
        } else if let uuid = value as? UUID {
            return uuid.uuidString
        } else if let url = value as? URL {
            return url.absoluteString
        } else if let dict = value as? [String: Any] {
            return dict.mapValues { sanitizeForJSON($0) }
        } else if let array = value as? [Any] {
            return array.map { sanitizeForJSON($0) }
        } else if let data = value as? Data {
            return data.base64EncodedString()
        } else if value is NSNull {
            return NSNull()
        } else if JSONSerialization.isValidJSONObject([value]) {
            return value
        } else {
            // Convert any non-JSON-serializable object to string
            return String(describing: value)
        }
    }
    
    private func persistLog(_ entry: LogEntry) {
        // let context = persistentContainer.viewContext  // Remove this unused variable
        
        // Create Core Data entity (you'll need to define this in your .xcdatamodeld)
        // For now, we'll skip the actual Core Data implementation
    }
    
    private func writeToFile(_ entry: LogEntry) {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let logsDirectory = documentsPath.appendingPathComponent("Logs")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "log_\(dateFormatter.string(from: Date())).json"
        let filePath = logsDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
            
            // Create a simplified version for JSON encoding
            let jsonEntry: [String: Any] = [
                "id": entry.id.uuidString,
                "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                "category": entry.category.rawValue,
                "level": entry.level.rawValue,
                "event": entry.event,
                "details": sanitizeForJSON(entry.details) as? [String: Any] ?? [:],
                "context": [
                    "screen": entry.context.screen,
                    "module": entry.context.module,
                    "userId": entry.context.userId ?? "anonymous",
                    "sessionId": entry.context.sessionId,
                    "deviceInfo": [
                        "model": entry.context.deviceInfo.model,
                        "osVersion": entry.context.deviceInfo.osVersion,
                        "appVersion": entry.context.deviceInfo.appVersion,
                        "screenSize": entry.context.deviceInfo.screenSize,
                        "orientation": entry.context.deviceInfo.orientation
                    ],
                    "navigationStack": entry.context.navigationStack
                ]
            ]
            
            let data = try JSONSerialization.data(withJSONObject: jsonEntry, options: [])
            
            if FileManager.default.fileExists(atPath: filePath.path) {
                let handle = try FileHandle(forWritingTo: filePath)
                handle.seekToEndOfFile()
                handle.write(",\n".data(using: .utf8)!)
                handle.write(data)
                handle.closeFile()
            } else {
                try ("[\n" + String(data: data, encoding: .utf8)!).write(to: filePath, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to write log: \(error)")
        }
    }
    
    // MARK: - Query Methods
    
    func getLogs(category: LogCategory? = nil, 
                 level: LogLevel? = nil,
                 since: Date? = nil,
                 containing: String? = nil) -> [LogEntry] {
        logs.filter { entry in
            (category == nil || entry.category == category) &&
            (level == nil || entry.level >= (level ?? .verbose)) &&
            (since == nil || entry.timestamp >= since!) &&
            (containing == nil || entry.event.lowercased().contains(containing!.lowercased()))
        }
    }
    
    // MARK: - Upload Support
    
    func getPendingLogs(limit: Int = 100) -> [LogEntry] {
        return Array(logs.filter { !$0.isUploaded }.prefix(limit))
    }
    
    func markLogsAsUploaded(_ uploadedLogs: [LogEntry]) {
        for log in uploadedLogs {
            if let index = logs.firstIndex(where: { $0.id == log.id }) {
                logs[index].isUploaded = true
            }
        }
    }
    
    func markLogsForRetry(_ failedLogs: [LogEntry]) {
        for log in failedLogs {
            if let index = logs.firstIndex(where: { $0.id == log.id }) {
                logs[index].retryCount += 1
            }
        }
    }
    
    func exportLogs(format: ExportFormat = .json) -> Data? {
        switch format {
        case .json:
            // Convert logs to JSON-serializable format
            let jsonLogs = logs.map { entry in
                [
                    "id": entry.id.uuidString,
                    "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                    "category": entry.category.rawValue,
                    "level": entry.level.rawValue,
                    "event": entry.event,
                    "details": entry.details
                ]
            }
            return try? JSONSerialization.data(withJSONObject: jsonLogs)
        case .csv:
            return exportAsCSV()
        }
    }
    
    private func exportAsCSV() -> Data? {
        var csv = "Timestamp,Category,Level,Event,Details,Screen,Module\n"
        
        for log in logs {
            let detailsJSON = (try? JSONSerialization.data(withJSONObject: log.details)) ?? Data()
            let detailsString = String(data: detailsJSON, encoding: .utf8) ?? ""
            
            csv += "\(log.timestamp),\(log.category.rawValue),\(log.level.rawValue),\"\(log.event)\",\"\(detailsString)\",\(log.context.screen),\(log.context.module)\n"
        }
        
        return csv.data(using: .utf8)
    }
    
    // MARK: - Crash Handler
    
    private func setupCrashHandler() {
        NSSetUncaughtExceptionHandler { exception in
            ComprehensiveLogger.shared.log(.error, .error, "Uncaught Exception", details: [
                "name": exception.name.rawValue,
                "reason": exception.reason ?? "Unknown",
                "stackTrace": exception.callStackSymbols.joined(separator: "\n")
            ])
        }
    }
    
    // MARK: - Performance Monitoring
    
    private func startPerformanceMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let memoryUsage = self.getMemoryUsage()
            let cpuUsage = self.getCPUUsage()
            
            self.logPerformance("memory_usage", value: memoryUsage, unit: "MB")
            self.logPerformance("cpu_usage", value: cpuUsage, unit: "%")
        }
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) { ptr in
            return ptr.withMemoryRebound(to: integer_t.self, capacity: 1) { ptr in
                return task_info(mach_task_self_,
                               task_flavor_t(MACH_TASK_BASIC_INFO),
                               ptr,
                               &count)
            }
        }
        
        return result == KERN_SUCCESS ? Double(info.resident_size) / 1024.0 / 1024.0 : 0
    }
    
    private func getCPUUsage() -> Double {
        // Simplified CPU usage calculation
        return 0.0 // Would need proper implementation
    }
}

enum ExportFormat {
    case json
    case csv
} 