//
//  StudentCourseListView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct StudentCourseListView: View {
    @StateObject private var viewModel = CourseViewModel()
    @State private var selectedTab = 0
    @State private var searchText = ""

    var filteredCourses: [Course] {
        let courses = selectedTab == 0 ? viewModel.enrolledCourses : viewModel.availableCourses

        if searchText.isEmpty {
            return courses
        }

        return courses.filter { course in
            course.title.localizedCaseInsensitiveContains(searchText) ||
            course.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            Picker("Курсы", selection: $selectedTab) {
                Text("Мои курсы").tag(0)
                Text("Доступные").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Поиск курсов", text: $searchText)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)

            // Course list
            if filteredCourses.isEmpty {
                                    StudentEmptyStateView(
                    icon: "book.closed",
                    title: selectedTab == 0 ? "Нет активных курсов" : "Нет доступных курсов",
                    subtitle: selectedTab == 0
                        ? "Запишитесь на курсы из вкладки \"Доступные\""
                        : "Все доступные курсы уже пройдены или недоступны"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredCourses) { course in
                            StudentCourseCard(
                                course: course,
                                isEnrolled: selectedTab == 0
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Обучение")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadCourses()
        }
    }
}

// MARK: - Student Course Card
struct StudentCourseCard: View {
    let course: Course
    let isEnrolled: Bool
    @State private var showingCourseDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                // Course icon
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.headline)
                        .lineLimit(2)

                    Text(course.category?.displayName ?? "Общее")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isEnrolled {
                    // Progress indicator
                    CircularProgressView(progress: 0.0) // TODO: Add course progress
                        .frame(width: 40, height: 40)
                }
            }

            // Description
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Info chips
            HStack(spacing: 12) {
                InfoChip(
                    icon: "clock",
                    text: "\(course.duration) ч",
                    color: .orange
                )

                InfoChip(
                    icon: "chart.bar",
                    text: course.duration,
                    color: .purple
                )

                if !course.modules.isEmpty {
                    InfoChip(
                        icon: "square.grid.2x2",
                        text: "\(course.modules.count) модулей",
                        color: .green
                    )
                }

                if course.hasCertificate {
                    InfoChip(
                        icon: "seal",
                        text: "Сертификат",
                        color: .blue
                    )
                }
            }

            // Action button
            if isEnrolled {
                NavigationLink(destination: CourseDetailView(course: course)) {
                    HStack {
                        Text("Продолжить обучение")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            } else {
                Button(action: {
                    // TODO: Enroll in course
                }) {
                    HStack {
                        Text("Записаться на курс")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "plus.circle.fill")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Info Chip
struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progress == 1.0 ? Color.green : Color.blue,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Empty State View
struct StudentEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        StudentCourseListView()
    }
}
