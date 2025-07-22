import XCTest
@testable import LMS

final class LaunchPerformanceTests: XCTestCase {
    
    func testLaunchPerformance() throws {
        measure {
            // Simulate app launch
            let appDelegate = OptimizedAppDelegate()
            _ = appDelegate.application(
                UIApplication.shared,
                didFinishLaunchingWithOptions: nil
            )
        }
    }
    
    func testLaunchProfiler() {
        let profiler = LaunchProfiler()
        profiler.startMeasuring()
        
        // Simulate some checkpoints
        Thread.sleep(forTimeInterval: 0.1)
        profiler.checkpoint("First checkpoint")
        
        Thread.sleep(forTimeInterval: 0.2)
        profiler.checkpoint("Second checkpoint")
        
        let report = profiler.finish()
        
        XCTAssertGreaterThan(report.totalTime, 0.3)
        XCTAssertEqual(report.checkpoints.count, 2)
        XCTAssertFalse(report.isOptimal) // Should be > 0.5s
    }
    
    func testOptimalLaunch() {
        let profiler = LaunchProfiler()
        profiler.startMeasuring()
        
        // Quick operations only
        profiler.checkpoint("Setup")
        profiler.checkpoint("Start")
        
        let report = profiler.finish()
        
        // Should be very fast without sleeps
        XCTAssertLessThan(report.totalTime, 0.1)
    }
    
    func testMeasureBlock() {
        let profiler = LaunchProfiler()
        var executed = false
        
        let result = profiler.measureBlock("Test block") {
            Thread.sleep(forTimeInterval: 0.05)
            executed = true
            return 42
        }
        
        XCTAssertTrue(executed)
        XCTAssertEqual(result, 42)
    }
    
    func testMeasureAsyncBlock() async {
        let profiler = LaunchProfiler()
        var executed = false
        
        let result = await profiler.measureAsyncBlock("Async test") {
            try? await Task.sleep(nanoseconds: 50_000_000)
            executed = true
            return "Done"
        }
        
        XCTAssertTrue(executed)
        XCTAssertEqual(result, "Done")
    }
    
    func testLaunchRecommendations() {
        let slowReport = LaunchReport(
            totalTime: 1.5,
            checkpoints: [
                ("Start", 0.1),
                ("Heavy operation", 0.8),
                ("Finish", 1.5)
            ],
            isOptimal: false
        )
        
        let recommendations = slowReport.recommendations
        XCTAssertTrue(recommendations.contains("Consider lazy loading heavy resources"))
        XCTAssertTrue(recommendations.contains { $0.contains("Heavy operation") })
    }
} 