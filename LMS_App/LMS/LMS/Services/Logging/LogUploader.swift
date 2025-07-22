import Foundation
import UIKit

// MARK: - Log Uploader
/// Handles incremental upload of logs to server for analysis
final class LogUploader {
    
    // MARK: - Properties
    
    static let shared = LogUploader()
    
    private let uploadInterval: TimeInterval = 30 // Upload every 30 seconds
    private var uploadTimer: Timer?
    private let uploadQueue = DispatchQueue(label: "com.lms.loguploader", qos: .background)
    private var isUploading = false
    
    // Динамический URL из CloudServerManager
    private var serverEndpoint: String {
        CloudServerManager.shared.logAPIEndpoint
    }
    
    private let batchSize = 100 // Maximum logs per upload
    
    // MARK: - Initialization
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        stopIncrementalUpload()
    }
    
    // MARK: - Public Methods
    
    /// Start automatic incremental log upload
    func startIncrementalUpload() {
        uploadQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.stopIncrementalUpload()
            
            // Initial upload
            self.uploadPendingLogs()
            
            // Schedule periodic uploads
            DispatchQueue.main.async {
                self.uploadTimer = Timer.scheduledTimer(
                    withTimeInterval: self.uploadInterval,
                    repeats: true
                ) { [weak self] _ in
                    self?.uploadPendingLogs()
                }
            }
            
            ComprehensiveLogger.shared.log(.data, .info, "Log uploader started", details: [
                "interval": self.uploadInterval,
                "batchSize": self.batchSize
            ])
        }
    }
    
    /// Stop automatic log upload
    func stopIncrementalUpload() {
        uploadTimer?.invalidate()
        uploadTimer = nil
        
        ComprehensiveLogger.shared.log(.data, .info, "Log uploader stopped")
    }
    
    /// Force upload all pending logs immediately
    func forceUpload(completion: ((Bool) -> Void)? = nil) {
        uploadQueue.async { [weak self] in
            self?.uploadPendingLogs(completion: completion)
        }
    }
    
    /// Update current screen information on server
    func updateCurrentScreen(_ screenName: String) {
        // This will be included in the next log batch
        ComprehensiveLogger.shared.log(.navigation, .debug, "Current screen updated", details: [
            "screen": screenName,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Upload logs immediately (alias for forceUpload for compatibility)
    func uploadLogsImmediately() {
        forceUpload()
    }
    
    // MARK: - Private Methods
    
    private func uploadPendingLogs(completion: ((Bool) -> Void)? = nil) {
        guard !isUploading else {
            completion?(false)
            return
        }
        
        isUploading = true
        
        let logs = ComprehensiveLogger.shared.getPendingLogs(limit: batchSize)
        
        guard !logs.isEmpty else {
            isUploading = false
            completion?(true)
            return
        }
        
        ComprehensiveLogger.shared.log(.network, .debug, "Uploading logs batch", details: [
            "count": logs.count,
            "oldestLog": logs.first?.timestamp ?? Date(),
            "newestLog": logs.last?.timestamp ?? Date()
        ])
        
        // Prepare upload data
        let uploadData = LogUploadData(
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
            sessionId: ComprehensiveLogger.shared.currentSessionId,
            userId: getUserId(),
            logs: logs.map { LogUploadEntry(from: $0) }
        )
        
        // Upload to server
        Task {
            do {
                try await uploadLogsToServer(uploadData)
                
                // Mark logs as uploaded
                ComprehensiveLogger.shared.markLogsAsUploaded(logs)
                
                ComprehensiveLogger.shared.log(.network, .info, "Logs uploaded successfully", details: [
                    "count": logs.count
                ])
                
                completion?(true)
            } catch {
                ComprehensiveLogger.shared.log(.error, .error, "Failed to upload logs", details: [
                    "error": error.localizedDescription,
                    "count": logs.count
                ])
                
                // Retry logic - mark for retry
                ComprehensiveLogger.shared.markLogsForRetry(logs)
                
                completion?(false)
            }
            
            isUploading = false
        }
    }
    
    private func uploadLogsToServer(_ data: LogUploadData) async throws {
        guard let url = URL(string: serverEndpoint) else {
            throw LogUploadError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(getAuthToken(), forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(data)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LogUploadError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw LogUploadError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    private func getUserId() -> String? {
        // Get from MockAuthService or SessionManager
        return nil // Will be set when user is logged in
    }
    
    private func getAuthToken() -> String {
        return "Bearer \(TokenManager.shared.accessToken ?? "anonymous")"
    }
    
    // MARK: - App Lifecycle
    
    @objc private func appDidEnterBackground() {
        // Force upload before going to background
        forceUpload()
    }
    
    @objc private func appWillEnterForeground() {
        // Resume uploads
        if uploadTimer == nil {
            startIncrementalUpload()
        }
    }
}

// MARK: - Data Models

struct LogUploadData: Codable {
    let deviceId: String
    let sessionId: String
    let userId: String?
    let logs: [LogUploadEntry]
    let timestamp: Date
    
    init(deviceId: String, sessionId: String, userId: String?, logs: [LogUploadEntry]) {
        self.deviceId = deviceId
        self.sessionId = sessionId
        self.userId = userId
        self.logs = logs
        self.timestamp = Date()
    }
}

struct LogUploadEntry: Codable {
    let id: String
    let timestamp: Date
    let category: String
    let level: String
    let event: String
    let details: [String: String]
    let context: LogUploadContext
    
    init(from logEntry: LogEntry) {
        self.id = logEntry.id.uuidString
        self.timestamp = logEntry.timestamp
        self.category = logEntry.category.rawValue
        self.level = logEntry.level.rawValue
        self.event = logEntry.event
        
        // Convert details to string representation
        var stringDetails: [String: String] = [:]
        for (key, value) in logEntry.details {
            stringDetails[key] = String(describing: value)
        }
        self.details = stringDetails
        
        self.context = LogUploadContext(from: logEntry.context)
    }
}

struct LogUploadContext: Codable {
    let screen: String?
    let module: String?
    let userId: String?
    let sessionId: String
    let deviceModel: String
    let osVersion: String
    let appVersion: String
    
    init(from context: LogContext) {
        self.screen = context.screen
        self.module = context.module
        self.userId = context.userId
        self.sessionId = context.sessionId
        self.deviceModel = context.deviceInfo.model
        self.osVersion = context.deviceInfo.osVersion
        self.appVersion = context.deviceInfo.appVersion
    }
}

// MARK: - Errors

enum LogUploadError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .encodingError:
            return "Failed to encode logs"
        }
    }
} 