import XCTest
@testable import LMS

/// Performance tests for Cmi5 module optimization
class Cmi5PerformanceTests: XCTestCase {
    
    // MARK: - Statement Processing Performance
    
    func testStatementProcessingSpeed() {
        let processor = XAPIStatementProcessor()
        
        measure {
            let expectation = XCTestExpectation(description: "Processing")
            
            Task {
                // Process 100 statements
                for i in 1...100 {
                    let statement = createTestStatement(id: "stmt-\(i)")
                    _ = try? await processor.processStatement(statement)
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testBatchStatementProcessing() {
        let processor = XAPIStatementProcessor()
        
        // Test batch processing vs individual
        let statements = (1...1000).map { i in
            createTestStatement(id: "batch-\(i)")
        }
        
        // Individual processing
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Individual")
            
            Task {
                for statement in statements {
                    _ = try? await processor.processStatement(statement)
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - Analytics Performance
    
    func testAnalyticsCalculationTime() {
        let collector = AnalyticsCollector()
        let sessionId = "perf-session"
        
        // Prepare data
        let setupExpectation = XCTestExpectation(description: "Setup")
        
        Task {
            // Add 1000 statements
            for i in 1...1000 {
                let statement = createTestStatement(
                    verb: "progressed",
                    sessionId: sessionId,
                    progress: Float(i) / 10.0
                )
                await collector.processStatement(statement)
            }
            setupExpectation.fulfill()
        }
        
        wait(for: [setupExpectation], timeout: 10.0)
        
        // Measure analytics calculation
        measure {
            let expectation = XCTestExpectation(description: "Analytics")
            
            Task {
                _ = await collector.getMetrics(for: sessionId)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testAnalyticsAggregationPerformance() {
        let collector = AnalyticsCollector()
        
        // Setup: Create 50 sessions with 100 statements each
        let setupExpectation = XCTestExpectation(description: "Setup aggregation")
        
        Task {
            for session in 1...50 {
                for stmt in 1...100 {
                    let statement = createTestStatement(
                        verb: stmt == 100 ? "completed" : "progressed",
                        sessionId: "session-\(session)",
                        progress: Float(stmt)
                    )
                    await collector.processStatement(statement)
                }
            }
            setupExpectation.fulfill()
        }
        
        wait(for: [setupExpectation], timeout: 30.0)
        
        // Measure overall metrics calculation
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            let expectation = XCTestExpectation(description: "Overall metrics")
            
            Task {
                _ = await collector.getOverallMetrics(for: "testUser")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Report Generation Performance
    
    func testReportGenerationSpeed() {
        let generator = ReportGenerator()
        let statements = (1...500).map { i in
            createTestStatement(
                verb: "progressed",
                timestamp: Date().addingTimeInterval(TimeInterval(i * 60))
            )
        }
        
        measure {
            let expectation = XCTestExpectation(description: "Report generation")
            
            Task {
                _ = await generator.generateProgressReport(
                    for: "testUser",
                    statements: statements
                )
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testPDFGenerationPerformance() {
        let generator = ReportGenerator()
        let report = LearningReport(
            id: "perf-report",
            type: .performance,
            generatedAt: Date(),
            userId: "testUser",
            sessionId: "test-session",
            content: String(repeating: "Test content line\n", count: 100),
            format: .pdf
        )
        
        measure(metrics: [XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "PDF generation")
            
            Task {
                _ = await generator.exportToPDF(report)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Offline Store Performance
    
    func testOfflineStoreWritePerformance() {
        let store = OfflineStatementStore()
        
        measure {
            let expectation = XCTestExpectation(description: "Store write")
            
            Task {
                // Write 100 statements
                for i in 1...100 {
                    let statement = createTestStatement(id: "offline-\(i)")
                    try? await store.storeStatement(statement)
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testOfflineStoreReadPerformance() {
        let store = OfflineStatementStore()
        
        // Setup: Add statements
        let setupExpectation = XCTestExpectation(description: "Setup store")
        
        Task {
            for i in 1...1000 {
                let statement = createTestStatement(id: "read-\(i)")
                try? await store.storeStatement(statement)
            }
            setupExpectation.fulfill()
        }
        
        wait(for: [setupExpectation], timeout: 20.0)
        
        // Measure read performance
        measure {
            let expectation = XCTestExpectation(description: "Store read")
            
            Task {
                _ = await store.getPendingStatements(limit: 100)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Memory Usage Tests
    
    func testMemoryUsageUnderLoad() {
        let processor = XAPIStatementProcessor()
        let collector = AnalyticsCollector()
        
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        
        measure(metrics: [XCTMemoryMetric()], options: options) {
            let expectation = XCTestExpectation(description: "Memory test")
            
            Task {
                // Process many statements
                for i in 1...500 {
                    let statement = createTestStatement(id: "memory-\(i)")
                    if let processed = try? await processor.processStatement(statement) {
                        await collector.processStatement(processed)
                    }
                }
                
                // Force cleanup
                await collector.clearCache()
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - Concurrent Access Performance
    
    func testConcurrentAnalyticsAccess() {
        let collector = AnalyticsCollector()
        let sessionId = "concurrent-session"
        
        // Setup
        let setupExpectation = XCTestExpectation(description: "Setup concurrent")
        
        Task {
            for i in 1...100 {
                let statement = createTestStatement(
                    verb: "progressed",
                    sessionId: sessionId,
                    progress: Float(i)
                )
                await collector.processStatement(statement)
            }
            setupExpectation.fulfill()
        }
        
        wait(for: [setupExpectation], timeout: 10.0)
        
        // Measure concurrent reads
        measure {
            let expectation = XCTestExpectation(description: "Concurrent reads")
            expectation.expectedFulfillmentCount = 10
            
            // 10 concurrent reads
            for _ in 1...10 {
                Task {
                    _ = await collector.getMetrics(for: sessionId)
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestStatement(
        id: String = UUID().uuidString,
        verb: String = "interacted",
        sessionId: String = "test-session",
        progress: Float? = nil,
        timestamp: Date = Date()
    ) -> XAPIStatement {
        var extensions: [String: Any]?
        if let progress = progress {
            extensions = ["http://example.com/progress": progress]
        }
        
        return XAPIStatement(
            id: id,
            actor: XAPIActor(mbox: "test@example.com", name: "Test User"),
            verb: XAPIVerb(
                id: "http://adlnet.gov/expapi/verbs/\(verb)",
                display: ["en-US": verb]
            ),
            object: XAPIObject(
                id: "http://example.com/object",
                definition: nil
            ),
            context: XAPIContext(
                registration: UUID().uuidString,
                contextActivities: nil,
                extensions: ["http://example.com/sessionId": sessionId]
            ),
            result: extensions != nil ? XAPIResult(
                score: nil,
                success: nil,
                completion: nil,
                response: nil,
                duration: nil,
                extensions: extensions
            ) : nil,
            timestamp: timestamp
        )
    }
} 