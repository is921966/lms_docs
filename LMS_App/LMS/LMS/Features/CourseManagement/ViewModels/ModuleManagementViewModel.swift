//
//  ModuleManagementViewModel.swift
//  LMS
//
//  ViewModel for module management functionality
//

import Foundation
import SwiftUI

@MainActor
class ModuleManagementViewModel: ObservableObject {
    @Published var modules: [ManagedCourseModule]
    
    init(modules: [ManagedCourseModule]) {
        self.modules = modules
    }
    
    // MARK: - Module Operations
    
    func addModule(_ module: ManagedCourseModule) {
        var newModule = module
        newModule.order = modules.count + 1
        modules.append(newModule)
    }
    
    func updateModule(_ module: ManagedCourseModule) {
        if let index = modules.firstIndex(where: { $0.id == module.id }) {
            modules[index] = module
        }
    }
    
    func deleteModule(_ module: ManagedCourseModule) {
        modules.removeAll { $0.id == module.id }
        reorderModules()
    }
    
    func moveModule(from source: IndexSet, to destination: Int) {
        modules.move(fromOffsets: source, toOffset: destination)
        reorderModules()
    }
    
    // MARK: - Validation
    
    struct ValidationResult {
        let isValid: Bool
        let error: String?
    }
    
    func validateModule(_ module: ManagedCourseModule) -> ValidationResult {
        if module.title.isEmpty {
            return ValidationResult(isValid: false, error: "Название модуля не может быть пустым")
        }
        
        if module.duration <= 0 {
            return ValidationResult(isValid: false, error: "Длительность должна быть больше 0")
        }
        
        return ValidationResult(isValid: true, error: nil)
    }
    
    // MARK: - Private Methods
    
    private func reorderModules() {
        for (index, _) in modules.enumerated() {
            modules[index].order = index + 1
        }
    }
}

// MARK: - Content Type Extensions

extension ManagedCourseModule.ContentType {
    var icon: String {
        switch self {
        case .video: return "play.circle.fill"
        case .document: return "doc.text.fill"
        case .quiz: return "questionmark.circle.fill"
        case .cmi5: return "cube.box.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .video: return .red
        case .document: return .blue
        case .quiz: return .orange
        case .cmi5: return .purple
        }
    }
    
    var displayName: String {
        switch self {
        case .video: return "Видео"
        case .document: return "Документ"
        case .quiz: return "Тест"
        case .cmi5: return "Cmi5"
        }
    }
} 