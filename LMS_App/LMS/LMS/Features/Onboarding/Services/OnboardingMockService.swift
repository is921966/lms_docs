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
        if stage.progress == 1.0 && stage.status != StageStatus.completed {
            programs[programIndex].stages[stageIndex].status = StageStatus.completed
            programs[programIndex].stages[stageIndex].endDate = Date()
            
            // Check if need to start next stage
            if stageIndex < programs[programIndex].stages.count - 1 {
                programs[programIndex].stages[stageIndex + 1].status = StageStatus.inProgress
                programs[programIndex].stages[stageIndex + 1].startDate = Date()
            }
        } else if stage.progress > 0 && stage.status == StageStatus.notStarted {
            programs[programIndex].stages[stageIndex].status = StageStatus.inProgress
            programs[programIndex].stages[stageIndex].startDate = Date()
        }
        
        // Update program status
        if programs[programIndex].status == OnboardingStatus.notStarted && stage.progress > 0 {
            programs[programIndex].status = OnboardingStatus.inProgress
        } else if programs[programIndex].overallProgress == 1.0 {
            programs[programIndex].status = OnboardingStatus.completed
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
        let activePrograms = programs.filter { $0.status == OnboardingStatus.inProgress }.count
        let completedPrograms = programs.filter { $0.status == OnboardingStatus.completed }.count
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
        let completedPrograms = programs.filter { $0.status == OnboardingStatus.completed && $0.actualEndDate != nil }
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
                id: UUID(),
                templateStageId: templateStage.id,
                title: templateStage.title,
                description: templateStage.description,
                order: templateStage.order,
                duration: templateStage.duration,
                startDate: nil,
                endDate: nil,
                status: StageStatus.notStarted,
                completionPercentage: 0,
                tasks: templateStage.tasks.map { templateTask in
                    OnboardingTask(
                        title: templateTask.title,
                        description: templateTask.description,
                        type: templateTask.type,
                        isCompleted: false,
                        completedAt: nil,
                        completedBy: nil,
                        courseId: templateTask.courseId,
                        testId: templateTask.testId,
                        documentUrl: templateTask.documentUrl,
                        meetingId: nil,
                        dueDate: nil,
                        isRequired: templateTask.requiredDocuments.isEmpty ? false : true
                    )
                }
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
            status: OnboardingStatus.notStarted
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
        if stage.progress == 1.0 && stage.status != StageStatus.completed {
            programs[programIndex].stages[stageIndex].status = StageStatus.completed
            programs[programIndex].stages[stageIndex].endDate = Date()
        }
        
        // Update program status
        if programs[programIndex].overallProgress == 1.0 {
            programs[programIndex].status = OnboardingStatus.completed
            programs[programIndex].actualEndDate = Date()
        }
    }
    
    
    func getAllTemplates() -> [OnboardingTemplate] {
        return templates
    }
    
    // MARK: - Create Program
    
    func createProgram(fromTemplate template: OnboardingTemplate, 
                      employee: UserResponse,
                      manager: UserResponse,
                      startDate: Date) -> OnboardingProgram {
        // Create stages from template
        var programStages: [OnboardingStage] = []
        var currentStageStartDate = startDate
        
        for (index, templateStage) in template.stages.enumerated() {
            // Create tasks from template
            let tasks = templateStage.tasks.map { taskTemplate in
                OnboardingTask(
                    title: taskTemplate.title,
                    description: taskTemplate.description,
                    type: taskTemplate.type,
                    isCompleted: false,
                    completedAt: nil,
                    completedBy: nil,
                    courseId: taskTemplate.courseId,
                    testId: taskTemplate.testId,
                    documentUrl: taskTemplate.documentUrl,
                    meetingId: nil,
                    dueDate: nil,
                    isRequired: !taskTemplate.requiredDocuments.isEmpty
                )
            }
            
            // Calculate stage dates
            let stageDuration = templateStage.duration
            let stageEndDate = Calendar.current.date(byAdding: .day, value: stageDuration, to: currentStageStartDate)!
            
            let stage = OnboardingStage(
                id: UUID(),
                templateStageId: templateStage.id,
                title: templateStage.title,
                description: templateStage.description,
                order: index + 1,
                duration: stageDuration,
                startDate: currentStageStartDate,
                endDate: stageEndDate,
                status: index == 0 ? .inProgress : .notStarted,
                completionPercentage: 0,
                tasks: tasks
            )
            
            programStages.append(stage)
            currentStageStartDate = stageEndDate
        }
        
        // Create program
        let program = OnboardingProgram(
            templateId: template.id,
            employeeId: UUID(uuidString: employee.id) ?? UUID(),
            employeeName: "\(employee.firstName) \(employee.lastName)",
            employeePosition: employee.position ?? "Сотрудник",
            employeeDepartment: employee.department ?? "Не указан",
            managerId: UUID(uuidString: manager.id) ?? UUID(),
            managerName: "\(manager.firstName) \(manager.lastName)",
            title: template.title,
            description: template.description,
            startDate: startDate,
            targetEndDate: currentStageStartDate,
            actualEndDate: nil,
            stages: programStages,
            totalDuration: template.duration,
            status: .inProgress
        )
        
        // Add to programs list
        programs.append(program)
        
        return program
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