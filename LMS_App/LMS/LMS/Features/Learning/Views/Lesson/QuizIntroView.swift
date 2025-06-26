import SwiftUI

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
            
            QuizInfoSection()
            
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

struct QuizInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            QuizInfoRow(icon: "questionmark.circle", text: "10 вопросов")
            QuizInfoRow(icon: "clock", text: "15 минут")
            QuizInfoRow(icon: "percent", text: "Проходной балл: 70%")
            QuizInfoRow(icon: "arrow.clockwise", text: "3 попытки")
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
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

#Preview {
    QuizIntroView(showingQuiz: .constant(false))
}
