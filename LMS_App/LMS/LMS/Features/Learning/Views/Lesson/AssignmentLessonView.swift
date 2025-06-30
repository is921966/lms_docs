import SwiftUI

struct AssignmentLessonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Практическое задание")
                .font(.title2)
                .fontWeight(.bold)

            Text("Выполните задание для закрепления материала")
                .font(.subheadline)
                .foregroundColor(.secondary)

            AssignmentInstructions()

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

struct AssignmentInstructions: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Инструкции:")
                .font(.headline)

            Text("1. Проведите анализ потребностей клиента\n2. Составьте презентацию товара\n3. Подготовьте ответы на возможные возражения")
                .font(.subheadline)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

#Preview {
    AssignmentLessonView()
        .padding()
}
