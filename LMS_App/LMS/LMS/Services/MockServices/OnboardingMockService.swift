import Foundation
import Combine

class OnboardingMockService: ObservableObject {
    static let shared = OnboardingMockService()
    
    @Published var programs: [OnboardingProgram] = []
    @Published var templates: [OnboardingTemplate] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Load mock programs
        programs = OnboardingProgram.createMockPrograms()
        
        // Load mock templates
        templates = OnboardingTemplate.mockTemplates
    }
    
    // MARK: - Programs
    
    func getPrograms() -> [OnboardingProgram] {
        return programs
    }
    
    func getProgram(by id: UUID) -> OnboardingProgram? {
        return programs.first { $0.id == id }
    }
    
    func updateProgram(_ program: OnboardingProgram) {
        if let index = programs.firstIndex(where: { $0.id == program.id }) {
            programs[index] = program
        }
    }
    
    func addProgram(_ program: OnboardingProgram) {
        programs.append(program)
    }
    
    func deleteProgram(by id: UUID) {
        programs.removeAll { $0.id == id }
    }
    
    // MARK: - Templates
    
    func getTemplates() -> [OnboardingTemplate] {
        return templates
    }
    
    func getTemplate(by id: UUID) -> OnboardingTemplate? {
        return templates.first { $0.id == id }
    }
    
    func addTemplate(_ template: OnboardingTemplate) {
        templates.append(template)
    }
    
    func updateTemplate(_ template: OnboardingTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
        }
    }
    
    func deleteTemplate(by id: UUID) {
        templates.removeAll { $0.id == id }
    }
    
    // MARK: - Task Management
    
    func markTaskCompleted(programId: UUID, stageIndex: Int, taskId: UUID) {
        guard var program = getProgram(by: programId),
              stageIndex < program.stages.count else { return }
        
        if let taskIndex = program.stages[stageIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            program.stages[stageIndex].tasks[taskIndex].isCompleted = true
            program.stages[stageIndex].tasks[taskIndex].completedAt = Date()
            
            // Update stage status
            let stageTasks = program.stages[stageIndex].tasks
            let completedStageTasks = stageTasks.filter { $0.isCompleted }.count
            if completedStageTasks == stageTasks.count {
                program.stages[stageIndex].status = .completed
            } else if program.stages[stageIndex].status == .notStarted && completedStageTasks > 0 {
                program.stages[stageIndex].status = .inProgress
            }
            
            // Update program status if needed
            let allTasksCount = program.stages.flatMap { $0.tasks }.count
            let completedTasksCount = program.stages.flatMap { $0.tasks }.filter { $0.isCompleted }.count
            
            if completedTasksCount == allTasksCount {
                program.status = .completed
                program.actualEndDate = Date()
            } else if program.status == .notStarted && completedTasksCount > 0 {
                program.status = .inProgress
            }
            
            updateProgram(program)
        }
    }
    
    func markTaskIncomplete(programId: UUID, stageIndex: Int, taskId: UUID) {
        guard var program = getProgram(by: programId),
              stageIndex < program.stages.count else { return }
        
        if let taskIndex = program.stages[stageIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            program.stages[stageIndex].tasks[taskIndex].isCompleted = false
            program.stages[stageIndex].tasks[taskIndex].completedAt = nil
            
            // Update stage status
            let stageTasks = program.stages[stageIndex].tasks
            let completedStageTasks = stageTasks.filter { $0.isCompleted }.count
            if completedStageTasks == 0 {
                program.stages[stageIndex].status = .notStarted
            } else if program.stages[stageIndex].status == .completed {
                program.stages[stageIndex].status = .inProgress
            }
            
            // Update program status if needed
            let allTasksCount = program.stages.flatMap { $0.tasks }.count
            let completedTasksCount = program.stages.flatMap { $0.tasks }.filter { $0.isCompleted }.count
            
            if completedTasksCount == 0 {
                program.status = .notStarted
            } else if program.status == .completed {
                program.status = .inProgress
                program.actualEndDate = nil
            }
            
            updateProgram(program)
        }
    }
    
    // MARK: - Statistics
    
    func getProgramStatistics() -> (total: Int, active: Int, completed: Int, overdue: Int) {
        let total = programs.count
        let active = programs.filter { $0.status == .inProgress }.count
        let completed = programs.filter { $0.status == .completed }.count
        let overdue = programs.filter { $0.isOverdue }.count
        
        return (total, active, completed, overdue)
    }
    
    func getTemplateStatistics() -> (total: Int, byPosition: [String: Int]) {
        let total = templates.count
        var byPosition: [String: Int] = [:]
        
        for template in templates {
            byPosition[template.targetPosition, default: 0] += 1
        }
        
        return (total, byPosition)
    }
} 