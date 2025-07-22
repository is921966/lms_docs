import Foundation
import SwiftUI

// MARK: - Test Assertion
struct TestAssertion {
    let description: String
    let condition: (LogEntry) -> Bool
    let timeout: TimeInterval
    
    init(_ description: String, timeout: TimeInterval = 5.0, condition: @escaping (LogEntry) -> Bool) {
        self.description = description
        self.condition = condition
        self.timeout = timeout
    }
}

// MARK: - Test Result
struct AutomatedTestResult: Codable {
    let testName: String
    let passed: Bool
    let message: String
    let logsCount: Int // Instead of storing actual LogEntry objects
    let duration: TimeInterval
    
    var summary: String {
        "\(passed ? "✅" : "❌") \(testName): \(message) (\(String(format: "%.2f", duration))s)"
    }
    
    // Original initializer for internal use
    init(testName: String, passed: Bool, message: String, logs: [LogEntry], duration: TimeInterval) {
        self.testName = testName
        self.passed = passed
        self.message = message
        self.logsCount = logs.count
        self.duration = duration
    }
}

// MARK: - Automated Test Runner
class AutomatedTestRunner {
    static let shared = AutomatedTestRunner()
    private let logger = ComprehensiveLogger.shared
    
    private init() {}
    
    // MARK: - Test Execution
    
