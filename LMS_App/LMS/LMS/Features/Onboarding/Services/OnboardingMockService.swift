//
//  OnboardingMockService.swift
//  LMS
//
//  Created on 27/01/2025.
//

import Foundation
import SwiftUI

class OnboardingMockService: ObservableObject {
    static let shared = OnboardingMockService()
    
    @Published var programs: [OnboardingProgram] = []
    @Published var templates: [OnboardingTemplate] = []
    
    private init() {
        loadInitialData()
    }
    
    private func loadInitialData() {
        programs = OnboardingProgram.createMockPrograms()
        templates = OnboardingTemplate.mockTemplates
        
        // Assign one program to the current user for testing
        if let currentUser = MockAuthService.shared.currentUser,
           let userId = UUID(uuidString: currentUser.id),
           programs.count > 0 {
            programs[0].employeeId = userId
            programs[0].employeeName = "\(currentUser.firstName) \(currentUser.lastName)"
            programs[0].employeePosition = currentUser.position ?? "Сотрудник"
            programs[0].employeeDepartment = currentUser.department ?? "Не указан"
        }
    }
    
    // MARK: - Programs
    
    func getPrograms() -> [OnboardingProgram] {
        return programs
    }
    
    func getProgramsForUser(_ userId: UUID) -> [OnboardingProgram] {
        return programs.filter { $0.employeeId == userId }
    }
    
    func getProgramsForManager(_ managerId: UUID) -> [OnboardingProgram] {
        return programs.filter { $0.managerId == managerId }
    }
    
    func updateProgram(_ program: OnboardingProgram) {
        if let index = programs.firstIndex(where: { $0.id == program.id }) {
            programs[index] = program
        }
    }
    
    func updateTask(in programId: UUID, stageId: UUID, task: OnboardingTask) {
        guard let programIndex = programs.firstIndex(where: { $0.id == programId }),
              let stageIndex = programs[programIndex].stages.firstIndex(where: { $0.id == stageId }),
              let taskIndex = programs[programIndex].stages[stageIndex].tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        programs[programIndex].stages[stageIndex].tasks[taskIndex] = task
        
        // Update stage status if needed
        let stage = programs[programIndex].stages[stageIndex]
        if stage.progress == 1.0 && stage.status != .completed {
            programs[programIndex].stages[stageIndex].status = .completed
            programs[programIndex].stages[stageIndex].endDate = Date()
            
            // Check if need to start next stage
            if stageIndex < programs[programIndex].stages.count - 1 {
                programs[programIndex].stages[stageIndex + 1].status = .inProgress
                programs[programIndex].stages[stageIndex + 1].startDate = Date()
            }
        } else if stage.progress > 0 && stage.status == .notStarted {
            programs[programIndex].stages[stageIndex].status = .inProgress
            programs[programIndex].stages[stageIndex].startDate = Date()
        }
        
        // Update program status
        if programs[programIndex].status == .notStarted && stage.progress > 0 {
            programs[programIndex].status = .inProgress
        } else if programs[programIndex].overallProgress == 1.0 {
            programs[programIndex].status = .completed
            programs[programIndex].actualEndDate = Date()
        }
    }
    
    // MARK: - Templates
    
    func getTemplates() -> [OnboardingTemplate] {
        return templates
    }
    
    func createTemplate(_ template: OnboardingTemplate) {
        templates.append(template)
    }
    
