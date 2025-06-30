import SwiftUI

struct ReportSectionView: View {
    let section: ReportSection
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: sectionIcon)
                        .foregroundColor(.blue)

                    Text(section.title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Content
            if isExpanded {
                sectionContent
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
            }
        }
    }

    private var sectionIcon: String {
        switch section.type {
        case .summary: return "doc.text"
        case .chart: return "chart.bar"
        case .table: return "tablecells"
        case .text: return "text.alignleft"
        case .metrics: return "number"
        }
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch section.data {
        case .summary(let data):
            SummaryView(data: data)
        case .metrics(let metrics):
            MetricsView(metrics: metrics)
        case .text(let text):
            Text(text)
                .font(.subheadline)
        case .chart:
            // Chart preview
            Text("График")
                .font(.caption)
                .foregroundColor(.secondary)
        case .table(let data):
            TableView(data: data)
        }
    }
}

#Preview {
    VStack {
        ReportSectionView(
            section: ReportSection(
                id: UUID(),
                title: "Сводка",
                type: .summary,
                order: 1,
                data: .summary(SummaryData(
                    highlights: ["Ключевой момент 1", "Ключевой момент 2"],
                    keyFindings: ["Вывод 1", "Вывод 2"],
                    recommendations: ["Рекомендация 1", "Рекомендация 2"]
                ))
            )
        )
    }
    .padding()
}
