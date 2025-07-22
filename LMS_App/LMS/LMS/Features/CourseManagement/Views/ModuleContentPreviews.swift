//
//  ModuleContentPreviews.swift
//  LMS
//
//  Preview implementations for different module types
//

import SwiftUI
import AVKit

// MARK: - Video Module Preview

struct VideoModulePreview: View {
    let module: ManagedCourseModule
    @Binding var progress: Double
    @State private var currentTime: Double = 0
    @State private var isPlaying = false
    
    private let videoDuration: Double = 300 // 5 минут для демо
    
    var body: some View {
        VStack(spacing: 0) {
            // Video Player Mock
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(16/9, contentMode: .fit)
                
                VStack(spacing: 20) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Видео: \(module.title)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Режим предпросмотра")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .onTapGesture {
                isPlaying.toggle()
                if isPlaying {
                    simulateVideoPlayback()
                }
            }
            
            // Video Controls
            VStack(spacing: 16) {
                // Progress bar
                HStack {
                    Text(formatTime(currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $currentTime, in: 0...videoDuration) { editing in
                        if !editing {
                            updateProgress()
                        }
                    }
                    
                    Text(formatTime(videoDuration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Control buttons
                HStack(spacing: 40) {
                    Button {
                        currentTime = max(0, currentTime - 10)
                        updateProgress()
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.title2)
                    }
                    
                    Button {
                        isPlaying.toggle()
                        if isPlaying {
                            simulateVideoPlayback()
                        }
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                    }
                    
                    Button {
                        currentTime = min(videoDuration, currentTime + 10)
                        updateProgress()
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.title2)
                    }
                }
            }
            .padding()
            
            // Video Info
            VStack(alignment: .leading, spacing: 12) {
                Text("О видео")
                    .font(.headline)
                
                Text(module.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("Длительность: \(module.duration) мин", systemImage: "clock")
                    Spacer()
                    Label("HD качество", systemImage: "4k.tv")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            // Auto start preview
            isPlaying = true
            simulateVideoPlayback()
        }
    }
    
    private func simulateVideoPlayback() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isPlaying {
                timer.invalidate()
                return
            }
            
            currentTime += 1
            updateProgress()
            
            if currentTime >= videoDuration {
                timer.invalidate()
                isPlaying = false
                progress = 1.0
            }
        }
    }
    
    private func updateProgress() {
        progress = min(1.0, currentTime / videoDuration)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Document Module Preview

struct DocumentModulePreview: View {
    let module: ManagedCourseModule
    @Binding var progress: Double
    @State private var scrollPosition: CGFloat = 0
    @State private var hasScrolledToBottom = false
    
    private let documentContent = """
    # \(UUID().uuidString)
    
    ## Введение
    
    Это учебный материал для модуля. В реальном приложении здесь будет загружаться актуальный контент документа.
    
    ### Основные темы:
    
    1. **Первая тема** - подробное описание первой темы с примерами и иллюстрациями.
    
    2. **Вторая тема** - объяснение второй темы, включая практические примеры.
    
    3. **Третья тема** - заключительная часть с выводами и рекомендациями.
    
    ## Детальное изложение
    
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
    
    ### Пример кода:
    ```swift
    func example() {
        print("Hello, World!")
    }
    ```
    
    ## Практические задания
    
    1. Изучите представленный материал
    2. Выполните практические упражнения
    3. Ответьте на контрольные вопросы
    
    ## Дополнительные ресурсы
    
    - Ссылка на дополнительные материалы
    - Рекомендуемая литература
    - Видео-уроки по теме
    
    ## Заключение
    
    Поздравляем! Вы изучили весь материал этого модуля. Теперь вы готовы перейти к следующему разделу курса.
    """
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Document header
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(module.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Текстовый материал")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Document content with markdown formatting
                    MarkdownContentView(text: documentContent.replacingOccurrences(of: UUID().uuidString, with: module.title))
                        .padding()
                    
                    // End marker
                    Text("Конец документа")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .id("bottom")
                        .onAppear {
                            if !hasScrolledToBottom {
                                hasScrolledToBottom = true
                                progress = 1.0
                            }
                        }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                updateReadingProgress(value)
            }
        }
        .onAppear {
            // Start tracking reading time
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                if progress < 0.5 {
                    progress += 0.1
                }
                if progress >= 1.0 {
                    timer.invalidate()
                }
            }
        }
    }
    
