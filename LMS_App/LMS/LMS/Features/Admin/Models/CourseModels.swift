import Foundation

// MARK: - CourseType

enum CourseType: String, CaseIterable, Codable {
    case mandatory = "mandatory"
    case optional = "optional"
    case recommended = "recommended"
    
    var displayName: String {
        switch self {
        case .mandatory: return "Обязательный"
        case .optional: return "По выбору"
        case .recommended: return "Рекомендуемый"
        }
    }
}

// MARK: - CourseStatus

enum CourseStatus: String, CaseIterable, Codable {
    case draft = "draft"
    case published = "published"
    case archived = "archived"
    
    var displayName: String {
        switch self {
        case .draft: return "Черновик"
        case .published: return "Опубликован"
        case .archived: return "В архиве"
        }
    }
    
    var color: String {
        switch self {
        case .draft: return "gray"
        case .published: return "green"
        case .archived: return "orange"
        }
    }
}

// MARK: - CourseCategory

enum CourseCategory: String, CaseIterable, Codable {
    case business = "business"
    case technical = "technical"
    case soft = "soft"
    case compliance = "compliance"
    case product = "product"
    
    var displayName: String {
        switch self {
        case .business: return "Бизнес"
        case .technical: return "Технические"
        case .soft: return "Soft skills"
        case .compliance: return "Комплаенс"
        case .product: return "Продуктовые"
        }
    }
    
    var icon: String {
        switch self {
        case .business: return "chart.line.uptrend.xyaxis"
        case .technical: return "gear"
        case .soft: return "person.2"
        case .compliance: return "checkmark.shield"
        case .product: return "cube.box"
        }
    }
}

// MARK: - CourseMaterial

struct CourseMaterial: Identifiable, Codable {
    let id: String
    let title: String
    let type: MaterialType
    let url: String?
    let description: String?
    let size: Int64? // in bytes
    let uploadedAt: Date
    
    enum MaterialType: String, Codable, CaseIterable {
        case pdf = "pdf"
        case video = "video"
        case presentation = "presentation"
        case document = "document"
        case link = "link"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.fill"
            case .video: return "play.rectangle.fill"
            case .presentation: return "rectangle.split.3x1.fill"
            case .document: return "doc.text.fill"
            case .link: return "link"
            }
        }
    }
} 