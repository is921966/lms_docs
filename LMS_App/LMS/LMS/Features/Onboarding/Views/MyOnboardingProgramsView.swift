//
//  MyOnboardingProgramsView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct MyOnboardingProgramsView: View {
    @StateObject private var onboardingService = OnboardingMockService.shared
    @StateObject private var authService = MockAuthService.shared
    @State private var selectedProgram: OnboardingProgram?
    
    var userPrograms: [OnboardingProgram] {
        guard let userIdString = authService.currentUser?.id,
              let userId = UUID(uuidString: userIdString) else { return [] }
        return onboardingService.getPrograms().filter { $0.employeeId == userId }
    }
    
    var body: some View {
        ScrollView {
            if userPrograms.isEmpty {
                MyOnboardingEmptyStateView()
            } else {
                VStack(spacing: 20) {
                    // Active programs
                    let activePrograms = userPrograms.filter { $0.status == .inProgress }
                    if !activePrograms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Активные программы")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(activePrograms) { program in
                                MyProgramCard(program: program) {
                                    selectedProgram = program
                                }
                            }
                        }
                    }
                    
                    // Completed programs
                    let completedPrograms = userPrograms.filter { $0.status == .completed }
                    if !completedPrograms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Завершенные программы")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            ForEach(completedPrograms) { program in
                                MyProgramCard(program: program) {
                                    selectedProgram = program
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Мои программы адаптации")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedProgram) { program in
            NavigationView {
                OnboardingProgramView(program: program)
            }
        }
    }
}

// MARK: - My Program Card
struct MyProgramCard: View {
    let program: OnboardingProgram
    let onTap: () -> Void
    
    var currentTaskDescription: String {
        if let currentStage = program.currentStage,
           let currentTask = currentStage.tasks.first(where: { !$0.isCompleted }) {
            return currentTask.title
        }
        return "Нет активных задач"
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(program.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Руководитель: \(program.managerName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: program.status, isOverdue: program.isOverdue)
                }
                
                // Current stage info
                if let currentStage = program.currentStage {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Текущий этап: \(currentStage.title)", systemImage: currentStage.icon)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Text("Текущая задача: \(currentTaskDescription)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                // Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Общий прогресс")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(program.overallProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * program.overallProgress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Stats
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "flag.checkered")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(program.completedStages)/\(program.stages.count) этапов")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if program.status == .inProgress {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(program.isOverdue ? .red : .gray)
                            Text(program.isOverdue ? "Просрочено" : "Осталось \(program.daysRemaining) дн.")
                                .font(.caption)
                                .foregroundColor(program.isOverdue ? .red : .secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State
struct MyOnboardingEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет программ адаптации")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("У вас пока нет назначенных программ онбординга")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationView {
        MyOnboardingProgramsView()
    }
}
