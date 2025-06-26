//
//  CourseListView.swift
//  LMS
//
//  Created on 19/01/2025.
//

import SwiftUI

struct CourseListView: View {
    @StateObject private var viewModel = CourseViewModel()
    @State private var showFilters = false
    @State private var selectedCourse: Course?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Статистика обучения
                    LearningStatsCard()
                        .padding(.horizontal)
                    
                    // Поиск и фильтры
                    SearchAndFilterBar()
                        .padding(.horizontal)
                    
                    // Рекомендации (если не применены фильтры)
                    if viewModel.searchText.isEmpty && viewModel.selectedCategory == "Все" {
                        RecommendedCoursesSection()
                    }
                    
                    // Список курсов
                    CourseGrid()
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Курсы")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                CourseFiltersView(viewModel: viewModel)
            }
        }
        .environmentObject(viewModel)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func LearningStatsCard() -> some View {
        VStack(spacing: 15) {
            HStack {
                Text("Моё обучение")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: MyCoursesView()) {
                    Text("Все курсы")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "book.fill",
                    value: "\(viewModel.enrolledCoursesCount)",
                    label: "Курсов",
                    color: .blue
                )
                
                StatItem(
                    icon: "checkmark.seal.fill",
                    value: "\(viewModel.completedCoursesCount)",
                    label: "Завершено",
                    color: .green
                )
                
                StatItem(
                    icon: "clock.fill",
                    value: viewModel.formattedTotalTime,
                    label: "Времени",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private func SearchAndFilterBar() -> some View {
        VStack(spacing: 12) {
            // Поиск
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Поиск курсов...", text: $viewModel.searchText)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Быстрые фильтры
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Категории
                    ForEach(viewModel.categories, id: \.self) { category in
                        FilterChip(
                            title: category,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Показать только записанные
                    FilterChip(
                        title: "Мои курсы",
                        isSelected: viewModel.showOnlyEnrolled,
                        icon: "person.fill"
                    ) {
                        viewModel.showOnlyEnrolled.toggle()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func RecommendedCoursesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Рекомендуем")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.getRecommendedCourses(for: "user123")) { course in
                        NavigationLink(destination: CourseDetailView(course: course)) {
                            RecommendedCourseCard(course: course)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func CourseGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
            ForEach(viewModel.filteredCourses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    CourseCard(course: course, viewModel: viewModel)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
    }
}

struct RecommendedCourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Заглушка для изображения
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 200, height: 120)
                .overlay(
                    VStack {
                        Image(systemName: course.format.icon)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text(course.category)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack {
                    Label("\(course.formattedDuration)", systemImage: "clock")
                    Spacer()
                    Label(String(format: "%.1f", course.averageRating), systemImage: "star.fill")
                        .foregroundColor(.orange)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .frame(width: 200)
    }
}

struct CourseCard: View {
    let course: Course
    @ObservedObject var viewModel: CourseViewModel
    
    private var progress: CourseProgress? {
        viewModel.getProgress(for: course)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 10)
                .fill(course.level.color.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: course.format.icon)
                            .font(.title2)
                            .foregroundColor(course.level.color)
                        Text(course.level.rawValue)
                            .font(.caption2)
                            .foregroundColor(course.level.color)
                    }
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(course.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let status = progress?.status {
                        StatusBadge(status: status)
                    }
                }
                
                Text(course.shortDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Label(course.formattedDuration, systemImage: "clock")
                    Label("\(course.totalLessons) уроков", systemImage: "list.bullet")
                    
                    Spacer()
                    
                    if let progress = progress {
                        ProgressView(value: progress.overallProgress)
                            .frame(width: 50)
                        Text("\(progress.progressPercentage)%")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    } else {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f", course.averageRating))
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: EnrollmentStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.2))
        .foregroundColor(status.color)
        .cornerRadius(8)
    }
} 