    func updateTemplate(_ template: OnboardingTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
        }
    }
    
    func deleteTemplate(_ templateId: UUID) {
        templates.removeAll { $0.id == templateId }
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> OnboardingStatistics {
        let activePrograms = programs.filter { $0.status == .inProgress }.count
        let completedPrograms = programs.filter { $0.status == .completed }.count
        let overduePrograms = programs.filter { $0.isOverdue }.count
        let totalPrograms = programs.count
        
        let averageProgress = programs.isEmpty ? 0 : programs.reduce(0) { $0 + $1.overallProgress } / Double(programs.count)
        let averageCompletionTime = calculateAverageCompletionTime()
        
        return OnboardingStatistics(
            activePrograms: activePrograms,
            completedPrograms: completedPrograms,
            overduePrograms: overduePrograms,
            totalPrograms: totalPrograms,
            averageProgress: averageProgress,
            averageCompletionTime: averageCompletionTime,
            completionRate: totalPrograms > 0 ? Double(completedPrograms) / Double(totalPrograms) : 0
        )
    }
    
    private func calculateAverageCompletionTime() -> Int {
        let completedPrograms = programs.filter { $0.status == .completed && $0.actualEndDate != nil }
        guard !completedPrograms.isEmpty else { return 0 }
        
        let totalDays = completedPrograms.reduce(0) { total, program in
            let days = Calendar.current.dateComponents([.day], from: program.startDate, to: program.actualEndDate!).day ?? 0
            return total + days
        }
        
        return totalDays / completedPrograms.count
    }
    
    // MARK: - Public Methods
    
    func resetData() {
        loadInitialData()
    }
    
    func createProgramFromTemplate(
        template: OnboardingTemplate,
        employeeId: UUID,
        employeeName: String,
        employeePosition: String,
        employeeDepartment: String,
        managerId: UUID,
        managerName: String,
        startDate: Date
    ) -> OnboardingProgram {
        // Convert template stages to program stages
        let programStages = template.stages.map { templateStage in
            OnboardingStage(
                orderIndex: templateStage.orderIndex,
                title: templateStage.title,
                description: templateStage.description,
                duration: templateStage.duration,
                tasks: templateStage.taskTemplates.map { taskTemplate in
                    OnboardingTask(
                        title: taskTemplate.title,
                        description: taskTemplate.description,
                        type: taskTemplate.type,
                        isCompleted: false,
                        courseId: taskTemplate.courseId,
                        testId: taskTemplate.testId,
                        documentUrl: taskTemplate.documentTemplateId != nil ? "document://\(taskTemplate.documentTemplateId!)" : nil,
                        isRequired: taskTemplate.isRequired
                    )
                },
                status: .notStarted
            )
        }
        
        let targetEndDate = Calendar.current.date(byAdding: .day, value: template.duration, to: startDate) ?? startDate
        
        let newProgram = OnboardingProgram(
            templateId: template.id,
            employeeId: employeeId,
            employeeName: employeeName,
            employeePosition: employeePosition,
            employeeDepartment: employeeDepartment,
            managerId: managerId,
            managerName: managerName,
            title: template.title,
            description: template.description,
            startDate: startDate,
            targetEndDate: targetEndDate,
            stages: programStages,
            totalDuration: template.duration,
            status: .notStarted
        )
        
        programs.append(newProgram)
        
        return newProgram
    }
    
    func updateTaskStatus(programId: UUID, stageId: UUID, taskId: UUID, isCompleted: Bool) {
        guard let programIndex = programs.firstIndex(where: { $0.id == programId }),
              let stageIndex = programs[programIndex].stages.firstIndex(where: { $0.id == stageId }),
              let taskIndex = programs[programIndex].stages[stageIndex].tasks.firstIndex(where: { $0.id == taskId }) else {
            return
        }
        
        programs[programIndex].stages[stageIndex].tasks[taskIndex].isCompleted = isCompleted
        programs[programIndex].stages[stageIndex].tasks[taskIndex].completedAt = isCompleted ? Date() : nil
        
        // Update stage status if needed
        let stage = programs[programIndex].stages[stageIndex]
        if stage.progress == 1.0 && stage.status != .completed {
            programs[programIndex].stages[stageIndex].status = .completed
            programs[programIndex].stages[stageIndex].endDate = Date()
        }
        
        // Update program status
        if programs[programIndex].overallProgress == 1.0 {
            programs[programIndex].status = .completed
            programs[programIndex].actualEndDate = Date()
        }
    }
}

// MARK: - Statistics Model
struct OnboardingStatistics {
    let activePrograms: Int
    let completedPrograms: Int
    let overduePrograms: Int
    let totalPrograms: Int
    let averageProgress: Double
    let averageCompletionTime: Int // in days
    let completionRate: Double
} 