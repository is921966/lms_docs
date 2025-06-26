//
//  TestMockService.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import Combine

@MainActor
class TestMockService: ObservableObject {
    static let shared = TestMockService()
    
    @Published var tests: [Test] = []
    @Published var attempts: [TestAttempt] = []
    @Published var results: [TestResult] = []
    @Published var isLoading = false
    
    init() {
        loadMockData()
    }
    
    func loadMockData() {
        // Создаем примеры тестов
        tests = [
            createSwiftBasicsTest(),
            createProjectManagementTest(),
            createLeadershipAssessment(),
            createDataAnalysisQuiz()
        ]
    }
    
    // MARK: - Mock Tests Creation
    
    private func createSwiftBasicsTest() -> Test {
        let questions = [
            Question(
                text: "Что такое Optional в Swift?",
                type: .singleChoice,
                points: 1.0,
                explanation: "Optional - это тип, который может содержать значение или nil",
                options: [
                    AnswerOption(text: "Тип данных, который может быть nil", isCorrect: true),
                    AnswerOption(text: "Обязательное свойство класса", isCorrect: false),
                    AnswerOption(text: "Метод для оптимизации кода", isCorrect: false),
                    AnswerOption(text: "Протокол Swift", isCorrect: false)
                ]
            ),
            Question(
                text: "Какие типы данных являются value types в Swift?",
                type: .multipleChoice,
                points: 2.0,
                options: [
                    AnswerOption(text: "struct", isCorrect: true),
                    AnswerOption(text: "class", isCorrect: false),
                    AnswerOption(text: "enum", isCorrect: true),
                    AnswerOption(text: "protocol", isCorrect: false)
                ]
            ),
            Question(
                text: "Swift поддерживает множественное наследование классов",
                type: .trueFalse,
                points: 1.0,
                explanation: "Swift не поддерживает множественное наследование классов, но поддерживает протоколы",
                options: [
                    AnswerOption(text: "Правда", isCorrect: false),
                    AnswerOption(text: "Ложь", isCorrect: true)
                ]
            ),
            Question(
                text: "Напишите ключевое слово для создания константы в Swift",
                type: .textInput,
                points: 1.0,
                acceptedAnswers: ["let", "Let", "LET"]
            ),
            Question(
                text: "Сопоставьте типы с их характеристиками",
                type: .matching,
                points: 3.0,
                matchingPairs: [
                    MatchingPair(left: "struct", right: "Value type"),
                    MatchingPair(left: "class", right: "Reference type"),
                    MatchingPair(left: "enum", right: "Can have associated values")
                ]
            )
        ]
        
        return Test(
            title: "Основы Swift",
            description: "Проверьте свои знания основ языка программирования Swift",
            type: LMSTestType.quiz,
            status: TestStatus.published,
            difficulty: TestDifficulty.easy,
            questions: questions,
            timeLimit: 30,
            passingScore: 70.0,
            competencyIds: ["comp-swift-basics", "comp-ios-dev"],
            positionIds: ["pos-junior-ios", "pos-middle-ios"],
            createdBy: "system",
            publishedAt: Date()
        )
    }
    
    private func createProjectManagementTest() -> Test {
        let questions = [
            Question(
                text: "Какие основные фазы включает жизненный цикл проекта?",
                type: .multipleChoice,
                points: 2.0,
                options: [
                    AnswerOption(text: "Инициация", isCorrect: true),
                    AnswerOption(text: "Планирование", isCorrect: true),
                    AnswerOption(text: "Исполнение", isCorrect: true),
                    AnswerOption(text: "Закрытие", isCorrect: true),
                    AnswerOption(text: "Отдых", isCorrect: false)
                ]
            ),
            Question(
                text: "Расположите этапы управления рисками в правильном порядке",
                type: .ordering,
                points: 3.0,
                correctOrder: [
                    "Идентификация рисков",
                    "Анализ рисков",
                    "Планирование реагирования",
                    "Мониторинг и контроль"
                ]
            ),
            Question(
                text: "Критический путь в проекте - это [blank1] последовательность задач, которая определяет [blank2] длительность проекта",
                type: .fillInBlanks,
                points: 2.0,
                textWithBlanks: "Критический путь в проекте - это [blank1] последовательность задач, которая определяет [blank2] длительность проекта",
                blanksAnswers: [
                    "blank1": ["самая длинная", "наибольшая", "максимальная"],
                    "blank2": ["минимальную", "наименьшую", "кратчайшую"]
                ]
            )
        ]
        
        return Test(
            title: "Управление проектами",
            description: "Экзамен по основам управления проектами",
            type: LMSTestType.exam,
            status: TestStatus.published,
            difficulty: TestDifficulty.medium,
            questions: questions,
            timeLimit: 45,
            attemptsAllowed: 2,
            passingScore: 80.0,
            competencyIds: ["comp-project-mgmt", "comp-leadership"],
            positionIds: ["pos-project-manager", "pos-team-lead"],
            createdBy: "system",
            publishedAt: Date()
        )
    }
    
    private func createLeadershipAssessment() -> Test {
        let questions = [
            Question(
                text: "Опишите ситуацию, когда вам пришлось принять сложное решение в условиях неопределенности. Как вы подошли к решению проблемы?",
                type: .essay,
                points: 10.0,
                hint: "Используйте метод STAR (Situation, Task, Action, Result)"
            ),
            Question(
                text: "Какой стиль лидерства вы предпочитаете и почему?",
                type: .essay,
                points: 10.0
            )
        ]
        
        return Test(
            title: "Оценка лидерских качеств",
            description: "Комплексная оценка лидерских компетенций",
            type: LMSTestType.assessment,
            status: TestStatus.published,
            difficulty: TestDifficulty.hard,
            questions: questions,
            passingScore: 60.0,
            showCorrectAnswers: false,
            competencyIds: ["comp-leadership", "comp-communication"],
            positionIds: ["pos-team-lead", "pos-department-head"],
            createdBy: "system",
            publishedAt: Date()
        )
    }
    
