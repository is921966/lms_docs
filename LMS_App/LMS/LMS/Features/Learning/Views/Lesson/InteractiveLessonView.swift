import SwiftUI

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
            ScenarioSection()
            
            Text("Как вы поступите?")
                .font(.headline)
            
            // Options
            OptionsSection(selectedAnswer: $selectedAnswer)
            
            // Feedback
            if !selectedAnswer.isEmpty {
                FeedbackSection(selectedAnswer: selectedAnswer)
            }
        }
    }
}

struct ScenarioSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ситуация:")
                .font(.headline)
            
            Text("Клиент зашел в магазин и рассматривает витрину с обувью. Он выглядит нерешительно.")
                .font(.subheadline)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

struct OptionsSection: View {
    @Binding var selectedAnswer: String
    
    let options = [
        "Сразу подойти и спросить: \"Что вас интересует?\"",
        "Дать клиенту время осмотреться, затем подойти",
        "Ждать, пока клиент сам обратится за помощью",
        "Громко рассказывать о скидках"
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                OptionButton(
                    option: option,
                    isSelected: selectedAnswer == option,
                    action: { selectedAnswer = option }
                )
            }
        }
    }
}

struct OptionButton: View {
    let option: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(option)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeedbackSection: View {
    let selectedAnswer: String
    
    var isCorrect: Bool {
        selectedAnswer.contains("осмотреться")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Правильно!" : "Попробуйте еще раз")
                    .font(.headline)
            }
            
            Text(isCorrect ? 
                 "Верно! Важно дать клиенту время осмотреться, а затем предложить помощь." :
                 "Подумайте о том, что чувствует клиент в этой ситуации.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ScrollView {
        InteractiveLessonView()
            .padding()
    }
}
