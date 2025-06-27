import SwiftUI

struct OnboardingTaskView: View {
    let task: OnboardingTask
    let onComplete: (OnboardingTask) -> Void
    
    @State private var showingCourseDetail = false
    @State private var showingTestDetail = false
    @State private var showingDocument = false
    @State private var showingMeetingDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Task icon
            ZStack {
                Circle()
                    .fill(task.iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: task.icon)
                    .foregroundColor(task.iconColor)
                    .font(.system(size: 18))
            }
            
            // Task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("До \(dueDate, formatter: dateFormatter)")
                            .font(.caption2)
                    }
                    .foregroundColor(isOverdue(dueDate) ? .red : .secondary)
                }
            }
            
            Spacer()
            
            // Action button
            Button(action: { handleTaskAction() }) {
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    actionButtonContent
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingCourseDetail) {
            if let courseId = task.courseId,
               let course = CourseMockService.shared.courses.first(where: { $0.id == courseId }) {
                NavigationView {
                    CourseDetailView(course: course)
                }
            }
        }
        .sheet(isPresented: $showingTestDetail) {
            if let testId = task.testId,
               let test = TestMockService.shared.tests.first(where: { $0.id == testId }) {
                NavigationView {
                    TestDetailView(test: test, viewModel: TestViewModel())
                }
            }
        }
        .sheet(isPresented: $showingDocument) {
            if let documentUrl = task.documentUrl {
                NavigationView {
                    DocumentViewerView(url: documentUrl)
                }
            }
        }
        .sheet(isPresented: $showingMeetingDetail) {
            if let meetingId = task.meetingId {
                NavigationView {
                    MeetingDetailView(meetingId: meetingId)
                }
            }
        }
    }
    
    @ViewBuilder
    private var actionButtonContent: some View {
        switch task.type {
        case .course:
            HStack(spacing: 4) {
                Text("Открыть")
                Image(systemName: "arrow.right.circle")
            }
            .font(.caption)
            .foregroundColor(.blue)
            
        case .test:
            HStack(spacing: 4) {
                Text("Пройти")
                Image(systemName: "pencil.circle")
            }
            .font(.caption)
            .foregroundColor(.purple)
            
        case .document:
            HStack(spacing: 4) {
                Text("Читать")
                Image(systemName: "doc.text")
            }
            .font(.caption)
            .foregroundColor(.orange)
            
        case .meeting:
            HStack(spacing: 4) {
                Text("Детали")
                Image(systemName: "video.circle")
            }
            .font(.caption)
            .foregroundColor(.green)
            
        case .task, .checklist, .feedback:
            Image(systemName: "circle")
                .foregroundColor(.gray)
                .font(.title2)
        }
    }
    
    private func handleTaskAction() {
        switch task.type {
        case .course:
            if !task.isCompleted {
                showingCourseDetail = true
            }
        case .test:
            if !task.isCompleted {
                showingTestDetail = true
            }
        case .document:
            if !task.isCompleted {
                showingDocument = true
            }
        case .meeting:
            if !task.isCompleted {
                showingMeetingDetail = true
            }
        case .task, .checklist, .feedback:
            if !task.isCompleted {
                var updatedTask = task
                updatedTask.isCompleted = true
                updatedTask.completedAt = Date()
                onComplete(updatedTask)
            }
        }
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        return date < Date() && !task.isCompleted
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
}

// MARK: - Document Viewer (Placeholder)
struct DocumentViewerView: View {
    let url: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Просмотр документа")
                .font(.largeTitle)
                .padding()
            
            Text("URL: \(url)")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Документ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Meeting Detail (Placeholder)
struct MeetingDetailView: View {
    let meetingId: UUID
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Встреча с руководителем")
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Завтра, 10:00", systemImage: "calendar")
                Label("Кабинет 305", systemImage: "location")
                Label("Длительность: 30 мин", systemImage: "clock")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Встреча")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        OnboardingTaskView(
            task: OnboardingTask(
                title: "Изучить корпоративную культуру",
                description: "Пройдите вводный курс о ценностях компании",
                type: .course,
                courseId: UUID(),
                dueDate: Date().addingTimeInterval(3*24*60*60)
            ),
            onComplete: { _ in }
        )
        
        OnboardingTaskView(
            task: OnboardingTask(
                title: "Тест по товароведению",
                description: "Проверка знаний ассортимента",
                type: .test,
                isCompleted: true,
                completedAt: Date(),
                testId: UUID()
            ),
            onComplete: { _ in }
        )
    }
    .padding()
} 