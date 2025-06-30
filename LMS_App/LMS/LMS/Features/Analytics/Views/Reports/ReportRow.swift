import SwiftUI

struct ReportRow: View {
    let report: Report
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Type icon
                ReportTypeIcon(type: report.type)

                // Report info
                ReportInfoSection(report: report)

                Spacer()

                // Schedule indicator
                if report.schedule != nil {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ReportTypeIcon: View {
    let type: ReportType

    var body: some View {
        Image(systemName: type.icon)
            .font(.title2)
            .foregroundColor(type.color)
            .frame(width: 40, height: 40)
            .background(type.color.opacity(0.1))
            .cornerRadius(10)
    }
}

struct ReportInfoSection: View {
    let report: Report

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(report.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                Label(report.period.rawValue, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label(report.format.rawValue, systemImage: report.format.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: report.status.icon)
                    .font(.caption)
                Text(report.status.rawValue)
                    .font(.caption)
            }
            .foregroundColor(report.status.color)
        }
    }
}

#Preview {
    List {
        ReportRow(
            report: Report(
                title: "Отчет по обучению",
                type: .learningProgress,
                status: .ready,
                period: .month,
                createdBy: "admin",
                format: .pdf
            ),
            onTap: {}
        )
        ReportRow(
            report: Report(
                title: "Отчет по обучению",
                type: .learningProgress,
                status: .ready,
                period: .month,
                createdBy: "admin",
                format: .pdf
            ),
            onTap: {}
        )
    }
}
