import SwiftUI

struct SprintReportsDetailView: View {
    let reports: [SprintReport]
    let onBack: () -> Void
    
    @State private var expandedReports: Set<UUID> = []
    
    var body: some View {
        ZStack {
            Color("TelegramBackground", bundle: nil)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("📊 Отчеты спринтов")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .opacity(0)
                }
                .padding()
                .background(Color("TelegramHeaderBackground", bundle: nil))
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(reports) { report in
                            SprintReportCard(
                                report: report,
                                isExpanded: expandedReports.contains(report.id),
                                onToggle: {
                                    withAnimation {
                                        if expandedReports.contains(report.id) {
                                            expandedReports.remove(report.id)
                                        } else {
                                            expandedReports.insert(report.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct SprintReportCard: View {
    let report: SprintReport
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sprint \(report.sprintNumber)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(report.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    SprintStatusBadge(status: report.status)
                    
                    Text(report.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Divider()
                
                // Content
                Text(report.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                // Achievements
                if !report.achievements.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("✅ Достижения")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(report.achievements, id: \.self) { achievement in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.green)
                                Text(achievement)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Challenges
                if !report.challenges.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("⚠️ Проблемы")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(report.challenges, id: \.self) { challenge in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.orange)
                                Text(challenge)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Next Steps
                if !report.nextSteps.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("➡️ Следующие шаги")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(report.nextSteps, id: \.self) { step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.blue)
                                Text(step)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color("TelegramCardBackground", bundle: nil))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onToggle()
        }
    }
}

struct SprintStatusBadge: View {
    let status: SprintReport.SprintStatus
    
    var backgroundColor: Color {
        switch status {
        case .completed:
            return .green.opacity(0.2)
        case .inProgress:
            return .orange.opacity(0.2)
        case .planned:
            return .blue.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch status {
        case .completed:
            return .green
        case .inProgress:
            return .orange
        case .planned:
            return .blue
        }
    }
    
    var statusText: String {
        switch status {
        case .completed:
            return "Завершен"
        case .inProgress:
            return "В работе"
        case .planned:
            return "Запланирован"
        }
    }
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(6)
    }
} 