//
//  TestDetailView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestDetailView: View {
    let test: Test
    @ObservedObject var viewModel: TestViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showTestPlayer = false
    @State private var showResults = false
    @State private var selectedResult: TestResult?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Description
                descriptionSection
                
                // Test info
                infoSection
                
                // Requirements
                if !test.competencyIds.isEmpty || !test.positionIds.isEmpty {
                    requirementsSection
                }
                
                // User progress
                if let result = viewModel.getUserTestResult(test) {
                    userProgressSection(result: result)
                }
                
                // Attempts history
                attemptHistorySection
                
                // Questions preview
                if test.showCorrectAnswers {
                    questionsPreviewSection
                }
                
                // Action button
                actionSection
            }
            .padding()
        }
        .navigationTitle("Детали теста")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
        .fullScreenCover(isPresented: $showTestPlayer) {
            TestPlayerView(test: test, viewModel: viewModel)
        }
        .sheet(item: $selectedResult) { result in
            NavigationView {
                TestResultView(result: result)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: test.type.icon)
                    .font(.largeTitle)
                    .foregroundColor(test.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(test.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 12) {
                        Label(test.type.rawValue, systemImage: test.type.icon)
                            .foregroundColor(test.type.color)
                        
                        Label(test.difficulty.rawValue, systemImage: test.difficulty.icon)
                            .foregroundColor(test.difficulty.color)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
                
                statusBadge
            }
        }
    }
    
    private var statusBadge: some View {
        Text(test.status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(test.status.color)
            .cornerRadius(10)
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            
            Text(test.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация о тесте")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                TestInfoCard(
                    icon: "questionmark.circle",
                    title: "Вопросов",
                    value: "\(test.totalQuestions)"
                )
                
                TestInfoCard(
                    icon: "sum",
                    title: "Баллов",
                    value: String(format: "%.0f", test.totalPoints)
                )
                
                TestInfoCard(
                    icon: "timer",
                    title: "Время",
                    value: test.timeLimit != nil ? "\(test.timeLimit!) мин" : "Без ограничений"
                )
                
                TestInfoCard(
                    icon: "arrow.clockwise",
                    title: "Попыток",
                    value: test.attemptsAllowed != nil ? "\(test.attemptsAllowed!)" : "Неограниченно"
                )
                
                TestInfoCard(
                    icon: "percent",
                    title: "Проходной балл",
                    value: String(format: "%.0f%%", test.passingScore)
                )
                
                TestInfoCard(
                    icon: "eye",
                    title: "Ответы",
                    value: test.showCorrectAnswers ? "Показываются" : "Скрыты"
                )
            }
        }
    }
    
    // MARK: - Requirements Section
    
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Требования")
                .font(.headline)
            
            if !test.competencyIds.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Связанные компетенции:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(test.competencyIds, id: \.self) { competencyId in
                            CompetencyChip(competencyId: competencyId)
                        }
                    }
                }
            }
            
            if !test.positionIds.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Для должностей:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(test.positionIds, id: \.self) { positionId in
                            PositionChip(positionId: positionId)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - User Progress Section
    
    private func userProgressSection(result: TestResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ваш результат")
                .font(.headline)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Последняя попытка")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(result.completedAt, formatter: dateTimeFormatter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: result.resultIcon)
                                .foregroundColor(result.resultColor)
                            Text(result.resultText)
                                .fontWeight(.semibold)
                                .foregroundColor(result.resultColor)
                        }
                        
                        Text(result.percentageText)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(result.resultColor)
                            .frame(width: geometry.size.width * (result.percentage / 100), height: 20)
                        
                        Text(result.scoreText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                    }
                }
                .frame(height: 20)
                
                // Details button
                Button(action: { selectedResult = result }) {
                    Label("Подробные результаты", systemImage: "doc.text.magnifyingglass")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Attempt History Section
    
    private var attemptHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История попыток")
                .font(.headline)
            
            let attempts = viewModel.service.getUserAttempts(userId: viewModel.currentUserId, testId: test.id)
            
            if attempts.isEmpty {
                Text("Вы еще не проходили этот тест")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(attempts.sorted(by: { $0.startedAt ?? Date() > $1.startedAt ?? Date() })) { attempt in
                    AttemptRow(attempt: attempt) {
                        if let result = viewModel.service.results.first(where: { $0.attemptId == attempt.id }) {
                            selectedResult = result
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Questions Preview Section
    
    private var questionsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Типы вопросов")
                .font(.headline)
            
            let questionsByType = Dictionary(grouping: test.questions, by: { $0.type })
            
            ForEach(Array(questionsByType.keys), id: \.self) { type in
                HStack {
                    Image(systemName: type.icon)
                        .foregroundColor(.blue)
                    
                    Text(type.rawValue)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(questionsByType[type]?.count ?? 0) вопросов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Action Section
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            if let activeAttempt = viewModel.service.getActiveAttempt(userId: viewModel.currentUserId, testId: test.id) {
                Button(action: { showTestPlayer = true }) {
                    Label("Продолжить тест", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("У вас есть незавершенная попытка")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if viewModel.canRetakeTest(test) && test.canBeTaken {
                Button(action: { 
                    viewModel.startTest(test)
                    showTestPlayer = true
                }) {
                    Label("Начать тест", systemImage: "play")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                if let maxAttempts = test.attemptsAllowed {
                    let usedAttempts = viewModel.service.getUserAttempts(userId: viewModel.currentUserId, testId: test.id).count
                    Text("Использовано попыток: \(usedAttempts) из \(maxAttempts)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Тест недоступен")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding(.top)
    }
}

// MARK: - Helper Views

struct TestInfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CompetencyChip: View {
    let competencyId: String
    
    var body: some View {
        Text(competencyId) // В реальном приложении получать название из сервиса
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
}

struct PositionChip: View {
    let positionId: String
    
    var body: some View {
        Text(positionId) // В реальном приложении получать название из сервиса
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .cornerRadius(8)
    }
}

struct AttemptRow: View {
    let attempt: TestAttempt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Попытка #\(attempt.attemptNumber)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let startedAt = attempt.startedAt {
                        Text(startedAt, formatter: dateTimeFormatter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: attempt.status.icon)
                        Text(attempt.status.rawValue)
                    }
                    .font(.caption)
                    .foregroundColor(attempt.status.color)
                    
                    if let percentage = attempt.percentage {
                        Text(String(format: "%.1f%%", percentage))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                     y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                maxHeight = max(maxHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: y + maxHeight)
        }
    }
}

// MARK: - Date Formatter

private let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - Preview

struct TestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestDetailView(test: TestMockService().tests.first!, viewModel: TestViewModel())
        }
    }
} 