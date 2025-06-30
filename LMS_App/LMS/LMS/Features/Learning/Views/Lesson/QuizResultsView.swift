import SwiftUI

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
            // Result icon
            ResultIcon(passed: passed)

            // Result text
            ResultText(passed: passed)

            // Score details
            ScoreDetails(score: score, total: total, percentage: percentage, passed: passed)

            // Action buttons
            ResultActions(passed: passed, onRetry: onRetry, onComplete: onComplete)
        }
        .padding()
        .navigationTitle("Результаты теста")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResultIcon: View {
    let passed: Bool

    var body: some View {
        Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(passed ? .green : .red)
    }
}

struct ResultText: View {
    let passed: Bool

    var body: some View {
        Text(passed ? "Отлично!" : "Попробуйте еще раз")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
}

struct ScoreDetails: View {
    let score: Int
    let total: Int
    let percentage: Int
    let passed: Bool

    var body: some View {
        VStack(spacing: 15) {
            Text("Ваш результат: \(score) из \(total)")
                .font(.title3)

            Text("\(percentage)%")
                .font(.system(size: 60))
                .fontWeight(.bold)
                .foregroundColor(passed ? .green : .red)

            Text(passed ?
                 "Вы успешно прошли тест!" :
                 "Для прохождения теста необходимо набрать минимум 70%")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct ResultActions: View {
    let passed: Bool
    let onRetry: () -> Void
    let onComplete: (Bool) -> Void

    var body: some View {
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
}

#Preview {
    NavigationView {
        QuizResultsView(
            score: 8,
            total: 10,
            onRetry: {},
            onComplete: { _ in }
        )
    }
}
