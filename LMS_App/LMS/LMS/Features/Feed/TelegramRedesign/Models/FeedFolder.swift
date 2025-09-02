//
//  FeedFolder.swift
//  LMS
//
//  Model for feed folders
//

import Foundation
import SwiftUI

/// Custom folders for organizing feed channels
enum FeedFolder: Identifiable, Equatable {
    case all
    case sprints
    case docs
    case system
    case custom(name: String, icon: String, filter: (FeedChannel) -> Bool)
    
    var id: String {
        switch self {
        case .all: return "all"
        case .sprints: return "sprints"
        case .docs: return "docs"
        case .system: return "system"
        case .custom(let name, _, _): return "custom_\(name)"
        }
    }
    
    var name: String {
        switch self {
        case .all: return "All"
        case .sprints: return "Sprints"
        case .docs: return "Docs"
        case .system: return "System"
        case .custom(let name, _, _): return name
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .sprints: return "calendar"
        case .docs: return "doc.text"
        case .system: return "gearshape"
        case .custom(_, let icon, _): return icon
        }
    }
    
    static var defaultFolders: [FeedFolder] {
        return [.all, .sprints, .docs]
    }
    
    static func == (lhs: FeedFolder, rhs: FeedFolder) -> Bool {
        return lhs.id == rhs.id
    }
} 