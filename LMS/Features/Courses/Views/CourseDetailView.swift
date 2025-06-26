//
//  CourseDetailView.swift
//  LMS
//
//  Created on 19/01/2025.
//

import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject var viewModel: CourseViewModel
    @State private var selectedTab = 0
    @State private var showEnrollAlert = false
    
    private var isEnrolled: Bool {
        viewModel.isEnrolled(course)
    }
    
    private var progress: CourseProgress? {
        viewModel.getProgress(for: course)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                CourseHeaderView(course: course)
                
                // Основная информация
                CourseInfoSection()
                
                // Кнопка записи/продолжения
                ActionButton()
                    .padding(.horizontal)
                
                // Табы с контентом
                TabSelector()
                
                // Контент в зависимости от выбранного таба
                switch selectedTab {
                case 0:
                    LessonsListView()
                case 1:
                    CourseRequirementsView()
                case 2:
                    CourseReviewsView()
                default:
                    EmptyView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Запись на курс", isPresented: $showEnrollAlert) {
            Button("Записаться") {
                viewModel.enrollInCourse(course)
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы хотите записаться на курс \"\(course.title)\"?")
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func CourseHeaderView(course: Course) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            LinearGradient(
                colors: [course.level.color.opacity(0.8), course.level.color.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    StatusBadge(status: course.status)
                    
                    HStack(spacing: 4) {
                        Image(systemName: course.level.icon)
                        Text(course.level.rawValue)
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    
                    Spacer()
                }
                
                Text(course.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Автор: \(course.authorName)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func CourseInfoSection() -> some View {
        VStack(spacing: 15) {
            Text(course.description)
                .font(.body)
                .padding(.horizontal)
            
            // Ключевые метрики
            HStack(spacing: 20) {
                InfoItem(
                    icon: "clock",
                    value: course.formattedDuration,
                    label: "Длительность"
                )
                
                InfoItem(
                    icon: "calendar",
                    value: "\(course.estimatedWeeks) нед",
                    label: "Срок изучения"
                )
                
                InfoItem(
                    icon: "person.2",
                    value: "\(course.enrolledCount)",
                    label: "Студентов"
                )
                
                InfoItem(
                    icon: "star.fill",
                    value: String(format: "%.1f", course.averageRating),
                    label: "Рейтинг",
                    color: .orange
                )
            }
            .padding(.horizontal)
            
            // Теги
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(course.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func ActionButton() -> some View {
        if let progress = progress {
            switch progress.status {
            case .enrolled:
                NavigationLink(destination: LessonPlayerView(course: course)) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Начать обучение")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            case .inProgress:
                NavigationLink(destination: LessonPlayerView(course: course)) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Продолжить обучение")
                        Spacer()
                        Text("\(progress.progressPercentage)%")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            case .completed:
                if progress.hasCertificate {
                    NavigationLink(destination: CertificateView(certificateId: progress.certificateId!)) {
                        HStack {
                            Image(systemName: "seal.fill")
                            Text("Посмотреть сертификат")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Text("Курс завершен")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            default:
                EmptyView()
            }
        } else {
            Button(action: { showEnrollAlert = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Записаться на курс")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func TabSelector() -> some View {
        Picker("", selection: $selectedTab) {
            Text("Программа").tag(0)
            Text("Требования").tag(1)
            Text("Отзывы (\(course.reviewsCount))").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    @ViewBuilder
    private func LessonsListView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Программа курса")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(Array(course.lessons.enumerated()), id: \.element.id) { index, lesson in
                LessonRow(lesson: lesson, index: index + 1, isAccessible: isEnrolled)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func CourseRequirementsView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Предварительные требования
            if !course.requiredCompetencies.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Необходимые знания")
                        .font(.headline)
                    
                    ForEach(course.requiredCompetencies) { req in
                        HStack {
                            Image(systemName: req.isCritical ? "exclamationmark.circle.fill" : "info.circle")
                                .foregroundColor(req.isCritical ? .red : .blue)
                            
                            Text(req.competencyName)
                            
                            Spacer()
                            
                            Text("Уровень \(req.requiredLevel)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
            
            // Развиваемые компетенции
            if !course.targetCompetencies.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Что вы изучите")
                        .font(.headline)
                    
                    ForEach(course.targetCompetencies) { comp in
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.green)
                            
                            Text(comp.competencyName)
                            
                            Spacer()
                            
                            Text("до уровня \(comp.requiredLevel)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func CourseReviewsView() -> some View {
        VStack(spacing: 15) {
            Text("Отзывы пока не реализованы")
                .foregroundColor(.gray)
                .padding()
        }
    }
}

// MARK: - Supporting Views

struct InfoItem: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .primary
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LessonRow: View {
    let lesson: Lesson
    let index: Int
    let isAccessible: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Номер урока
            Text("\(index)")
                .font(.headline)
                .foregroundColor(isAccessible ? .white : .gray)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isAccessible ? lesson.type.color : Color.gray.opacity(0.3))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: lesson.type.icon)
                        .foregroundColor(lesson.type.color)
                    Text(lesson.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text(lesson.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Label(lesson.formattedDuration, systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if lesson.hasQuiz {
                        Label("Тест", systemImage: "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    if !lesson.materials.isEmpty {
                        Label("\(lesson.materials.count) материалов", systemImage: "paperclip")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            if isAccessible {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isAccessible ? 1.0 : 0.6)
    }
} 