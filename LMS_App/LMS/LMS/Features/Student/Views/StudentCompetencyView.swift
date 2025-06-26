//
//  StudentCompetencyView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct StudentCompetencyView: View {
    @StateObject private var viewModel = CompetencyViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            Picker("Компетенции", selection: $selectedTab) {
                Text("Мои компетенции").tag(0)
                Text("Требуемые").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                // My competencies
                ScrollView {
                    VStack(spacing: 16) {
                        // Overall progress
                        CompetencyOverallProgress(
                            achieved: viewModel.myCompetencies.count,
                            total: viewModel.requiredCompetencies.count
                        )
                        
                        // Competency list
                        ForEach(viewModel.myCompetencies) { competency in
                            StudentCompetencyCard(competency: competency)
                        }
                    }
                    .padding()
                }
            } else {
                // Required competencies
                ScrollView {
                    VStack(spacing: 16) {
                        // Position info
                        PositionRequirementsCard(
                            position: "iOS Developer",
                            department: "IT Department"
                        )
                        
                        // Required competencies
                        ForEach(viewModel.requiredCompetencies) { competency in
                            RequiredCompetencyCard(
                                competency: competency,
                                currentLevel: viewModel.getCurrentLevel(for: competency)
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Компетенции")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadCompetencies()
        }
    }
}

// MARK: - Overall Progress
struct CompetencyOverallProgress: View {
    let achieved: Int
    let total: Int
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(achieved) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Общий прогресс")
                        .font(.headline)
                    Text("\(achieved) из \(total) компетенций достигнуто")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progress == 1.0 ? Color.green : Color.blue,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - Student Competency Card
struct StudentCompetencyCard: View {
    let competency: Competency
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Competency icon
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(competency.name)
                        .font(.headline)
                    
                    Text(competency.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Current level
                Text("Уровень \(competency.currentLevel)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(levelColor(competency.currentLevel))
                    .cornerRadius(20)
            }
            
            // Level progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    ForEach(1...5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(level <= competency.currentLevel ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 6)
                    }
                }
                
                HStack {
                    Text("Начальный")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Эксперт")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Courses for improvement
            if competency.currentLevel < 5 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Рекомендуемые курсы для развития:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(competency.recommendedCourses?.prefix(2) ?? [], id: \.self) { course in
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                    .font(.caption)
                                Text(course)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func levelColor(_ level: Int) -> Color {
        switch level {
        case 1: return .gray
        case 2: return .blue
        case 3: return .green
        case 4: return .orange
        case 5: return .purple
        default: return .gray
        }
    }
}

// MARK: - Position Requirements Card
struct PositionRequirementsCard: View {
    let position: String
    let department: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Требования для позиции")
                    .font(.headline)
                Text("\(position) • \(department)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "briefcase.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - Required Competency Card
struct RequiredCompetencyCard: View {
    let competency: Competency
    let currentLevel: Int
    
    var hasCompetency: Bool {
        currentLevel >= competency.requiredLevel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Status icon
                Image(systemName: hasCompetency ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(hasCompetency ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(competency.name)
                        .font(.headline)
                    
                    Text("Требуется: Уровень \(competency.requiredLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentLevel > 0 {
                    Text("Текущий: \(currentLevel)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(hasCompetency ? .green : .orange)
                } else {
                    Text("Не изучено")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            
            // Progress to required level
            if currentLevel > 0 && !hasCompetency {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        ForEach(1...competency.requiredLevel, id: \.self) { level in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(level <= currentLevel ? Color.orange : Color.gray.opacity(0.3))
                                .frame(height: 6)
                        }
                    }
                    
                    Text("Необходимо повысить на \(competency.requiredLevel - currentLevel) уровень")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action button
            if !hasCompetency {
                NavigationLink(destination: StudentCourseListView()) {
                    HStack {
                        Text("Найти курсы")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        StudentCompetencyView()
    }
} 