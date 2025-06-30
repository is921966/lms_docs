import Combine
import Foundation

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
        programs
    }

    func getProgram(by id: UUID) -> OnboardingProgram? {
        programs.first { $0.id == id }
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
        templates
    }

    func getTemplate(by id: UUID) -> OnboardingTemplate? {
        templates.first { $0.id == id }
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

    // MARK: - Additional Methods for Tests

    func resetData() {
        programs.removeAll()
        templates.removeAll()
        loadMockData()
    }

    func createProgramFromTemplate(templateId: UUID, employeeName: String, position: String, startDate: Date = Date()) -> OnboardingProgram? {
        guard let template = getTemplate(by: templateId) else { return nil }

        let endDate = startDate.addingTimeInterval(TimeInterval(template.duration * 24 * 60 * 60))

        let program = OnboardingProgram(
            templateId: templateId,
            employeeId: UUID(),
            employeeName: employeeName,
            employeePosition: position,
            employeeDepartment: template.targetDepartment ?? "Не указан",
            managerId: UUID(),
            managerName: "Менеджер",
            title: template.title,
            description: template.description,
            startDate: startDate,
            targetEndDate: endDate,
            stages: template.stages.map { templateStage in
                OnboardingStage(
                    id: UUID(),
                    templateStageId: templateStage.id,
                    title: templateStage.title,
                    description: templateStage.description,
                    order: templateStage.order,
                    duration: templateStage.duration,
                    startDate: nil,
                    endDate: nil,
                    status: .notStarted,
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
                            isRequired: true
                        )
                    }
                )
            },
            totalDuration: template.duration,
            status: .notStarted
        )

        addProgram(program)
        return program
    }

    func getProgramsForUser(_ userId: UUID) -> [OnboardingProgram] {
        // Фильтруем программы по employeeId
        programs.filter { $0.employeeId == userId }
    }

    func updateTaskStatus(programId: UUID, taskId: UUID, isCompleted: Bool) {
        guard var program = getProgram(by: programId) else { return }

        // Найти задачу во всех этапах
        for (stageIndex, stage) in program.stages.enumerated() {
            if let taskIndex = stage.tasks.firstIndex(where: { $0.id == taskId }) {
                if isCompleted {
                    markTaskCompleted(programId: programId, stageIndex: stageIndex, taskId: taskId)
                } else {
                    markTaskIncomplete(programId: programId, stageIndex: stageIndex, taskId: taskId)
                }
                break
            }
        }
    }
}
