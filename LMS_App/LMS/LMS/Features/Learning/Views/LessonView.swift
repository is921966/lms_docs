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
                ProgressBar(
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
                HStack(spacing: 15) {
                    if currentLessonIndex > 0 {
                        Button(action: previousLesson) {
                            Label("Назад", systemImage: "chevron.left")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(action: nextLesson) {
                        if currentLessonIndex < module.lessons.count - 1 {
                            Label("Далее", systemImage: "chevron.right")
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Завершить модуль")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
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
                QuizView { passed in
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

// MARK: - Progress Bar
struct ProgressBar: View {
    let current: Int
    let total: Int
    
    var progress: Double {
        Double(current) / Double(total)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Video Lesson
struct VideoLessonView: View {
    @State private var player = AVPlayer(url: URL(string: "https://example.com/video.mp4")!)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Video player placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black)
                    .aspectRatio(16/9, contentMode: .fit)
                
                VStack(spacing: 20) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Видео урок")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // Lesson info
            VStack(alignment: .leading, spacing: 15) {
                Text("Введение в технику продаж")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Label("15 минут", systemImage: "clock")
                    Label("Иван Петров", systemImage: "person")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("В этом уроке вы узнаете основные принципы успешных продаж, научитесь устанавливать контакт с клиентом и выявлять его потребности.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Key points
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ключевые моменты:")
                        .font(.headline)
                    
                    ForEach([
                        "Первое впечатление и приветствие",
                        "Открытые вопросы для выявления потребностей",
                        "Активное слушание",
                        "Презентация преимуществ товара"
                    ], id: \.self) { point in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(point)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Text Lesson
struct TextLessonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Работа с возражениями клиентов")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Возражения - это естественная часть процесса продаж. Важно научиться правильно на них реагировать.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Content sections
            VStack(alignment: .leading, spacing: 25) {
                LessonSection(
                    title: "Типы возражений",
                    content: "Существует несколько основных типов возражений:\n\n• Ценовые - \"Слишком дорого\"\n• Временные - \"Мне нужно подумать\"\n• Качественные - \"А что если не подойдет?\"\n• Сравнительные - \"У конкурентов дешевле\""
                )
                
                LessonSection(
                    title: "Техника работы с возражениями",
                    content: "1. Выслушайте клиента до конца\n2. Покажите понимание его позиции\n3. Задайте уточняющий вопрос\n4. Приведите аргументы\n5. Проверьте, снято ли возражение"
                )
                
                // Example
                VStack(alignment: .leading, spacing: 10) {
                    Text("Пример диалога:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        DialogBubble(
                            text: "Это слишком дорого для меня",
                            isClient: true
                        )
                        
                        DialogBubble(
                            text: "Я понимаю вашу озабоченность ценой. Скажите, а что именно вам понравилось в этом товаре?",
                            isClient: false
                        )
                        
                        DialogBubble(
                            text: "Качество хорошее и дизайн нравится",
                            isClient: true
                        )
                        
                        DialogBubble(
                            text: "Отлично! Давайте посчитаем стоимость использования в день...",
                            isClient: false
                        )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

struct LessonSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct DialogBubble: View {
    let text: String
    let isClient: Bool
    
    var body: some View {
        HStack {
            if !isClient { Spacer() }
            
            Text(text)
                .font(.subheadline)
                .padding()
                .background(isClient ? Color.gray.opacity(0.2) : Color.blue)
                .foregroundColor(isClient ? .primary : .white)
                .cornerRadius(15)
                .frame(maxWidth: 280, alignment: isClient ? .leading : .trailing)
            
            if isClient { Spacer() }
        }
    }
}

// MARK: - Quiz Intro
struct QuizIntroView: View {
    @Binding var showingQuiz: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Проверка знаний")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Пройдите тест, чтобы проверить усвоение материала модуля")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 15) {
                QuizInfoRow(icon: "questionmark.circle", text: "10 вопросов")
                QuizInfoRow(icon: "clock", text: "15 минут")
                QuizInfoRow(icon: "percent", text: "Проходной балл: 70%")
                QuizInfoRow(icon: "arrow.clockwise", text: "3 попытки")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            
            Button(action: { showingQuiz = true }) {
                Text("Начать тест")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct QuizInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Interactive Lesson
struct InteractiveLessonView: View {
    @State private var selectedAnswer = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Интерактивное упражнение")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Выберите правильный подход к клиенту")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Scenario
            VStack(alignment: .leading, spacing: 10) {
                Text("Ситуация:")
                    .font(.headline)
                
                Text("Клиент зашел в магазин и рассматривает витрину с обувью. Он выглядит нерешительно.")
                    .font(.subheadline)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Text("Как вы поступите?")
                .font(.headline)
            
            // Options
            VStack(spacing: 10) {
                ForEach([
                    "Сразу подойти и спросить: \"Что вас интересует?\"",
                    "Дать клиенту время осмотреться, затем подойти",
                    "Ждать, пока клиент сам обратится за помощью",
                    "Громко рассказывать о скидках"
                ], id: \.self) { option in
                    Button(action: { selectedAnswer = option }) {
                        HStack {
                            Image(systemName: selectedAnswer == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedAnswer == option ? .blue : .gray)
                            
                            Text(option)
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                        .background(selectedAnswer == option ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if !selectedAnswer.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: selectedAnswer.contains("осмотреться") ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(selectedAnswer.contains("осмотреться") ? .green : .red)
                        
                        Text(selectedAnswer.contains("осмотреться") ? "Правильно!" : "Попробуйте еще раз")
                            .font(.headline)
                    }
                    
                    Text(selectedAnswer.contains("осмотреться") ? 
                         "Верно! Важно дать клиенту время осмотреться, а затем предложить помощь." :
                         "Подумайте о том, что чувствует клиент в этой ситуации.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(selectedAnswer.contains("осмотреться") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Assignment Lesson
struct AssignmentLessonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Практическое задание")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Выполните задание для закрепления материала")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Инструкции:")
                    .font(.headline)
                
                Text("1. Проведите анализ потребностей клиента\n2. Составьте презентацию товара\n3. Подготовьте ответы на возможные возражения")
                    .font(.subheadline)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    Text("Срок выполнения: 3 дня")
                        .font(.subheadline)
                }
                
                Button(action: {}) {
                    Text("Загрузить выполненное задание")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - Quiz View
struct QuizView: View {
    let onComplete: (Bool) -> Void
    @State private var currentQuestion = 0
    @State private var selectedAnswers: [Int] = []
    @State private var showingResults = false
    
    let questions = [
        QuizQuestion(
            question: "Что является первым шагом в работе с возражением клиента?",
            options: [
                "Сразу привести контраргументы",
                "Выслушать клиента до конца",
                "Предложить скидку",
                "Позвать старшего менеджера"
            ],
            correctAnswer: 1
        ),
        // Add more questions...
    ]
    
    var body: some View {
        NavigationView {
            if showingResults {
                QuizResultsView(
                    score: calculateScore(),
                    total: questions.count,
                    onRetry: {
                        currentQuestion = 0
                        selectedAnswers = []
                        showingResults = false
                    },
                    onComplete: { passed in
                        onComplete(passed)
                    }
                )
            } else {
                QuizQuestionView(
                    question: questions[currentQuestion],
                    questionNumber: currentQuestion + 1,
                    totalQuestions: questions.count,
                    onAnswer: { answer in
                        selectedAnswers.append(answer)
                        if currentQuestion < questions.count - 1 {
                            currentQuestion += 1
                        } else {
                            showingResults = true
                        }
                    }
                )
            }
        }
    }
    
    private func calculateScore() -> Int {
        var score = 0
        for (index, answer) in selectedAnswers.enumerated() {
            if index < questions.count && questions[index].correctAnswer == answer {
                score += 1
            }
        }
        return score
    }
}

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
}

struct QuizQuestionView: View {
    let question: QuizQuestion
    let questionNumber: Int
    let totalQuestions: Int
    let onAnswer: (Int) -> Void
    
    @State private var selectedOption: Int?
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress
            HStack {
                Text("Вопрос \(questionNumber) из \(totalQuestions)")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            // Question
            Text(question.question)
                .font(.title3)
                .fontWeight(.medium)
                .padding()
            
            // Options
            VStack(spacing: 15) {
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        selectedOption = index
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onAnswer(index)
                        }
                    }) {
                        HStack {
                            Text(question.options[index])
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding()
                        .background(selectedOption == index ? Color.blue : Color.gray.opacity(0.1))
                        .foregroundColor(selectedOption == index ? .white : .primary)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedOption != nil)
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Тест")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct QuizResultsView: View {
    let score: Int
    let total: Int
    let onRetry: () -> Void
    let onComplete: (Bool) -> Void
    
    var percentage: Int {
        (score * 100) / total
    }
    
    var passed: Bool {
        percentage >= 70
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(passed ? .green : .red)
            
            Text(passed ? "Отлично!" : "Попробуйте еще раз")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Ваш результат: \(score) из \(total)")
                .font(.title3)
            
            Text("\(percentage)%")
                .font(.system(size: 60))
                .fontWeight(.bold)
                .foregroundColor(passed ? .green : .red)
            
            Text(passed ? "Вы успешно прошли тест!" : "Для прохождения теста необходимо набрать минимум 70%")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                if !passed {
                    Button(action: onRetry) {
                        Text("Пройти еще раз")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: { onComplete(passed) }) {
                    Text(passed ? "Продолжить" : "Вернуться к уроку")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(passed ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .padding()
        .navigationTitle("Результаты теста")
        .navigationBarTitleDisplayMode(.inline)
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
                ),
                Lesson(
                    title: "Практика",
                    type: .interactive,
                    orderIndex: 3,
                    duration: 20,
                    content: .interactive(url: "https://example.com/interactive1")
                ),
                Lesson(
                    title: "Тест",
                    type: .quiz,
                    orderIndex: 4,
                    duration: 15,
                    content: .quiz(questions: [
                        CourseQuizQuestion(
                            text: "Что является первым шагом в работе с возражением клиента?",
                            options: [
                                "Сразу привести контраргументы",
                                "Выслушать клиента до конца",
                                "Предложить скидку",
                                "Позвать старшего менеджера"
                            ],
                            correctAnswerIndex: 1
                        )
                    ])
                )
            ]
        )
    )
} 