    private func updateReadingProgress(_ offset: CGFloat) {
        // Simple progress calculation based on scroll
        let totalHeight: CGFloat = 2000 // Approximate
        let scrolled = abs(offset)
        let calculatedProgress = min(1.0, scrolled / totalHeight + 0.3)
        
        if calculatedProgress > progress {
            progress = calculatedProgress
        }
    }
}

// MARK: - Quiz Module Preview

struct QuizModulePreview: View {
    let module: ManagedCourseModule
    @Binding var progress: Double
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: Int] = [:]
    @State private var showResults = false
    
    private let questions = [
        PreviewQuizQuestion(
            question: "Какое утверждение является верным?",
            answers: [
                "Вариант A - правильный ответ",
                "Вариант B - неправильный ответ",
                "Вариант C - неправильный ответ",
                "Вариант D - неправильный ответ"
            ],
            correctAnswer: 0
        ),
        PreviewQuizQuestion(
            question: "Выберите правильное определение:",
            answers: [
                "Определение 1",
                "Определение 2 - правильное",
                "Определение 3",
                "Определение 4"
            ],
            correctAnswer: 1
        ),
        PreviewQuizQuestion(
            question: "Какой из методов является наиболее эффективным?",
            answers: [
                "Метод A",
                "Метод B",
                "Метод C - наиболее эффективный",
                "Метод D"
            ],
            correctAnswer: 2
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if !showResults {
                // Quiz header
                VStack(spacing: 8) {
                    Text("Вопрос \(currentQuestionIndex + 1) из \(questions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                        .tint(.blue)
                }
                .padding()
                
                // Question
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(questions[currentQuestionIndex].question)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding()
                        
                        // Answer options
                        VStack(spacing: 12) {
                            ForEach(0..<questions[currentQuestionIndex].answers.count, id: \.self) { index in
                                AnswerButton(
                                    text: questions[currentQuestionIndex].answers[index],
                                    isSelected: selectedAnswers[currentQuestionIndex] == index,
                                    action: {
                                        selectedAnswers[currentQuestionIndex] = index
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Navigation
                HStack {
                    if currentQuestionIndex > 0 {
                        Button("Назад") {
                            currentQuestionIndex -= 1
                        }
                    }
                    
                    Spacer()
                    
                    Button(currentQuestionIndex < questions.count - 1 ? "Далее" : "Завершить") {
                        if currentQuestionIndex < questions.count - 1 {
                            currentQuestionIndex += 1
                            updateProgress()
                        } else {
                            showResults = true
                            progress = 1.0
                        }
                    }
                    .disabled(selectedAnswers[currentQuestionIndex] == nil)
                }
                .padding()
            } else {
                // Results
                PreviewQuizResultsView(
                    questions: questions,
                    selectedAnswers: selectedAnswers,
                    onRestart: {
                        currentQuestionIndex = 0
                        selectedAnswers = [:]
                        showResults = false
                        progress = 0
                    }
                )
            }
        }
        .onAppear {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        progress = Double(selectedAnswers.count) / Double(questions.count)
    }
}

// MARK: - Cmi5 Module Preview

struct Cmi5ModulePreview: View {
    let module: ManagedCourseModule
    let cmi5PackageId: UUID?
    @Binding var progress: Double
    
    @State private var cmi5Activity: Cmi5Activity?
    @State private var isLoading = true
    @State private var error: String?
    @State private var showingFullContent = false
    @State private var packagesLoaded = false
    
    @EnvironmentObject var cmi5Service: Cmi5Service
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Загрузка Cmi5 контента...")
                    .padding()
            } else if let error = error {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Попробовать снова") {
                        Task {
                            await loadContent()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let activity = cmi5Activity {
                // Реальный Cmi5 контент доступен
                VStack(spacing: 15) {
                    Text("Cmi5 Контент")
                        .font(.headline)
                    
                    Text(activity.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let description = activity.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        showingFullContent = true
                    } label: {
                        Label("Открыть контент", systemImage: "play.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("Реальный Cmi5 контент готов к загрузке")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .sheet(isPresented: $showingFullContent) {
                    Cmi5FullContentView(
                        activity: activity,
                        cmi5PackageId: cmi5PackageId,  // Передаем packageId из курса
                        onProgress: { newProgress in
                            progress = newProgress
                        },
                        onComplete: {
                            progress = 1.0
                            showingFullContent = false
                        }
                    )
                }
            } else {
                // Показываем симуляцию
                Cmi5SimulationView(module: module, progress: $progress)
            }
        }
        .task {
            await loadContent()
        }
    }
    
    @MainActor
    private func loadContent() async {
        isLoading = true
        
        if module.contentType == .cmi5, let _ = module.contentUrl {
            // Сначала загружаем пакеты если не загружены
            if !packagesLoaded {
                await cmi5Service.loadPackages()
                packagesLoaded = true
                print("🔍 [Cmi5ModulePreview] Packages loaded: \(cmi5Service.packages.count)")
            }
            
            // Теперь пробуем загрузить активность
            await loadCmi5Activity()
        }
        
        isLoading = false
    }
    
    @MainActor
    private func loadCmi5Activity() async {
        print("🔍 [Cmi5ModulePreview] loadCmi5Activity() started")
        print("   - module.id: \(module.id)")
        print("   - module.title: \(module.title)")
        print("   - module.contentType: \(module.contentType)")
        print("   - module.contentUrl: \(String(describing: module.contentUrl))")
        print("   - cmi5PackageId: \(String(describing: cmi5PackageId))")
        
        // Получаем ID активности из contentUrl
        guard let contentUrl = module.contentUrl else {
            print("❌ [Cmi5ModulePreview] No contentUrl in module")
            return
        }
        
        let activityId = contentUrl
        print("✅ [Cmi5ModulePreview] Using activity ID: \(activityId)")
        
        // Загружаем все пакеты
        await cmi5Service.loadPackages()
        let packages = await cmi5Service.packages
        print("🔍 [Cmi5ModulePreview] Packages loaded: \(packages.count)")
        
        // Если есть cmi5PackageId, ищем в конкретном пакете
        if let packageId = cmi5PackageId {
            if let package = packages.first(where: { $0.id == packageId }) {
                if let activity = findActivityInPackage(package, activityId: activityId) {
                    print("✅ [Cmi5ModulePreview] Found activity in specific package")
                    self.cmi5Activity = activity
                    self.isLoading = false
                    return
                }
            }
        }
        
        // Если не нашли в конкретном пакете, ищем во всех пакетах
        print("⚠️ [Cmi5ModulePreview] Activity not found in specific package, searching all packages")
        for package in packages {
            if let activity = findActivityInPackage(package, activityId: activityId) {
                print("✅ [Cmi5ModulePreview] Found activity in package: \(package.title)")
                // Создаем новую активность с правильным packageId
                self.cmi5Activity = Cmi5Activity(
                    id: activity.id,
                    packageId: package.id,  // Используем ID пакета, где нашли активность
                    activityId: activity.activityId,
                    title: activity.title,
                    description: activity.description,
                    launchUrl: activity.launchUrl,
                    launchMethod: activity.launchMethod,
                    moveOn: activity.moveOn,
                    masteryScore: activity.masteryScore,
                    activityType: activity.activityType,
                    duration: activity.duration
                )
                self.isLoading = false
                return
            }
        }
        
        print("❌ [Cmi5ModulePreview] Activity not found in any package, showing simulation")
        self.isLoading = false
    }
    
    private func findActivityInPackages(activityId: String) -> Cmi5Activity? {
        // Ищем активность среди загруженных пакетов
        for package in cmi5Service.packages {
            // Проверяем активности в корневом блоке
            if let rootBlock = package.manifest.course?.rootBlock {
                if let activity = findActivityInBlock(rootBlock, activityId: activityId, packageId: package.id) {
                    return activity
                }
            }
        }
        return nil
    }
    
    private func findActivityInBlock(_ block: Cmi5Block, activityId: String, packageId: UUID) -> Cmi5Activity? {
        print("🔍 [findActivityInBlock] Searching for activityId: \(activityId)")
        print("   - Block ID: \(block.id)")
        print("   - Block has \(block.activities.count) activities")
        
        // Проверяем активности в текущем блоке
        for activity in block.activities {
            print("   - Checking activity: \(activity.activityId) == \(activityId)?")
            if activity.activityId == activityId {
                print("   ✅ Found matching activity!")
                // Возвращаем существующую активность
                return activity
            }
        }
        
        print("   - Block has \(block.blocks.count) sub-blocks")
        // Рекурсивно проверяем вложенные блоки
        for subBlock in block.blocks {
            if let activity = findActivityInBlock(subBlock, activityId: activityId, packageId: packageId) {
                return activity
            }
        }
        
        print("   ❌ Activity not found in this block")
        return nil
    }
    
    private func findFirstActivityId(in block: Cmi5Block) -> String? {
        for activity in block.activities {
            return activity.activityId
        }
        for subBlock in block.blocks {
            if let activityId = findFirstActivityId(in: subBlock) {
                return activityId
            }
        }
        return nil
    }
    
    private func findActivityInPackage(_ package: Cmi5Package, activityId: String) -> Cmi5Activity? {
        guard let rootBlock = package.manifest.course?.rootBlock else { return nil }
        return findActivityInBlock(rootBlock, activityId: activityId, packageId: package.id)
    }
}

// MARK: - Cmi5 Full Content View

struct Cmi5FullContentView: View {
    let activity: Cmi5Activity
    let cmi5PackageId: UUID?  // Добавляем packageId из курса
    let onProgress: (Double) -> Void
    let onComplete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var sessionId = UUID().uuidString
    @State private var launchParameters: [String: String] = [:]
    @EnvironmentObject var cmi5Service: Cmi5Service
    @EnvironmentObject var lrsService: LRSService
    
    var body: some View {
        NavigationView {
            Cmi5PlayerView(
                packageId: cmi5PackageId ?? activity.packageId,  // Используем packageId из курса, если есть
                activityId: activity.activityId,
                sessionId: sessionId,
                launchParameters: buildLaunchParameters()
            ) { statement in
                // Handle xAPI statements
                handleStatement(statement)
            } onCompletion: { passed in
                onComplete()
            }
            .environmentObject(cmi5Service)
            .environmentObject(lrsService)
            .navigationTitle("Просмотр контента")
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
    
    private func buildLaunchParameters() -> [String: String] {
        return [
            "lang": "ru",
            "learner_id": "preview_user",
            "learner_name": "Режим предпросмотра"
        ]
    }
    
    private func handleStatement(_ statement: XAPIStatement) {
        // Обработка прогресса на основе xAPI statements
        if statement.verb.id == "http://adlnet.gov/expapi/verbs/progressed" {
            if let progress = statement.result?.extensions?["progress"] as? Double {
                onProgress(progress)
            }
        }
    }
}

// MARK: - Cmi5 Simulation View (Fallback)

struct Cmi5SimulationView: View {
    let module: ManagedCourseModule
    @Binding var progress: Double
    @State private var currentSlide = 0
    
    private let totalSlides = 5
    
    var body: some View {
        VStack(spacing: 20) {
            // Slide indicator
            HStack {
                ForEach(0..<totalSlides, id: \.self) { index in
                    Circle()
                        .fill(index <= currentSlide ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            
            // Simulated content
            TabView(selection: $currentSlide) {
                ForEach(0..<totalSlides, id: \.self) { index in
                    SimulatedSlideView(
                        slideNumber: index + 1,
                        title: "Слайд \(index + 1)",
                        content: generateSlideContent(index)
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Navigation
            HStack {
                Button {
                    if currentSlide > 0 {
                        currentSlide -= 1
                    }
                } label: {
                    Label("Назад", systemImage: "chevron.left")
                }
                .disabled(currentSlide == 0)
                
                Spacer()
                
                Text("\(currentSlide + 1) / \(totalSlides)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    if currentSlide < totalSlides - 1 {
                        currentSlide += 1
                    } else {
                        progress = 1.0
                    }
                } label: {
                    Label(currentSlide < totalSlides - 1 ? "Далее" : "Завершить", 
                          systemImage: "chevron.right")
                }
            }
            .padding()
            
            Text("Симуляция контента - реальный курс недоступен")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onChange(of: currentSlide) {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        progress = Double(currentSlide + 1) / Double(totalSlides)
    }
    
    private func generateSlideContent(_ index: Int) -> String {
        switch index {
        case 0: return "Введение в тему. Интерактивные элементы помогут лучше усвоить материал."
        case 1: return "Основные концепции. Используйте кнопки для взаимодействия."
        case 2: return "Практические примеры. Попробуйте выполнить задания."
        case 3: return "Углубленное изучение. Исследуйте дополнительные материалы."
        case 4: return "Заключение и выводы. Проверьте свои знания."
        default: return "Содержимое слайда"
        }
    }
}

struct SimulatedSlideView: View {
    let slideNumber: Int
    let title: String
    let content: String
    @State private var isInteracting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            // Interactive element
            Button {
                withAnimation(.spring()) {
                    isInteracting.toggle()
                }
            } label: {
                VStack {
                    Image(systemName: isInteracting ? "hand.tap.fill" : "hand.tap")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .scaleEffect(isInteracting ? 1.2 : 1.0)
                    
                    Text("Нажмите для интерактива")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isInteracting {
                Text("✅ Отлично! Вы взаимодействовали с элементом.")
                    .font(.callout)
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Helper Views

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct PreviewQuizResultsView: View {
    let questions: [PreviewQuizQuestion]
    let selectedAnswers: [Int: Int]
    let onRestart: () -> Void
    
    private var correctAnswers: Int {
        questions.enumerated().reduce(0) { count, item in
            let (index, question) = item
            return count + (selectedAnswers[index] == question.correctAnswer ? 1 : 0)
        }
    }
    
    private var percentage: Int {
        Int((Double(correctAnswers) / Double(questions.count)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Score
            VStack(spacing: 16) {
                Image(systemName: percentage >= 70 ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(percentage >= 70 ? .green : .red)
                
                Text("Результат теста")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(correctAnswers) из \(questions.count)")
                    .font(.title)
                
                Text("\(percentage)%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(percentage >= 70 ? .green : .red)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 12) {
                ForEach(questions.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: selectedAnswers[index] == questions[index].correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(selectedAnswers[index] == questions[index].correctAnswer ? .green : .red)
                        
                        Text("Вопрос \(index + 1)")
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // Note
            Text("Это режим предпросмотра. Результаты не сохраняются.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Restart button
            Button {
                onRestart()
            } label: {
                Label("Пройти заново", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct InteractiveSlide: View {
    let slideNumber: Int
    let title: String
    let content: String
    @State private var isInteracting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            // Interactive element
            Button {
                withAnimation(.spring()) {
                    isInteracting.toggle()
                }
            } label: {
                VStack {
                    Image(systemName: isInteracting ? "hand.tap.fill" : "hand.tap")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .scaleEffect(isInteracting ? 1.2 : 1.0)
                    
                    Text("Нажмите для интерактива")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isInteracting {
                Text("✅ Отлично! Вы взаимодействовали с элементом.")
                    .font(.callout)
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Supporting Types

struct PreviewQuizQuestion {
    let question: String
    let answers: [String]
    let correctAnswer: Int
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 