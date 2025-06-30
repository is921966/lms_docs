//
//  AdminContentView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct AdminContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Content type selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ContentTypeCard(
                        icon: "book.fill",
                        title: "Курсы",
                        count: 156,
                        color: .blue,
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }

                    ContentTypeCard(
                        icon: "doc.text.magnifyingglass",
                        title: "Тесты",
                        count: 423,
                        color: .orange,
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }

                    ContentTypeCard(
                        icon: "star.fill",
                        title: "Компетенции",
                        count: 89,
                        color: .purple,
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }

                    ContentTypeCard(
                        icon: "seal.fill",
                        title: "Сертификаты",
                        count: 12,
                        color: .green,
                        isSelected: selectedTab == 3
                    ) {
                        selectedTab = 3
                    }

                    ContentTypeCard(
                        icon: "person.badge.clock.fill",
                        title: "Онбординг",
                        count: 24,
                        color: .indigo,
                        isSelected: selectedTab == 4
                    ) {
                        selectedTab = 4
                    }
                }
                .padding()
            }

            // Content list based on selection
            switch selectedTab {
            case 0:
                AdminCourseListView()
            case 1:
                AdminTestListView()
            case 2:
                AdminCompetencyListView()
            case 3:
                AdminCertificateListView()
            case 4:
                OnboardingDashboard()
            default:
                EmptyView()
            }
        }
        .navigationTitle("Контент")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Content Type Card
struct ContentTypeCard: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : color)

                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 120)
            .background(isSelected ? color : Color(.systemGray6))
            .cornerRadius(15)
        }
    }
}

// MARK: - Admin Course List View
struct AdminCourseListView: View {
    @StateObject private var viewModel = CourseViewModel()
    @State private var searchText = ""
    @State private var showingAddCourse = false
    @State private var selectedCourse: Course?

    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return viewModel.courses
        }
        return viewModel.courses.filter { course in
            course.title.localizedCaseInsensitiveContains(searchText) ||
            course.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and add button
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск курсов", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)

                Button(action: {
                    showingAddCourse = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()

            // Course list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredCourses) { course in
                        AdminCourseCard(course: course) {
                            selectedCourse = course
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddCourse) {
            NavigationView {
                CourseAddView { _ in }
            }
        }
        .sheet(item: $selectedCourse) { course in
            NavigationView {
                CourseEditView(course: course)
            }
        }
        .onAppear {
            viewModel.loadCourses()
        }
    }
}

// MARK: - Admin Test List View
struct AdminTestListView: View {
    @StateObject private var viewModel = TestViewModel()
    @State private var searchText = ""
    @State private var showingAddTest = false
    @State private var selectedTest: Test?

    var filteredTests: [Test] {
        let tests = viewModel.filteredTests
        return searchText.isEmpty ? tests : tests.filter { test in
            test.title.localizedCaseInsensitiveContains(searchText) ||
            test.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and add button
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск тестов", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)

                Button(action: {
                    showingAddTest = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding()

            // Test list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTests) { test in
                        AdminTestCard(test: test) {
                            selectedTest = test
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddTest) {
            NavigationView {
                TestAddView { _ in }
            }
        }
        .sheet(item: $selectedTest) { test in
            NavigationView {
                TestEditView(test: test)
            }
        }
        .onAppear {
            viewModel.loadTests()
        }
    }
}

// MARK: - Admin Competency List View
struct AdminCompetencyListView: View {
    @StateObject private var viewModel = CompetencyViewModel()
    @State private var showingAddCompetency = false
    @State private var selectedCompetency: Competency?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Competency matrix
                CompetencyMatrixSection()

                // Competency list
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Все компетенции")
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            showingAddCompetency = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                    }

                    ForEach(viewModel.competencies) { competency in
                        AdminCompetencyCard(competency: competency) {
                            selectedCompetency = competency
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddCompetency) {
            NavigationView {
                Text("Add Competency View")
                    .navigationTitle("Новая компетенция")
            }
        }
        .sheet(item: $selectedCompetency) { competency in
            NavigationView {
                Text("Edit Competency: \(competency.name)")
                    .navigationTitle("Редактирование")
            }
        }
    }
}

// MARK: - Admin Certificate List View
struct AdminCertificateListView: View {
    @State private var showingAddTemplate = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Certificate statistics
                CertificateStatsSection()

                // Certificate templates
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Шаблоны сертификатов")
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            showingAddTemplate = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }

                    // Template list
                    ForEach(0..<3) { _ in
                        CertificateTemplateCard()
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddTemplate) {
            NavigationView {
                Text("Add Certificate Template")
                    .navigationTitle("Новый шаблон")
            }
        }
    }
}

// MARK: - Helper Views
struct AdminCourseCard: View {
    let course: Course
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(course.title)
                    .font(.headline)

                HStack(spacing: 12) {
                    if let categoryId = course.categoryId,
                       let category = CourseCategory.categories.first(where: { $0.id == categoryId }) {
                        Label(category.name, systemImage: "folder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Label("\(course.modules.count) модулей", systemImage: "square.grid.2x2")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(course.totalLessons) уроков", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Status
                HStack {
                    Circle()
                        .fill(course.isPublished ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(course.isPublished ? "Опубликован" : "Черновик")
                        .font(.caption)
                        .foregroundColor(course.isPublished ? .green : .orange)
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AdminTestCard: View {
    let test: Test
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(test.title)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label("\(test.questionsCount) вопросов", systemImage: "questionmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(test.duration) мин", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let courseName = test.courseName {
                        Label(courseName, systemImage: "book")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Statistics
                if test.totalAttempts > 0 {
                    HStack(spacing: 8) {
                        Text("Попыток: \(test.totalAttempts)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text("Средний балл: \(test.averageScore)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AdminCompetencyCard: View {
    let competency: Competency
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(competency.name)
                    .font(.headline)

                Text(competency.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Usage statistics
                HStack(spacing: 12) {
                    Label("\(competency.usageCount) позиций", systemImage: "briefcase")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(competency.coursesCount) курсов", systemImage: "book")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CompetencyMatrixSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Матрица компетенций")
                .font(.headline)

            HStack(spacing: 12) {
                MatrixAdminContentStatCard(
                    title: "Позиций",
                    value: "45",
                    icon: "briefcase.fill",
                    color: .blue
                )

                MatrixAdminContentStatCard(
                    title: "Компетенций",
                    value: "89",
                    icon: "star.fill",
                    color: .purple
                )

                MatrixAdminContentStatCard(
                    title: "Связей",
                    value: "312",
                    icon: "link",
                    color: .green
                )
            }
        }
        .padding()
    }
}

struct CertificateStatsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика сертификатов")
                .font(.headline)

            HStack(spacing: 12) {
                AdminContentStatCard(
                    icon: "doc.badge.gearshape.fill",
                    title: "Выдано",
                    value: "892",
                    trend: "+23%",
                    color: .green
                )

                AdminContentStatCard(
                    icon: "checkmark.seal.fill",
                    title: "Активных",
                    value: "756",
                    trend: "+18%",
                    color: .blue
                )

                AdminContentStatCard(
                    icon: "xmark.seal.fill",
                    title: "Истекло",
                    value: "136",
                    trend: "-5%",
                    color: .orange
                )
            }
        }
        .padding()
    }
}

struct CertificateTemplateCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Сертификат об окончании курса")
                    .font(.headline)

                Text("Используется в 45 курсах")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MatrixAdminContentStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Stat Card
struct AdminContentStatCard: View {
    let icon: String
    let title: String
    let value: String
    let trend: String?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(trend.starts(with: "+") ? .green : .red)
                }
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        AdminContentView()
    }
}
