import SwiftUI

struct ReportInfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

#Preview {
    HStack {
        ReportInfoCard(
            icon: "calendar",
            title: "Период",
            value: "Месяц"
        )
        ReportInfoCard(
            icon: "doc.text",
            title: "Формат",
            value: "PDF"
        )
    }
    .padding()
}
