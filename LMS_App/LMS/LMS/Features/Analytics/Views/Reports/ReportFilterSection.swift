import SwiftUI

struct ReportFilterSection: View {
    @Binding var filterType: ReportType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ReportFilterChip(
                    title: "Все",
                    isSelected: filterType == nil,
                    action: { filterType = nil }
                )

                ForEach(ReportType.allCases, id: \.self) { type in
                    ReportFilterChip(
                        title: type.rawValue,
                        isSelected: filterType == type,
                        action: { filterType = type }
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct ReportFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(15)
        }
    }
}

#Preview {
    ReportFilterSection(filterType: .constant(.learningProgress))
}
