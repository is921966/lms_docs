import Foundation
import os

final class LaunchProfiler {
    
    static let shared = LaunchProfiler()
    
    private let logger = os.Logger(subsystem: "com.tsum.lms", category: "LaunchProfiler")
    private var startTime: CFAbsoluteTime = 0
    private var checkpoints: [(name: String, time: CFAbsoluteTime)] = []
    
    private init() {}
    
    func startMeasuring() {
        startTime = CFAbsoluteTimeGetCurrent()
        logger.info("Launch profiling started")
    }
    
    func checkpoint(_ name: String) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsed = currentTime - startTime
        checkpoints.append((name: name, time: elapsed))
        
        logger.info("Checkpoint '\(name)': \(String(format: "%.3f", elapsed))s")
    }
    
    func finish() -> LaunchReport {
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        
        let report = LaunchReport(
            totalTime: totalTime,
            checkpoints: checkpoints,
            isOptimal: totalTime < 0.5
        )
        
        logger.info("Launch completed in \(String(format: "%.3f", totalTime))s")
        printReport(report)
        
        return report
    }
    
    private func printReport(_ report: LaunchReport) {
        print("\n=== Launch Performance Report ===")
        print("Total time: \(String(format: "%.3f", report.totalTime))s")
        print("Status: \(report.isOptimal ? "✅ OPTIMAL" : "⚠️ NEEDS OPTIMIZATION")")
        print("\nCheckpoints:")
        
        var previousTime: CFAbsoluteTime = 0
        for checkpoint in report.checkpoints {
            let delta = checkpoint.time - previousTime
            print("  \(checkpoint.name): \(String(format: "%.3f", checkpoint.time))s (+\(String(format: "%.3f", delta))s)")
            previousTime = checkpoint.time
        }
        
        print("================================\n")
    }
    
    // MARK: - Optimization Helpers
    
    func measureBlock<T>(_ name: String, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        logger.debug("Block '\(name)' executed in \(String(format: "%.3f", elapsed))s")
        
        return result
    }
    
    func measureAsyncBlock<T>(_ name: String, block: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        logger.debug("Async block '\(name)' executed in \(String(format: "%.3f", elapsed))s")
        
        return result
    }
}

struct LaunchReport {
    let totalTime: CFAbsoluteTime
    let checkpoints: [(name: String, time: CFAbsoluteTime)]
    let isOptimal: Bool
    
    var formattedTotalTime: String {
        String(format: "%.3f", totalTime)
    }
    
    var recommendations: [String] {
        var recommendations: [String] = []
        
        if totalTime > 1.0 {
            recommendations.append("Consider lazy loading heavy resources")
        }
        
        // Check for slow checkpoints
        var previousTime: CFAbsoluteTime = 0
        for checkpoint in checkpoints {
            let delta = checkpoint.time - previousTime
            if delta > 0.2 {
                recommendations.append("Optimize '\(checkpoint.name)' - took \(String(format: "%.3f", delta))s")
            }
            previousTime = checkpoint.time
        }
        
        if checkpoints.count > 10 {
            recommendations.append("Too many initialization steps - consider consolidation")
        }
        
        return recommendations
    }
} 