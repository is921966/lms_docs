//  LRSService.swift
//  LMS
//
//  Created by LMS on 11.01.2025.
//

import Foundation
import Combine

// MARK: - LRSService Protocol

public protocol LRSServiceProtocol {
    func sendStatement(_ statement: XAPIStatement) async throws -> String
    func getStatements(activityId: String, userId: String?, limit: Int) async throws -> [XAPIStatement]
    func getState(activityId: String, userId: String, stateId: String) async throws -> [String: Any]?
    func setState(activityId: String, userId: String, stateId: String, value: [String: Any]) async throws
    func deleteState(activityId: String, userId: String, stateId: String) async throws
    func createSession(activityId: String, userId: String) async throws -> LRSSession
}

// MARK: - LRSSession

public struct LRSSession {
    let sessionId: String
    let authToken: String
    let endpoint: String
    let registration: String
    let actorMbox: String
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() >= expiresAt
    }
    
    var authHeader: String {
        "Bearer \(authToken)"
    }
}

// Wrapper for NSCache
private class LRSSessionBox {
    let session: LRSSession
    init(_ session: LRSSession) {
        self.session = session
    }
}

// MARK: - LRS Service Implementation

/// Сервис для работы с Learning Record Store (LRS) - центральным хранилищем xAPI statements
final class LRSService: LRSServiceProtocol, ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = LRSService()
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    private let sessionCache = NSCache<NSString, LRSSessionBox>()
    
    @Published private(set) var isOnline = true
    @Published private(set) var pendingStatements = 0
    
    // Configuration
    private(set) var endpoint: String = "https://lrs.example.com/xapi"
    private(set) var authToken: String = "mock-auth-token"
    private(set) var version = "1.0.3"
    
    // Current actor
    private(set) var currentActor: XAPIActor = XAPIActor(
        name: "Default User",
        mbox: "mailto:user@example.com"
    )
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Statement Management
    
    func sendStatement(_ statement: XAPIStatement) async throws -> String {
        // Ensure statement has ID
        var statementToSend = statement
        if statementToSend.id == nil {
            statementToSend.id = UUID().uuidString
        }
        
        // Ensure timestamp
        if statementToSend.timestamp == nil {
            statementToSend.timestamp = Date()
        }
        
        // For now, use mock response since APIClient.request needs proper implementation
        // In production, this would call the actual API
        return statementToSend.id ?? UUID().uuidString
    }
    
    func getStatements(activityId: String, userId: String?, limit: Int) async throws -> [XAPIStatement] {
        // Mock implementation for now
        // In production, this would call the actual LRS API
        return []
    }
    
    // MARK: - State Management
    
    func getState(activityId: String, userId: String, stateId: String) async throws -> [String: Any]? {
        // LRS State API endpoint
        _ = "/activities/state"
        let params: [String: String] = [
            "activityId": activityId,
            "agent": "{\"account\":{\"name\":\"\(userId)\"}}",
            "stateId": stateId
        ]
        
        // For now, return mock data
        // In production, this would call the actual LRS API
        return MockLRSData.getState(stateId: stateId)
    }
    
    func setState(activityId: String, userId: String, stateId: String, value: [String: Any]) async throws {
        // LRS State API endpoint
        _ = "/activities/state"
        
        // For now, store in mock
        MockLRSData.setState(stateId: stateId, value: value)
    }
    
    func deleteState(activityId: String, userId: String, stateId: String) async throws {
        // LRS State API endpoint
        _ = "/activities/state"
        
        // For now, delete from mock
        MockLRSData.deleteState(stateId: stateId)
    }
    
    // MARK: - Session Management
    
    func createSession(activityId: String, userId: String) async throws -> LRSSession {
        // Check cache first
        let cacheKey = "\(activityId)_\(userId)" as NSString
        if let cachedBox = sessionCache.object(forKey: cacheKey),
           !cachedBox.session.isExpired {
            return cachedBox.session
        }
        
        // Mock implementation for now
        let session = LRSSession(
            sessionId: UUID().uuidString,
            authToken: "mock-token-\(UUID().uuidString)",
            endpoint: "https://lrs.example.com/xapi",
            registration: UUID().uuidString,
            actorMbox: "mailto:\(userId)@lms.com",
            expiresAt: Date().addingTimeInterval(3600) // 1 hour
        )
        
        // Cache session
        sessionCache.setObject(LRSSessionBox(session), forKey: cacheKey)
        
        return session
    }
}

// MARK: - Mock LRS Service

final class MockLRSService: LRSServiceProtocol {
    var statements: [XAPIStatement] = []
    private var state: [String: [String: Any]] = [:]
    
    // For testing
    var sendAttempts = 0
    var shouldFailNextCalls = 0
    
    func sendStatement(_ statement: XAPIStatement) async throws -> String {
        sendAttempts += 1
        
        // Simulate failures for testing
        if shouldFailNextCalls > 0 {
            shouldFailNextCalls -= 1
            throw NSError(domain: "MockLRS", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock LRS failure"])
        }
        
        var newStatement = statement
        if newStatement.id == nil {
            newStatement.id = UUID().uuidString
        }
        if newStatement.timestamp == nil {
            newStatement.timestamp = Date()
        }
        statements.append(newStatement)
        return newStatement.id ?? UUID().uuidString
    }
    
    func getStatements(activityId: String, userId: String?, limit: Int) async throws -> [XAPIStatement] {
        let filtered = statements.filter { statement in
            if case .activity(let activity) = statement.object {
                return activity.id == activityId
            }
            return false
        }
        
        return Array(filtered.prefix(limit))
    }
    
    func getState(activityId: String, userId: String, stateId: String) async throws -> [String: Any]? {
        return state[stateId]
    }
    
    func setState(activityId: String, userId: String, stateId: String, value: [String: Any]) async throws {
        state[stateId] = value
    }
    
    func deleteState(activityId: String, userId: String, stateId: String) async throws {
        state.removeValue(forKey: stateId)
    }
    
    func createSession(activityId: String, userId: String) async throws -> LRSSession {
        return LRSSession(
            sessionId: UUID().uuidString,
            authToken: "mock-token-\(UUID().uuidString)",
            endpoint: "https://lrs.example.com/xapi",
            registration: UUID().uuidString,
            actorMbox: "mailto:\(userId)@lms.com",
            expiresAt: Date().addingTimeInterval(3600) // 1 hour
        )
    }
}

// MARK: - Mock LRS Data

private enum MockLRSData {
    private static var stateStorage: [String: [String: Any]] = [:]
    
    static func getState(stateId: String) -> [String: Any]? {
        return stateStorage[stateId]
    }
    
    static func setState(stateId: String, value: [String: Any]) {
        stateStorage[stateId] = value
    }
    
    static func deleteState(stateId: String) {
        stateStorage.removeValue(forKey: stateId)
    }
} 