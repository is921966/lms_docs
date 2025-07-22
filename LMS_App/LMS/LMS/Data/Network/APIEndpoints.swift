import Foundation

enum APIEndpoints {
    
    // MARK: - Base URLs
    private static let baseURL = "https://api.lms.tsum.ru" // TODO: Replace with AppConfig when implemented
    private static let apiVersion = "/api/v1"
    
    // MARK: - Auth Service
    enum Auth {
        static let base = "\(baseURL)\(apiVersion)/auth"
        
        static let login = "\(base)/login"
        static let refresh = "\(base)/refresh"
        static let logout = "\(base)/logout"
        static let me = "\(base)/me"
        static let changePassword = "\(base)/change-password"
        static let forgotPassword = "\(base)/forgot-password"
        static let resetPassword = "\(base)/reset-password"
    }
    
    // MARK: - User Service
    enum Users {
        static let base = "\(baseURL)\(apiVersion)/users"
        
        static func user(id: String) -> String {
            return "\(base)/\(id)"
        }
        
        static func profile(userId: String) -> String {
            return "\(base)/\(userId)/profile"
        }
        
        static func avatar(userId: String) -> String {
            return "\(base)/\(userId)/avatar"
        }
        
        static func roles(userId: String) -> String {
            return "\(base)/\(userId)/roles"
        }
        
        static let search = "\(base)/search"
        static let bulk = "\(base)/bulk"
    }
    
    // MARK: - Course Service
    enum Courses {
        static let base = "\(baseURL)\(apiVersion)/courses"
        
        static func course(id: String) -> String {
            return "\(base)/\(id)"
        }
        
        static func modules(courseId: String) -> String {
            return "\(base)/\(courseId)/modules"
        }
        
        static func enroll(courseId: String) -> String {
            return "\(base)/\(courseId)/enroll"
        }
        
        static func progress(courseId: String) -> String {
            return "\(base)/\(courseId)/progress"
        }
        
        static func certificate(courseId: String) -> String {
            return "\(base)/\(courseId)/certificate"
        }
        
        static let search = "\(base)/search"
        static let categories = "\(base)/categories"
        static let recommended = "\(base)/recommended"
        static let trending = "\(base)/trending"
        
        // CMI5 specific
        static let cmi5Import = "\(base)/cmi5/import"
        static func cmi5Launch(courseId: String, activityId: String) -> String {
            return "\(base)/\(courseId)/cmi5/launch/\(activityId)"
        }
    }
    
    // MARK: - Competency Service
    enum Competencies {
        static let base = "\(baseURL)\(apiVersion)/competencies"
        
        static func competency(id: String) -> String {
            return "\(base)/\(id)"
        }
        
        static func levels(competencyId: String) -> String {
            return "\(base)/\(competencyId)/levels"
        }
        
        static func userCompetencies(userId: String) -> String {
            return "\(base)/users/\(userId)"
        }
        
        static func assess(competencyId: String) -> String {
            return "\(base)/\(competencyId)/assess"
        }
        
        static let matrix = "\(base)/matrix"
        static let categories = "\(base)/categories"
        static let skills = "\(base)/skills"
    }
    
    // MARK: - Notification Service
    enum Notifications {
        static let base = "\(baseURL)\(apiVersion)/notifications"
        
        static func notification(id: String) -> String {
            return "\(base)/\(id)"
        }
        
        static let markRead = "\(base)/mark-read"
        static let markAllRead = "\(base)/mark-all-read"
        static let preferences = "\(base)/preferences"
        static let subscribe = "\(base)/subscribe"
        static let unsubscribe = "\(base)/unsubscribe"
        
        static func deviceToken(token: String) -> String {
            return "\(base)/devices/\(token)"
        }
    }
    
    // MARK: - OrgStructure Service
    enum OrgStructure {
        static let base = "\(baseURL)\(apiVersion)/orgstructure"
        
        static let departments = "\(base)/departments"
        static func department(id: String) -> String {
            return "\(departments)/\(id)"
        }
        
        static let positions = "\(base)/positions"
        static func position(id: String) -> String {
            return "\(positions)/\(id)"
        }
        
        static func employees(departmentId: String) -> String {
            return "\(departments)/\(departmentId)/employees"
        }
        
        static let hierarchy = "\(base)/hierarchy"
        static let orgChart = "\(base)/chart"
    }
    
    // MARK: - Analytics Service
    enum Analytics {
        static let base = "\(baseURL)\(apiVersion)/analytics"
        
        static let events = "\(base)/events"
        static let metrics = "\(base)/metrics"
        static let reports = "\(base)/reports"
        
        static func userActivity(userId: String) -> String {
            return "\(base)/users/\(userId)/activity"
        }
        
        static func courseAnalytics(courseId: String) -> String {
            return "\(base)/courses/\(courseId)"
        }
    }
} 