    func runTest(_ testName: String, steps: [TestStep]) async -> AutomatedTestResult {
        let startTime = Date()
        var testLogs: [LogEntry] = []
        
        print("🧪 Running test: \(testName)")
        
        for (index, step) in steps.enumerated() {
            print("  Step \(index + 1): \(step.description)")
            
            // Clear logs before step
            let stepStartTime = Date()
            
            // Execute the step
            await step.action()
            
            // Wait for assertions
            let (success, message, logs) = await waitForAssertion(
                step.assertion,
                timeout: step.assertion.timeout,
                since: stepStartTime
            )
            
            testLogs.append(contentsOf: logs)
            
            if !success {
                let duration = Date().timeIntervalSince(startTime)
                return AutomatedTestResult(
                    testName: testName,
                    passed: false,
                    message: "Failed at step \(index + 1): \(message)",
                    logs: testLogs,
                    duration: duration
                )
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        return AutomatedTestResult(
            testName: testName,
            passed: true,
            message: "All \(steps.count) steps passed",
            logs: testLogs,
            duration: duration
        )
    }
    
    // MARK: - Assertion Helpers
    
    private func waitForAssertion(_ assertion: TestAssertion, 
                                  timeout: TimeInterval,
                                  since: Date) async -> (success: Bool, message: String, logs: [LogEntry]) {
        let deadline = Date().addingTimeInterval(timeout)
        var relevantLogs: [LogEntry] = []
        
        while Date() < deadline {
            // Get logs since the step started
            relevantLogs = logger.getLogs(since: since)
            
            // Check if any log matches the assertion
            if let matchingLog = relevantLogs.first(where: assertion.condition) {
                return (true, "Assertion passed: \(assertion.description)", relevantLogs)
            }
            
            // Wait a bit before checking again
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        return (false, "Timeout waiting for: \(assertion.description)", relevantLogs)
    }
    
    // MARK: - Common Assertions
    
    static func assertNavigatedTo(_ screen: String) -> TestAssertion {
        TestAssertion("Navigated to \(screen)") { log in
            log.category == .navigation && 
            log.event.contains("→ \(screen)")
        }
    }
    
    static func assertButtonTapped(_ buttonName: String) -> TestAssertion {
        TestAssertion("Button '\(buttonName)' was tapped") { log in
            log.category == .ui &&
            log.event == "Button Tap" &&
            (log.details["buttonName"] as? String) == buttonName
        }
    }
    
    static func assertTextEntered(_ fieldName: String, value: String) -> TestAssertion {
        TestAssertion("Text '\(value)' entered in '\(fieldName)'") { log in
            log.category == .ui &&
            log.event == "Text Input" &&
            (log.details["fieldName"] as? String) == fieldName &&
            (log.details["newValue"] as? String) == value
        }
    }
    
    static func assertNetworkRequest(_ endpoint: String, statusCode: Int? = nil) -> TestAssertion {
        TestAssertion("Network request to \(endpoint)" + (statusCode != nil ? " with status \(statusCode!)" : "")) { log in
            guard log.category == .network else { return false }
            guard let url = log.details["url"] as? String,
                  url.contains(endpoint) else { return false }
            
            if let expectedCode = statusCode,
               let actualCode = log.details["statusCode"] as? Int {
                return actualCode == expectedCode
            }
            
            return true
        }
    }
    
    static func assertDataChanged(_ entity: String, operation: String) -> TestAssertion {
        TestAssertion("Data change: \(entity).\(operation)") { log in
            log.category == .data &&
            (log.details["entity"] as? String) == entity &&
            (log.details["operation"] as? String) == operation
        }
    }
    
    static func assertViewState(_ view: String, state: [String: Any]) -> TestAssertion {
        TestAssertion("View '\(view)' has state: \(state)") { log in
            guard log.category == .ui,
                  log.event == "View State",
                  (log.details["viewName"] as? String) == view else { return false }
            
            // Check if all expected state values match
            for (key, expectedValue) in state {
                guard let actualValue = log.details[key] else { return false }
                // Simple equality check (would need more sophisticated comparison for complex types)
                if "\(actualValue)" != "\(expectedValue)" { return false }
            }
            
            return true
        }
    }
    
    static func assertError(_ errorType: String? = nil) -> TestAssertion {
        TestAssertion("Error occurred" + (errorType != nil ? " of type \(errorType!)" : "")) { log in
            guard log.level == .error else { return false }
            
            if let expectedType = errorType {
                return (log.details["errorType"] as? String) == expectedType
            }
            
            return true
        }
    }
    
    static func assertNoErrors() -> TestAssertion {
        TestAssertion("No errors occurred", timeout: 1.0) { log in
            log.level == .error
        }
    }
}

// MARK: - Test Step
struct TestStep {
    let description: String
    let action: () async -> Void
    let assertion: TestAssertion
    
    init(_ description: String, 
         action: @escaping () async -> Void,
         assertion: TestAssertion) {
        self.description = description
        self.action = action
        self.assertion = assertion
    }
}

// MARK: - Test Suite
class TestSuite {
    private var tests: [(String, [TestStep])] = []
    private let runner = AutomatedTestRunner.shared
    
    func addTest(_ name: String, steps: [TestStep]) {
        tests.append((name, steps))
    }
    
    func runAll() async -> [AutomatedTestResult] {
        print("\n🚀 Running Test Suite with \(tests.count) tests\n")
        
        var results: [AutomatedTestResult] = []
        
        for (name, steps) in tests {
            let result = await runner.runTest(name, steps: steps)
            results.append(result)
            print(result.summary)
        }
        
        let passed = results.filter { $0.passed }.count
        let failed = results.count - passed
        
        print("\n📊 Test Summary: \(passed) passed, \(failed) failed\n")
        
        if failed > 0 {
            print("Failed tests:")
            for result in results.filter({ !$0.passed }) {
                print("  - \(result.testName): \(result.message)")
                print("    Logs count: \(result.logsCount)")
            }
        }
        
        return results
    }
    
    func exportResults(_ results: [AutomatedTestResult], to url: URL) throws {
        let report = TestReport(
            timestamp: Date(),
            totalTests: results.count,
            passed: results.filter { $0.passed }.count,
            failed: results.filter { !$0.passed }.count,
            results: results
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(report)
        try data.write(to: url)
    }
}

// MARK: - Test Report
struct TestReport: Codable {
    let timestamp: Date
    let totalTests: Int
    let passed: Int
    let failed: Int
    let results: [AutomatedTestResult]
} 