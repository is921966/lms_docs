//
//  StudentDashboardView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct StudentDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingNotifications = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Добро пожаловать!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let userName = authViewModel.currentUser?.firstName {
                        Text("Привет, \(userName)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Personal stats
                PersonalStatsSection()
                
                // Active courses
                ActiveCoursesSection()
                
                // Upcoming tests
                UpcomingTestsSection()
                
                // Recent achievements
                RecentAchievementsSection()
                
                Spacer(minLength: 100)
            }
            .padding(.vertical)
        }
        .navigationTitle("Главная")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingNotifications = true
                }) {
                    ZStack {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                        
                        if notificationService.unreadCount > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text("\(notificationService.unreadCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationListView()
        }
    }
}

// MARK: - Personal Stats Section
struct PersonalStatsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Моя статистика")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    PersonalStatCard(
                        title: "Курсов пройдено",
                        value: "8",
                        total: "12",
                        icon: "book.fill",
                        color: .blue
                    )
                    
                    PersonalStatCard(
                        title: "Средний балл",
                        value: "4.5",
                        total: "5.0",
                        icon: "star.fill",
                        color: .orange
                    )
                    
                    PersonalStatCard(
                        title: "Компетенций",
                        value: "6",
                        total: "10",
                        icon: "chart.bar.fill",
                        color: .green
                    )
                    
                    PersonalStatCard(
                        title: "Сертификатов",
                        value: "3",
                        total: nil,
                        icon: "seal.fill",
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Active Courses Section
struct ActiveCoursesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Активные курсы")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: StudentCourseListView()) {
                    Text("Все курсы")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { _ in
                        ActiveCourseCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Upcoming Tests Section
struct UpcomingTestsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Предстоящие тесты")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: StudentTestListView()) {
                    Text("Все тесты")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                UpcomingTestRow(
                    title: "Основы iOS разработки",
                    deadline: "Завтра",
                    questions: 25,
                    duration: 45,
                    isUrgent: true
                )
                
                UpcomingTestRow(
                    title: "SwiftUI Advanced",
                    deadline: "Через 3 дня",
                    questions: 30,
                    duration: 60,
                    isUrgent: false
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Recent Achievements Section
struct RecentAchievementsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Последние достижения")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                AchievementRow(
                    title: "Завершен курс iOS разработка",
                    time: "2 часа назад",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                AchievementRow(
                    title: "Получена компетенция: SwiftUI",
                    time: "Вчера",
                    icon: "star.fill",
                    color: .orange
                )
                
                AchievementRow(
                    title: "Сертификат: Mobile Development",
                    time: "3 дня назад",
                    icon: "seal.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Helper Views
struct PersonalStatCard: View {
    let title: String
    let value: String
    let total: String?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            if let total = total {
                Text("\(value)/\(total)")
                    .font(.title3)
                    .fontWeight(.bold)
            } else {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120, height: 120)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActiveCourseCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "book.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("iOS Development")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            Text("Модуль 3 из 8")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Progress
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.65, height: 4)
                }
            }
            .frame(height: 4)
            
            Text("65%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(width: 160)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct UpcomingTestRow: View {
    let title: String
    let deadline: String
    let questions: Int
    let duration: Int
    let isUrgent: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.title3)
                .foregroundColor(isUrgent ? .red : .blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    Label(deadline, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(isUrgent ? .red : .secondary)
                    
                    Label("\(questions) вопросов", systemImage: "questionmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(duration) мин", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isUrgent {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AchievementRow: View {
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        StudentDashboardView()
            .environmentObject(AuthViewModel())
    }
} 