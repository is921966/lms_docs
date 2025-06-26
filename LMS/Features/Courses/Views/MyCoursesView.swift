//
//  MyCoursesView.swift
//  LMS
//
//  Created on 19/01/2025.
//

import SwiftUI

struct MyCoursesView: View {
    @EnvironmentObject var viewModel: CourseViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Табы
                Picker("", selection: $selectedTab) {
                    Text("В процессе").tag(0)
                    Text("Завершенные").tag(1)
                    Text("Все").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Список курсов
                if enrolledCourses.isEmpty {
                    EmptyStateView()
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(enrolledCourses) { course in
                            if let progress = viewModel.getProgress(for: course) {
                                NavigationLink(destination: CourseDetailView(course: course)) {
                                    MyCourseCard(course: course, progress: progress)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Мои курсы")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var enrolledCourses: [Course] {
        let enrolledIds = viewModel.userProgress.compactMap { progress -> String? in
            switch selectedTab {
            case 0: // В процессе
                return progress.status == .inProgress ? progress.courseId : nil
            case 1: // Завершенные
                return progress.status == .completed ? progress.courseId : nil
            default: // Все
                return progress.courseId
            }
        }
        
        return viewModel.courses.filter { enrolledIds.contains($0.id.uuidString) }
    }
}

struct MyCourseCard: View {
    let course: Course
    let progress: CourseProgress
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(alignment: .top, spacing: 15) {
                // Thumbnail
                RoundedRectangle(cornerRadius: 10)
                    .fill(course.level.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: course.format.icon)
                            .font(.title2)
                            .foregroundColor(course.level.color)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(course.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    HStack {
                        StatusBadge(status: progress.status)
                        
                        if progress.hasCertificate {
                            Image(systemName: "seal.fill")
                                .foregroundColor(.purple)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Text(relativeDate(from: progress.lastAccessedAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Прогресс: \(progress.progressPercentage)%")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if progress.status == .inProgress {
                        Text("Потрачено: \(progress.formattedTimeSpent)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if let score = progress.score {
                        Text("Оценка: \(Int(score))%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                ProgressView(value: progress.overallProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var progressColor: Color {
        switch progress.status {
        case .completed: return .green
        case .inProgress: return .blue
        case .failed: return .red
        default: return .gray
        }
    }
    
    private func relativeDate(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Вы пока не записаны на курсы")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Изучите каталог курсов и выберите интересующие вас темы")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
} 