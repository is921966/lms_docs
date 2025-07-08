import XCTest
import Combine
@testable import LMS

/// Integration tests for the complete Cmi5 module flow
class Cmi5IntegrationTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Full Flow Tests
    
    func testCompleteCmi5CourseFlow() {
        // Given: A complete Cmi5 setup
        let package = createTestPackage()
        let launcher = Cmi5Launcher()
        let processor = XAPIStatementProcessor()
        let offlineStore = OfflineStatementStore()
        let syncManager = SyncManager(offlineStore: offlineStore)
        let collector = AnalyticsCollector()
        let reportGenerator = ReportGenerator()
        
        let expectation = XCTestExpectation(description: "Complete flow")
        var launchData: LaunchData?
        var statements: [XAPIStatement] = []
        var metrics: LearningMetrics?
        var report: LearningReport?
        
        // When: Running the complete flow
        Task {
            // 1. Launch course
            launchData = try await launcher.launchCourse(
                package: package,
                auIndex: 0,
                learnerInfo: createTestLearnerInfo()
            )
            
            XCTAssertNotNil(launchData)
            XCTAssertEqual(launchData?.sessionId.count, 36) // UUID format
            
            // 2. Create and process statements
            let statement1 = createTestStatement(verb: "initialized", sessionId: launchData!.sessionId)
            let statement2 = createTestStatement(verb: "progressed", sessionId: launchData!.sessionId)
            let statement3 = createTestStatement(verb: "completed", sessionId: launchData!.sessionId)
            
            for statement in [statement1, statement2, statement3] {
                let processed = try await processor.processStatement(statement)
                statements.append(processed)
                
                // Store offline
                try await offlineStore.storeStatement(processed)
            }
            
            XCTAssertEqual(statements.count, 3)
            
            // 3. Sync statements
            let syncResult = await syncManager.syncStatements()
            XCTAssertEqual(syncResult.successCount, 3)
            XCTAssertEqual(syncResult.failureCount, 0)
            
            // 4. Collect analytics
            await collector.collectMetrics(for: launchData!.sessionId)
            metrics = await collector.getMetrics(for: launchData!.sessionId)
            
            XCTAssertNotNil(metrics)
            XCTAssertEqual(metrics?.completionRate, 100.0)
            XCTAssertEqual(metrics?.statementCount, 3)
            
            // 5. Generate report
            report = await reportGenerator.generateProgressReport(
                for: "testUser",
                sessionId: launchData!.sessionId
            )
            
            XCTAssertNotNil(report)
            XCTAssertEqual(report?.type, .progress)
            XCTAssertTrue(report?.content.contains("100%") ?? false)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testOfflineToOnlineTransition() {
        // Given: Offline mode with pending statements
        let offlineStore = OfflineStatementStore()
        let syncManager = SyncManager(offlineStore: offlineStore)
        let expectation = XCTestExpectation(description: "Offline to online")
        
        Task {
            // When: Creating statements offline
            let statements = (1...5).map { i in
                createTestStatement(verb: "progressed", progress: Float(i) * 20)
            }
            
            for statement in statements {
                try await offlineStore.storeStatement(statement)
            }
            
            let pendingCount = await offlineStore.getPendingCount()
            XCTAssertEqual(pendingCount, 5)
            
            // Then: Going online and syncing
            let syncResult = await syncManager.syncStatements()
            XCTAssertEqual(syncResult.successCount, 5)
            
            let remainingCount = await offlineStore.getPendingCount()
            XCTAssertEqual(remainingCount, 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentStatementProcessing() {
        // Given: Multiple concurrent statement submissions
        let processor = XAPIStatementProcessor()
        let offlineStore = OfflineStatementStore()
        let expectation = XCTestExpectation(description: "Concurrent processing")
        
        Task {
            // When: Processing 10 statements concurrently
            let statements = (1...10).map { i in
                createTestStatement(verb: "interacted", objectId: "object\(i)")
            }
            
            let results = await withTaskGroup(of: XAPIStatement?.self) { group in
                for statement in statements {
                    group.addTask {
                        try? await processor.processStatement(statement)
                    }
                }
                
                var processed: [XAPIStatement] = []
                for await result in group {
                    if let statement = result {
                        processed.append(statement)
                        try? await offlineStore.storeStatement(statement)
                    }
                }
                return processed
            }
            
            XCTAssertEqual(results.count, 10)
            
            let storedCount = await offlineStore.getPendingCount()
            XCTAssertEqual(storedCount, 10)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAnalyticsAggregation() {
        // Given: Multiple sessions with statements
        let collector = AnalyticsCollector()
        let expectation = XCTestExpectation(description: "Analytics aggregation")
        
        Task {
            // When: Creating data for 3 sessions
            for sessionNum in 1...3 {
                let sessionId = "session\(sessionNum)"
                let statementCount = sessionNum * 2 // 2, 4, 6 statements
                
                for i in 1...statementCount {
                    let statement = createTestStatement(
                        verb: i == statementCount ? "completed" : "progressed",
                        sessionId: sessionId,
                        progress: Float(i) / Float(statementCount) * 100
                    )
                    await collector.processStatement(statement)
                }
            }
            
            // Then: Checking aggregated metrics
            let overallMetrics = await collector.getOverallMetrics(for: "testUser")
            
            XCTAssertEqual(overallMetrics.totalSessions, 3)
            XCTAssertEqual(overallMetrics.totalStatements, 12) // 2+4+6
            XCTAssertEqual(overallMetrics.completedSessions, 3)
            XCTAssertEqual(overallMetrics.averageCompletionRate, 100.0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testReportGenerationPerformance() {
        // Given: Large dataset for performance testing
        let reportGenerator = ReportGenerator()
        let expectation = XCTestExpectation(description: "Report performance")
        
        measure {
            Task {
                // When: Generating report with many data points
                let statements = (1...100).map { i in
                    createTestStatement(
                        verb: "progressed",
                        timestamp: Date().addingTimeInterval(TimeInterval(i * 60))
                    )
                }
                
                let report = await reportGenerator.generatePerformanceReport(
                    for: "testUser",
                    statements: statements
                )
                
                XCTAssertNotNil(report)
                XCTAssertTrue(report.content.count > 1000)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorRecoveryFlow() {
        // Given: Components with potential errors
        let launcher = Cmi5Launcher()
        let processor = XAPIStatementProcessor()
        let syncManager = SyncManager(offlineStore: OfflineStatementStore())
        let expectation = XCTestExpectation(description: "Error recovery")
        
        Task {
            // When: Simulating various errors
            
            // 1. Invalid package error
            do {
                _ = try await launcher.launchCourse(
                    package: Cmi5Package(manifest: Cmi5Manifest(course: Cmi5Course(id: "", title: []))),
                    auIndex: 99, // Invalid index
                    learnerInfo: createTestLearnerInfo()
                )
                XCTFail("Should throw error")
            } catch {
                XCTAssertTrue(error is Cmi5LauncherError)
            }
            
            // 2. Statement validation error
            let invalidStatement = XAPIStatement(
                id: "",  // Invalid empty ID
                actor: XAPIActor(mbox: "test@example.com", name: "Test"),
                verb: XAPIVerb(id: "http://adlnet.gov/expapi/verbs/progressed", display: ["en-US": "progressed"]),
                object: XAPIObject(id: "http://example.com/object", definition: nil),
                timestamp: Date()
            )
            
            do {
                _ = try await processor.processStatement(invalidStatement)
                XCTFail("Should throw validation error")
            } catch {
                XCTAssertTrue(error is XAPIError)
            }
            
            // 3. Sync failure recovery
            let syncResult = await syncManager.syncStatements()
            XCTAssertEqual(syncResult.successCount, 0) // No statements to sync
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - UI Integration Tests
    
    func testUIComponentsIntegration() {
        // This would typically be in UI tests, but checking view model integration
        let viewModel = Cmi5PlayerViewModel()
        let expectation = XCTestExpectation(description: "UI integration")
        
        // Monitor state changes
        viewModel.$playerState
            .dropFirst()
            .sink { state in
                switch state {
                case .ready:
                    // Launch course
                    viewModel.launchCourse()
                case .launching:
                    // Expected transitional state
                    break
                case .playing:
                    // Verify launch data
                    XCTAssertNotNil(viewModel.currentSession)
                    expectation.fulfill()
                case .error:
                    XCTFail("Unexpected error state")
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Start the flow
        viewModel.loadPackage(createTestPackage())
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestPackage() -> Cmi5Package {
        let course = Cmi5Course(
            id: "test-course",
            title: ["en-US": "Test Course"]
        )
        
        let au = Cmi5AU(
            id: "test-au",
            title: ["en-US": "Test AU"],
            url: "http://example.com/au",
            launchMethod: "OwnWindow",
            masteryScore: 0.8
        )
        
        let manifest = Cmi5Manifest(
            course: course,
            aus: [au]
        )
        
        return Cmi5Package(manifest: manifest)
    }
    
    private func createTestLearnerInfo() -> LearnerInfo {
        return LearnerInfo(
            id: "testUser",
            name: "Test User",
            email: "test@example.com"
        )
    }
    
    private func createTestStatement(
        verb: String,
        objectId: String = "http://example.com/object",
        sessionId: String = "test-session",
        progress: Float? = nil,
        timestamp: Date = Date()
    ) -> XAPIStatement {
        var extensions: [String: Any]?
        if let progress = progress {
            extensions = ["http://example.com/progress": progress]
        }
        
        return XAPIStatement(
            id: UUID().uuidString,
            actor: XAPIActor(mbox: "test@example.com", name: "Test User"),
            verb: XAPIVerb(
                id: "http://adlnet.gov/expapi/verbs/\(verb)",
                display: ["en-US": verb]
            ),
            object: XAPIObject(id: objectId, definition: nil),
            context: XAPIContext(
                registration: UUID().uuidString,
                contextActivities: nil,
                extensions: ["http://example.com/sessionId": sessionId]
            ),
            result: progress != nil ? XAPIResult(
                score: nil,
                success: progress == 100,
                completion: progress == 100,
                response: nil,
                duration: nil,
                extensions: extensions
            ) : nil,
            timestamp: timestamp
        )
    }
} 