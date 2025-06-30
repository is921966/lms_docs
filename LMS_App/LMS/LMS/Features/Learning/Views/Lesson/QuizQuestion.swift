import SwiftUI

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
            QuizProgressHeader(
                questionNumber: questionNumber,
                totalQuestions: totalQuestions
            )

            // Question
            Text(question.question)
                .font(.title3)
                .fontWeight(.medium)
                .padding()

            // Options
            QuizOptionsSection(
                options: question.options,
                selectedOption: selectedOption,
                onSelect: { index in
                    selectedOption = index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onAnswer(index)
                    }
                }
            )

            Spacer()
        }
        .navigationTitle("Тест")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct QuizProgressHeader: View {
    let questionNumber: Int
    let totalQuestions: Int

    var body: some View {
        HStack {
            Text("Вопрос \(questionNumber) из \(totalQuestions)")
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}

struct QuizOptionsSection: View {
    let options: [String]
    let selectedOption: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 15) {
            ForEach(0..<options.count, id: \.self) { index in
                QuizOptionButton(
                    text: options[index],
                    isSelected: selectedOption == index,
                    isDisabled: selectedOption != nil,
                    action: { onSelect(index) }
                )
            }
        }
        .padding()
    }
}

struct QuizOptionButton: View {
    let text: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

#Preview {
    NavigationView {
        QuizQuestionView(
            question: QuizQuestion(
                question: "Что является первым шагом в работе с возражением клиента?",
                options: [
                    "Сразу привести контраргументы",
                    "Выслушать клиента до конца",
                    "Предложить скидку",
                    "Позвать старшего менеджера"
                ],
                correctAnswer: 1
            ),
            questionNumber: 1,
            totalQuestions: 10,
            onAnswer: { _ in }
        )
    }
}
