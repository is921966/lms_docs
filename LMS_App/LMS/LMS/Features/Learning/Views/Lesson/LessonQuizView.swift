import SwiftUI

struct LessonQuizView: View {
    let onComplete: (Bool) -> Void
    @State private var currentQuestion = 0
    @State private var selectedAnswers: [Int] = []
    @State private var showingResults = false

    let questions = QuizMockData.questions

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

struct QuizMockData {
    static let questions = [
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
        QuizQuestion(
            question: "Какой вопрос лучше задать при выявлении потребностей?",
            options: [
                "Вам что-нибудь подсказать?",
                "Что именно вы ищете?",
                "Расскажите, для каких целей выбираете товар?",
                "У нас есть скидки, интересно?"
            ],
            correctAnswer: 2
        ),
        QuizQuestion(
            question: "Что делать, если клиент говорит 'Я подумаю'?",
            options: [
                "Дать визитку и отпустить",
                "Выяснить, что именно смущает",
                "Предложить скидку",
                "Настаивать на покупке"
            ],
            correctAnswer: 1
        )
    ]
}

#Preview {
    LessonQuizView { passed in
        print("Quiz completed: \(passed)")
    }
}
