import AVKit
import SwiftUI

struct LessonView: View {
    let module: Module
    @State private var currentLessonIndex = 0
    @State private var showingQuiz = false
    @State private var lessonCompleted = false
    @State private var showingCmi5Player = false
    @State private var cmi5SessionId = UUID().uuidString
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cmi5Service: Cmi5Service
    @EnvironmentObject var lrsService: LRSService

    var currentLesson: Lesson {
        module.lessons[currentLessonIndex]
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                LessonProgressBar(
                    current: currentLessonIndex + 1,
                    total: module.lessons.count
                )

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch currentLesson.type {
                        case .video:
                            VideoLessonView()
                        case .text:
                            TextLessonView()
                        case .quiz:
                            QuizIntroView(showingQuiz: $showingQuiz)
                        case .interactive:
                            InteractiveLessonView()
                        case .assignment:
                            AssignmentLessonView()
                        case .cmi5:
                            Cmi5IntroView(
                                lesson: currentLesson,
                                onStart: { showingCmi5Player = true }
                            )
                        }
                    }
                    .padding()
                }

                // Navigation buttons
                LessonNavigationBar(
                    currentIndex: currentLessonIndex,
                    totalLessons: module.lessons.count,
                    onPrevious: previousLesson,
                    onNext: nextLesson
                )
            }
            .navigationTitle(currentLesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(currentLessonIndex + 1) / \(module.lessons.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showingQuiz) {
                LessonQuizView { passed in
                    showingQuiz = false
                    if passed {
                        lessonCompleted = true
                        nextLesson()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCmi5Player) {
                if case .cmi5(let activityId, let packageId) = currentLesson.content,
                   let activity = getCmi5Activity(activityId: activityId) {
                    Cmi5PlayerView(
                        activity: activity,
                        sessionId: cmi5SessionId,
                        launchParameters: getLaunchParameters()
                    ) { statement in
                        // Handle xAPI statement
                        handleCmi5Statement(statement)
                    } onCompletion: { passed in
                        showingCmi5Player = false
                        if passed {
                            lessonCompleted = true
                            nextLesson()
                        }
                    }
                    .environmentObject(cmi5Service)
                    .environmentObject(lrsService)
                }
            }
        }
    }

    private func previousLesson() {
        withAnimation {
            currentLessonIndex = max(0, currentLessonIndex - 1)
            cmi5SessionId = UUID().uuidString // New session for new lesson
        }
    }

    private func nextLesson() {
        withAnimation {
            if currentLessonIndex < module.lessons.count - 1 {
                currentLessonIndex += 1
                cmi5SessionId = UUID().uuidString // New session for new lesson
            } else {
                // Module completed
                dismiss()
            }
        }
    }
    
    private func getCmi5Activity(activityId: String) -> Cmi5Activity? {
        // TODO: Получить активность из сервиса
        // Временная заглушка для компиляции
        return Cmi5Activity(
            id: UUID(),
            packageId: UUID(), // TODO: Получить из реального пакета
            activityId: activityId,
            title: currentLesson.title,
            description: currentLesson.description,
            launchUrl: "https://example.com/cmi5/content/\(activityId)",
            launchMethod: .ownWindow,
            moveOn: .passed,
            masteryScore: 0.8,
            activityType: "http://adlnet.gov/expapi/activities/module",
            duration: "PT\(currentLesson.duration)M" // ISO 8601 format
        )
    }
    
    private func getLaunchParameters() -> [String: String] {
        return [
            "lang": "ru",
            "learner_id": UserDefaults.standard.string(forKey: "userId") ?? "anonymous",
            "learner_name": UserDefaults.standard.string(forKey: "userName") ?? "Anonymous User"
        ]
    }
    
    private func handleCmi5Statement(_ statement: XAPIStatement) {
        // Обработка xAPI statement
        Task {
            await updateLessonProgress(from: statement)
        }
    }
    
    private func updateLessonProgress(from statement: XAPIStatement) async {
        // Обновить прогресс урока на основе statement
        if statement.verb.id == XAPIStatementBuilder.Cmi5Verb.completed.id ||
           statement.verb.id == XAPIStatementBuilder.Cmi5Verb.passed.id {
            lessonCompleted = true
        }
    }
}

#Preview {
    LessonView(
        module: Module(
            title: "Работа с возражениями",
            description: "Изучение техник работы с возражениями клиентов",
            orderIndex: 3,
            lessons: [
                Lesson(
                    title: "Видео: Введение",
                    type: .video,
                    orderIndex: 1,
                    duration: 15,
                    content: .video(url: "https://example.com/video1.mp4", subtitlesUrl: nil)
                ),
                Lesson(
                    title: "Теория",
                    type: .text,
                    orderIndex: 2,
                    duration: 10,
                    content: .text(html: "<h1>Работа с возражениями</h1><p>Содержание урока...</p>")
                )
            ]
        )
    )
}

// MARK: - Cmi5 Intro View

struct Cmi5IntroView: View {
    let lesson: Lesson
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.box")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Интерактивный урок Cmi5")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Этот урок содержит интерактивный контент в формате Cmi5. Ваш прогресс будет автоматически сохраняться.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // duration is not optional in Lesson
            Label("\(lesson.duration) минут", systemImage: "clock")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: onStart) {
                Label("Начать урок", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
