import Foundation

struct AppConfig {
    static let shared = AppConfig()
    
    let apiBaseURL: String = "https://api.lms.example.com"
    let isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    private init() {}
}
