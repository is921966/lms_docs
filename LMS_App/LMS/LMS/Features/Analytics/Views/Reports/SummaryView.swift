import SwiftUI

struct SummaryView: View {
    let data: SummaryData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !data.highlights.isEmpty {
                SummarySection(
                    title: "Основные моменты",
                    icon: "star.fill",
                    color: .yellow,
                    items: data.highlights
                )
            }

            if !data.keyFindings.isEmpty {
                SummarySection(
                    title: "Ключевые выводы",
                    icon: "lightbulb.fill",
                    color: .orange,
                    items: data.keyFindings
                )
            }

            if !data.recommendations.isEmpty {
                SummarySection(
                    title: "Рекомендации",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    items: data.recommendations
                )
            }
        }
    }
}

struct SummarySection: View {
    let title: String
    let icon: String
    let color: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(color)
                    Text(item)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    SummaryView(
        data: SummaryData(
            highlights: ["Ключевой момент 1", "Ключевой момент 2"],
            keyFindings: ["Вывод 1", "Вывод 2", "Вывод 3"],
            recommendations: ["Рекомендация 1", "Рекомендация 2"]
        )
    )
    .padding()
}