    private func createDataAnalysisQuiz() -> Test {
        return Test(
            title: "Основы анализа данных",
            description: "Практический тест по работе с данными",
            type: LMSTestType.practice,
            status: TestStatus.draft,
            difficulty: TestDifficulty.medium,
            questions: [],
            competencyIds: ["comp-data-analysis"],
            createdBy: "system"
        )
    }
    
    // MARK: - Test Management
    
    func getTest(by id: UUID) -> Test? {
        tests.first { $0.id == id }
    }
    
    func getTestsForUser(_ userId: String) -> [Test] {
        // В реальном приложении фильтровать по должности и компетенциям пользователя
        tests.filter { $0.isPublished }
    }
    
    func getTestsForCourse(_ courseId: String) -> [Test] {
        tests.filter { $0.courseId == courseId && $0.isPublished }
    }
    
    // MARK: - Attempt Management
    
    func getUserAttempts(userId: String, testId: UUID) -> [TestAttempt] {
        attempts.filter { $0.userId == userId && $0.testId == testId }
    }
    
    func getActiveAttempt(userId: String, testId: UUID) -> TestAttempt? {
        attempts.first { $0.userId == userId && $0.testId == testId && $0.isActive }
    }
    
    func startTest(testId: UUID, userId: String) -> TestAttempt? {
        guard let test = getTest(by: testId) else { return nil }
        
        // Проверяем количество попыток
        let userAttempts = getUserAttempts(userId: userId, testId: testId)
        if let maxAttempts = test.attemptsAllowed, userAttempts.count >= maxAttempts {
            return nil // Превышен лимит попыток
        }
        
        // Создаем новую попытку
        var questionsOrder = test.questions.map { $0.id }
        if test.shuffleQuestions {
            questionsOrder.shuffle()
        }
        
        // Если ограничено количество вопросов на попытку
        if let limit = test.questionsPerAttempt, limit < questionsOrder.count {
            questionsOrder = Array(questionsOrder.prefix(limit))
        }
        
        var attempt = TestAttempt(
            testId: testId,
            userId: userId,
            attemptNumber: userAttempts.count + 1
        )
        
        attempt.start(with: questionsOrder, timeLimit: test.timeLimit)
        attempts.append(attempt)
        
        return attempt
    }
    
    func saveAnswer(attemptId: UUID, answer: UserAnswer) {
        guard let index = attempts.firstIndex(where: { $0.id == attemptId }) else { return }
        attempts[index].saveAnswer(answer)
    }
    
    func submitTest(attemptId: UUID) -> TestResult? {
        guard let attemptIndex = attempts.firstIndex(where: { $0.id == attemptId }),
              let test = getTest(by: attempts[attemptIndex].testId) else { return nil }
        
        var attempt = attempts[attemptIndex]
        attempt.submit()
        
        // Автоматическая проверка
        var questionResults: [QuestionResult] = []
        var totalScore = 0.0
        var maxScore = 0.0
        
        for question in test.questions {
            guard let userAnswer = attempt.getAnswer(for: question.id) else {
                // Вопрос без ответа
                questionResults.append(QuestionResult(
                    questionId: question.id,
                    questionText: question.text,
                    questionType: question.type,
                    userAnswer: UserAnswer(questionId: question.id),
                    isCorrect: false,
                    earnedScore: 0,
                    maxScore: question.points
                ))
                maxScore += question.points
                continue
            }
            
            let checkResult = question.checkAnswer(userAnswer)
            questionResults.append(QuestionResult(
                questionId: question.id,
                questionText: question.text,
                questionType: question.type,
                userAnswer: userAnswer,
                isCorrect: checkResult.isCorrect,
                earnedScore: checkResult.score,
                maxScore: question.points,
                feedback: checkResult.feedback,
                correctAnswer: checkResult.correctAnswer
            ))
            
            totalScore += checkResult.score
            maxScore += question.points
        }
        
        let percentage = maxScore > 0 ? (totalScore / maxScore) * 100 : 0
        let isPassed = percentage >= test.passingScore
        
        // Обновляем попытку
        attempt.grade(
            score: totalScore,
            maxScore: maxScore,
            isPassed: isPassed,
            gradedBy: "system",
            feedback: nil
        )
        attempts[attemptIndex] = attempt
        
        // Создаем результат
        let result = TestResult(
            attemptId: attemptId,
            testId: test.id,
            userId: attempt.userId,
            totalScore: totalScore,
            maxScore: maxScore,
            percentage: percentage,
            isPassed: isPassed,
            passingScore: test.passingScore,
            questionResults: questionResults,
            totalTimeSeconds: attempt.timeSpentSeconds,
            averageTimePerQuestion: attempt.timeSpentSeconds / test.questions.count
        )
        
        results.append(result)
        return result
    }
    
    // MARK: - Results & Analytics
    
    func getUserResults(userId: String) -> [TestResult] {
        results.filter { $0.userId == userId }
    }
    
    func getTestResults(testId: UUID) -> [TestResult] {
        results.filter { $0.testId == testId }
    }
    
    func getTestAnalytics(testId: UUID) -> TestAnalytics {
        let testResults = getTestResults(testId: testId)
        return TestAnalytics(results: testResults)
    }
} 