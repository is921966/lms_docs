import SwiftUI
import AVKit

struct LessonView: View {
    let module: Module
    @State private var currentLessonIndex = 0
    @State private var showingQuiz = false
    @State private var lessonCompleted = false
    @Environment(\.dismiss) private var dismiss
    
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
        }
    }
    
    private func previousLesson() {
        withAnimation {
            currentLessonIndex = max(0, currentLessonIndex - 1)
        }
    }
    
    private func nextLesson() {
        withAnimation {
            if currentLessonIndex < module.lessons.count - 1 {
                currentLessonIndex += 1
            } else {
                // Module completed
                dismiss()
            }
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