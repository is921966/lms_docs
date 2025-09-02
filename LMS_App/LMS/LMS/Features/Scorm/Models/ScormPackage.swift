import Foundation

struct ScormPackage: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let version: String
    let organization: String?
    let scoCount: Int
    let fileSize: Int64
    let importDate: Date
    let manifestPath: String
    let contentPath: String
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: importDate)
    }
} 