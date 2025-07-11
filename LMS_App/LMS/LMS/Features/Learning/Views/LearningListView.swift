import SwiftUI

struct LearningListView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "Все"
    @State private var courses: [Course] = []

    init() {
        // Initialize mock courses on first load
        if Course.mockCourses.isEmpty {
            Course.mockCourses = Course.createMockCourses()
        }
        _courses = State(initialValue: Course.mockCourses)
    }
    @State private var showingEditView = false
    @State private var courseToEdit: Course?
    @State private var showingAddCourse = false

    let categories = ["Все", "В процессе", "Назначенные", "Завершенные"]

    var isAdmin: Bool {
        if let user = MockAuthService.shared.currentUser {
            return user.role == .admin || user.role == .manager
        }
        return false
    }

    var filteredCourses: [Course] {
        var filtered = courses

        // Filter by category
        if selectedCategory != "Все" {
            switch selectedCategory {
            case "В процессе":
                filtered = filtered.filter { $0.progress > 0 && $0.progress < 1 }
            case "Назначенные":
                filtered = filtered.filter { $0.progress == 0 }
            case "Завершенные":
                filtered = filtered.filter { $0.progress == 1 }
            default:
                break
            }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Поиск курсов", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories, id: \.self) { category in
                        CategoryChip(
                            title: category,
                            isSelected: selectedCategory == category
                        )                            { selectedCategory = category }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)

            // Course list
            if filteredCourses.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)

                    Text("Курсы не найдены")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                                        ForEach(filteredCourses) { course in
                    NavigationLink(destination: CourseDetailView(course: course)) {
                        CourseCard(course: course, isAdmin: isAdmin) { editCourse in
                            courseToEdit = editCourse
                            showingEditView = true
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Обучение")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if isAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            if let course = courseToEdit {
                NavigationView {
                    CourseEditView(course: course)
                }
            }
        }
        .sheet(isPresented: $showingAddCourse) {
            CourseAddView { newCourse in
                courses.append(newCourse)
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Course Card
struct CourseCard: View {
    let course: Course
    let isAdmin: Bool
    let onEdit: ((Course) -> Void)?

    init(course: Course, isAdmin: Bool = false, onEdit: ((Course) -> Void)? = nil) {
        self.course = course
        self.isAdmin = isAdmin
        self.onEdit = onEdit
    }

    var body: some View {
        HStack(spacing: 15) {
            // Course icon
            Image(systemName: course.icon)
                .font(.system(size: 40))
                .foregroundColor(course.color)
                .frame(width: 60, height: 60)
                .background(course.color.opacity(0.1))
                .cornerRadius(15)

            // Course info
            VStack(alignment: .leading, spacing: 8) {
                Text(course.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(course.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(course.color)
                            .frame(width: geometry.size.width * course.progress, height: 4)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text("\(Int(course.progress * 100))% завершено")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(course.duration)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(alignment: .topTrailing) {
            if isAdmin, let onEdit = onEdit {
                Button(action: { onEdit(course) }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding(8)
            }
        }
    }
}

// MARK: - Course Model
// Course model moved to separate file - Models/Course.swift

// MARK: - Module Model moved to Course.swift

#Preview {
    NavigationView {
        LearningListView()
    }
}
