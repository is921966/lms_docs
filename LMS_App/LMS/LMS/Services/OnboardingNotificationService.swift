import Foundation
import UserNotifications
import Combine

class OnboardingNotificationService: ObservableObject {
    static let shared = OnboardingNotificationService()

    @Published var pendingNotifications: [OnboardingNotification] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        requestAuthorization()
        observeOnboardingChanges()
    }

    // MARK: - Authorization

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    // MARK: - Onboarding Observations

    private func observeOnboardingChanges() {
        // Observe program status changes
        OnboardingMockService.shared.$programs
            .sink { [weak self] programs in
                self?.checkForStatusChanges(programs)
            }
            .store(in: &cancellables)
    }

    private func checkForStatusChanges(_ programs: [OnboardingProgram]) {
        for program in programs {
            // Check for overdue tasks
            for stage in program.stages {
                for task in stage.tasks where !task.isCompleted {
                    if let dueDate = task.dueDate, dueDate < Date() {
                        scheduleOverdueNotification(for: task, in: program)
                    }
                }
            }

            // Check for stage completion
            for stage in program.stages {
                if stage.progress >= 1.0 && stage.status != .completed {
                    sendStageCompletionNotification(stage: stage, program: program)
                }
            }

            // Check for program milestones
            let progress = program.overallProgress
            if progress >= 0.25 && progress < 0.5 {
                sendMilestoneNotification(program: program, milestone: "25%")
            } else if progress >= 0.5 && progress < 0.75 {
                sendMilestoneNotification(program: program, milestone: "50%")
            } else if progress >= 0.75 && progress < 1.0 {
                sendMilestoneNotification(program: program, milestone: "75%")
            } else if progress >= 1.0 {
                sendCompletionNotification(program: program)
            }
        }
    }

    // MARK: - Notification Scheduling

    func scheduleOverdueNotification(for task: OnboardingTask, in program: OnboardingProgram) {
        let notification = OnboardingNotification(
            id: UUID(),
            type: .taskOverdue,
            title: "Задача просрочена",
            body: "Задача '\(task.title)' в программе адаптации просрочена",
            programId: program.id,
            taskId: task.id,
            scheduledDate: Date()
        )

        sendNotification(notification)
    }

    func sendStageCompletionNotification(stage: OnboardingStage, program: OnboardingProgram) {
        let notification = OnboardingNotification(
            id: UUID(),
            type: .stageCompleted,
            title: "Этап завершен! 🎉",
            body: "Вы завершили этап '\(stage.title)' в программе адаптации",
            programId: program.id,
            stageId: stage.id,
            scheduledDate: Date()
        )

        sendNotification(notification)
    }

    func sendMilestoneNotification(program: OnboardingProgram, milestone: String) {
        let notification = OnboardingNotification(
            id: UUID(),
            type: .milestone,
            title: "Достижение: \(milestone) выполнено!",
            body: "Вы прошли \(milestone) программы адаптации '\(program.title)'",
            programId: program.id,
            scheduledDate: Date()
        )

        sendNotification(notification)
    }

    func sendCompletionNotification(program: OnboardingProgram) {
        let notification = OnboardingNotification(
            id: UUID(),
            type: .programCompleted,
            title: "Поздравляем! 🎊",
            body: "Вы успешно завершили программу адаптации '\(program.title)'",
            programId: program.id,
            scheduledDate: Date()
        )

        sendNotification(notification)
    }

    func scheduleTaskReminder(task: OnboardingTask, program: OnboardingProgram, daysBefore: Int = 1) {
        guard let dueDate = task.dueDate else { return }

        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: dueDate) ?? dueDate

        let notification = OnboardingNotification(
            id: UUID(),
            type: .taskReminder,
            title: "Напоминание о задаче",
            body: "Не забудьте выполнить '\(task.title)' до \(formatDate(dueDate))",
            programId: program.id,
            taskId: task.id,
            scheduledDate: reminderDate
        )

        scheduleLocalNotification(notification)
    }

    // MARK: - Local Notifications

    private func sendNotification(_ notification: OnboardingNotification) {
        pendingNotifications.append(notification)

        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        content.badge = NSNumber(value: pendingNotifications.count)

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: nil // Immediate delivery
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }

    private func scheduleLocalNotification(_ notification: OnboardingNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                self.pendingNotifications.append(notification)
            }
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    // MARK: - Notification Management

    func clearNotification(_ id: UUID) {
        pendingNotifications.removeAll { $0.id == id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    func clearAllNotifications() {
        pendingNotifications.removeAll()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Notification Model

struct OnboardingNotification: Identifiable {
    let id: UUID
    let type: OnboardingNotificationType
    let title: String
    let body: String
    let programId: UUID
    var taskId: UUID?
    var stageId: UUID?
    let scheduledDate: Date
    var isRead: Bool = false
}

enum OnboardingNotificationType {
    case taskReminder
    case taskOverdue
    case stageCompleted
    case milestone
    case programCompleted
}
