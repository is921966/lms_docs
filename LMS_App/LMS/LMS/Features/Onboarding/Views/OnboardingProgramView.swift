//
//  OnboardingProgramView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct OnboardingProgramView: View {
    let program: OnboardingProgram
    @State private var selectedStage: OnboardingStage?
    @State private var showingTask = false
    @State private var showingActions = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                ProgramHeaderView(program: program)
                
                // Progress Overview
                ProgressOverview(program: program)
                
                // Timeline
                VStack(alignment: .leading, spacing: 16) {
                    Text("Этапы программы")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(Array(program.stages.enumerated()), id: \.element.id) { index, stage in
                        StageTimelineItem(
                            stage: stage,
                            isFirst: index == 0,
                            isLast: index == program.stages.count - 1,
                            isCurrent: stage.id == program.currentStage?.id
                        ) {
                            selectedStage = stage
                            showingTask = true
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingActions = true }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $selectedStage) { stage in
            OnboardingStageView(stage: stage, program: program)
        }
        .actionSheet(isPresented: $showingActions) {
            ActionSheet(
                title: Text("Действия с программой"),
                buttons: [
                    .default(Text("Отправить напоминание")) {
                        // Send reminder
                    },
                    .default(Text("Изменить сроки")) {
                        // Edit dates
                    },
                    .destructive(Text("Отменить программу")) {
                        // Cancel program
                    },
                    .cancel()
                ]
            )
        }
    }
}

// MARK: - Program Header
struct ProgramHeaderView: View {
    let program: OnboardingProgram
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(program.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(program.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: program.status, isOverdue: program.isOverdue)
            }
            
            // Employee info
            HStack(spacing: 20) {
                EmployeeInfoItem(
                    icon: "person.fill",
                    title: "Сотрудник",
                    value: program.employeeName
                )
                
                EmployeeInfoItem(
                    icon: "briefcase.fill",
                    title: "Должность",
                    value: program.employeePosition
                )
                
                EmployeeInfoItem(
                    icon: "building.2.fill",
                    title: "Отдел",
                    value: program.employeeDepartment
                )
            }
            
            Divider()
            
            // Dates and manager
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Руководитель")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(program.managerName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Срок выполнения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDate(program.targetEndDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(program.isOverdue ? .red : .primary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Employee Info Item
struct EmployeeInfoItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Progress Overview
struct ProgressOverview: View {
    let program: OnboardingProgram
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Общий прогресс")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(Int(program.overallProgress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * program.overallProgress, height: 12)
                    }
                }
                .frame(height: 12)
            }
            
            // Stats
            HStack(spacing: 20) {
                ProgressStat(
                    title: "Этапов",
                    value: "\(program.completedStages)/\(program.stages.count)",
                    icon: "flag.checkered",
                    color: .green
                )
                
                ProgressStat(
                    title: "Дней осталось",
                    value: program.isOverdue ? "Просрочено" : "\(program.daysRemaining)",
                    icon: "calendar",
                    color: program.isOverdue ? .red : .orange
                )
                
                if let currentStage = program.currentStage {
                    ProgressStat(
                        title: "Текущий этап",
                        value: "\(currentStage.completedTasks)/\(currentStage.tasks.count)",
                        icon: "checkmark.square",
                        color: .blue
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// MARK: - Progress Stat
struct ProgressStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stage Timeline Item
struct StageTimelineItem: View {
    let stage: OnboardingStage
    let isFirst: Bool
    let isLast: Bool
    let isCurrent: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(stage.status == .completed ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 2, height: 20)
                }
                
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: stage.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(stage.status == .completed ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 2)
                }
            }
            .frame(width: 40)
            
            // Stage content
            Button(action: action) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Этап \(stage.orderIndex): \(stage.title)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(stage.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if isCurrent {
                            Text("Текущий")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Progress
                    HStack {
                        Text("\(stage.completedTasks)/\(stage.tasks.count) задач")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(stage.duration) дн.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(progressColor)
                                .frame(width: geometry.size.width * stage.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }
    
    private var backgroundColor: Color {
        switch stage.status {
        case .completed: return .green
        case .inProgress: return .blue
        case .notStarted: return .gray
        case .cancelled: return .red
        }
    }
    
    private var progressColor: Color {
        if stage.status == .completed {
            return .green
        } else if stage.progress > 0 {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
}

#Preview {
    NavigationView {
        OnboardingProgramView(
            program: OnboardingProgram.createMockPrograms()[0]
        )
    }
} 