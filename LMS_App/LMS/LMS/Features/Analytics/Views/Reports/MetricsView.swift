import SwiftUI

struct MetricsView: View {
    let metrics: [MetricData]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(metrics) { metric in
                MetricMiniCard(metric: metric)
            }
        }
    }
}

struct MetricMiniCard: View {
    let metric: MetricData

    var body: some View {
        VStack(spacing: 4) {
            if let icon = metric.icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            HStack(spacing: 2) {
                Text(metric.value)
                    .font(.caption)
                    .fontWeight(.semibold)

                if let unit = metric.unit {
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Text(metric.title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

#Preview {
    MetricsView(
        metrics: [
            MetricData(
                id: UUID(),
                title: "Прогресс",
                value: "87",
                unit: "%",
                icon: "chart.line.uptrend.xyaxis"
            ),
            MetricData(
                id: UUID(),
                title: "Завершено",
                value: "12",
                unit: "курсов",
                icon: "checkmark.circle"
            ),
            MetricData(
                id: UUID(),
                title: "Время",
                value: "45",
                unit: "часов",
                icon: "clock"
            ),
            MetricData(
                id: UUID(),
                title: "Баллы",
                value: "1250",
                unit: nil,
                icon: "star"
            )
        ]
    )
    .padding()
}
