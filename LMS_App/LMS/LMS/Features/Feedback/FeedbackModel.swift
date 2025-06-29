import Foundation
import UIKit

struct FeedbackModel: Codable {
    let id: UUID
    let type: String
    let text: String
    let screenshot: String?
    let deviceInfo: DeviceInfo
    let timestamp: Date
    let userId: String?
    let userEmail: String?
    let appContext: AppContext?
    
    init(
        id: UUID = UUID(),
        type: String,
        text: String,
        screenshot: String? = nil,
        deviceInfo: DeviceInfo,
        timestamp: Date = Date(),
        userId: String? = nil,
        userEmail: String? = nil,
        appContext: AppContext? = nil
    ) {
        self.id = id
        self.type = type
        self.text = text
        self.screenshot = screenshot
        self.deviceInfo = deviceInfo
        self.timestamp = timestamp
        self.userId = userId
        self.userEmail = userEmail
        self.appContext = appContext
    }
}

struct AppContext: Codable {
    let currentScreen: String?
    let previousScreen: String?
    let sessionDuration: TimeInterval?
    let memoryUsage: Int64?
    let batteryLevel: Float?
    
    static func current() -> AppContext {
        let memoryUsage = getMemoryUsage()
        let batteryLevel = UIDevice.current.isBatteryMonitoringEnabled ? UIDevice.current.batteryLevel : nil
        
        return AppContext(
            currentScreen: nil, // Should be set by the calling view
            previousScreen: nil,
            sessionDuration: nil,
            memoryUsage: memoryUsage,
            batteryLevel: batteryLevel
        )
    }
    
    private static func getMemoryUsage() -> Int64? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return result == KERN_SUCCESS ? Int64(info.resident_size) : nil
    }
} 