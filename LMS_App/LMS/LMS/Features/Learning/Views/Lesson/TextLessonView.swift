import SwiftUI

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

                // Example dialog
                DialogExample()
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

struct DialogExample: View {
    var body: some View {
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

#Preview {
    ScrollView {
        TextLessonView()
            .padding()
    }
}
