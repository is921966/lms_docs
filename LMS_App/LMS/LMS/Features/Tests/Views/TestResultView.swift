//
//  TestResultView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestResultView: View {
    let result: TestResult
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall result
                overallResultSection
                
                // Tabs
                Picker("", selection: $selectedTab) {
                    Text("Обзор").tag(0)
                    Text("По вопросам").tag(1)
                    Text("По типам").tag(2)
                    Text("Рекомендации").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab content
                switch selectedTab {
                case 0:
                    overviewTab
                case 1:
                    questionsTab
                case 2:
                    typesTab
                case 3:
                    recommendationsTab
                default:
                    EmptyView()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Результаты теста")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
    }
    
    // MARK: - Overall Result Section
    
    private var overallResultSection: some View {
        VStack(spacing: 16) {
            // Result icon
            Image(systemName: result.resultIcon)
                .font(.system(size: 60))
                .foregroundColor(result.resultColor)
            
            // Result text
            Text(result.resultText)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(result.resultColor)
            
            // Score
            Text(result.percentageText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Text(result.scoreText)
                .font(.title3)
                .foregroundColor(.secondary)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 24)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(result.resultColor)
                        .frame(width: geometry.size.width * (result.percentage / 100), height: 24)
                    
                    // Passing score indicator
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2, height: 32)
                        .offset(x: geometry.size.width * (result.passingScore / 100) - 1)
                    
                    Text(String(format: "%.0f%%", result.passingScore))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .offset(x: geometry.size.width * (result.passingScore / 100) - 20, y: -25)
                }
            }
            .frame(height: 32)
            .padding(.horizontal)
            
            // Time spent
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.blue)
                Text("Время: \(result.formattedTime)")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        VStack(spacing: 16) {
            // Statistics cards
            HStack(spacing: 12) {
                TestStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(result.correctAnswersCount)",
                    label: "Правильно",
                    color: .green
                )
                
                TestStatCard(
                    icon: "xmark.circle.fill",
                    value: "\(result.incorrectAnswersCount)",
                    label: "Неправильно",
                    color: .red
                )
                
                if result.pendingReviewCount > 0 {
                    TestStatCard(
                        icon: "questionmark.circle.fill",
                        value: "\(result.pendingReviewCount)",
                        label: "На проверке",
                        color: .orange
                    )
                }
            }
            .padding(.horizontal)
            
            // Average time per question
            InfoRow(
                icon: "clock",
                title: "Среднее время на вопрос",
                value: "\(result.averageTimePerQuestion) сек"
            )
            
            // Completed date
            InfoRow(
                icon: "calendar",
                title: "Дата прохождения",
                value: result.completedAt.formatted(date: .abbreviated, time: .shortened)
            )
            
            // Certificate
            if result.hasCertificate {
                certificateSection
            }
        }
    }
    
    // MARK: - Questions Tab
    
    private var questionsTab: some View {
        VStack(spacing: 12) {
            ForEach(result.questionResults) { questionResult in
                QuestionResultCard(questionResult: questionResult)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Types Tab
    
    private var typesTab: some View {
        VStack(spacing: 16) {
            ForEach(Array(result.scoreByType.sorted(by: { $0.key.rawValue < $1.key.rawValue })), id: \.key) { type, score in
                TypeScoreCard(type: type, score: score, questions: result.questionsByType[type] ?? [])
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Recommendations Tab
    
    private var recommendationsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !result.weaknessCompetencies.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Компетенции для развития", systemImage: "exclamationmark.triangle")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    ForEach(result.weaknessCompetencies, id: \.self) { competency in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(competency)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            
            if !result.strengthCompetencies.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Сильные компетенции", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    ForEach(result.strengthCompetencies, id: \.self) { competency in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(competency)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            if !result.recommendedCourses.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Рекомендуемые курсы", systemImage: "book.fill")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ForEach(result.recommendedCourses, id: \.self) { course in
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(course)
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Certificate Section
    
    private var certificateSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "seal.fill")
                .font(.largeTitle)
                .foregroundColor(.purple)
            
            Text("Сертификат получен!")
                .font(.headline)
            
            Button(action: {
                // Открыть сертификат
            }) {
                Label("Просмотреть сертификат", systemImage: "doc.text.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Share Button
    
    private var shareButton: some View {
        Button(action: shareResult) {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    private func shareResult() {
        // Реализация share функционала
    }
}

// MARK: - Helper Views

struct TestStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct QuestionResultCard: View {
    let questionResult: QuestionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: questionResult.resultIcon)
                    .foregroundColor(questionResult.resultColor)
                
                Text("Вопрос #\(questionResult.id.uuidString.prefix(4))")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(questionResult.scoreText)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            Text(questionResult.questionText)
                .font(.subheadline)
                .lineLimit(2)
            
            if let feedback = questionResult.feedback {
                Text(feedback)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let correctAnswer = questionResult.correctAnswer {
                HStack {
                    Text("Правильный ответ:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(correctAnswer)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct TypeScoreCard: View {
    let type: QuestionType
    let score: Double
    let questions: [QuestionResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: type.icon)
                    .foregroundColor(.blue)
                
                Text(type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.0f%%", score))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor(score))
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(scoreColor(score))
                        .frame(width: geometry.size.width * (score / 100), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(questions.count) вопросов")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(questions.filter { $0.isCorrect == true }.count) правильных")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Preview

struct TestResultView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestResultView(result: TestResult(
                attemptId: UUID(),
                testId: UUID(),
                userId: "user-1",
                totalScore: 85,
                maxScore: 100,
                percentage: 85,
                isPassed: true,
                passingScore: 70,
                questionResults: [],
                totalTimeSeconds: 1200,
                averageTimePerQuestion: 60
            ))
        }
    }
} 