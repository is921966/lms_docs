import SwiftUI

struct CourseListView: View {
    @StateObject var viewModel: CourseListViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var searchText = ""
    @State private var selectedCategory: Course.CourseCategory?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading && viewModel.courses.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredCourses) { course in
                            CourseCard(course: course) {
                                coordinator.showCourseDetail(course)
                            }
                        }
                    }
                    .padding()
                }
            }
            .searchable(text: $searchText, prompt: "Поиск курсов")
            .navigationTitle("Курсы")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Категория", selection: $selectedCategory) {
                            Text("Все категории").tag(nil as Course.CourseCategory?)
                            ForEach(Course.CourseCategory.allCases, id: \.self) { category in
                                Text(category.displayName).tag(category as Course.CourseCategory?)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.loadCourses()
            }
            .task {
                await viewModel.loadCourses()
            }
            .alert("Ошибка", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Произошла ошибка")
            }
        }
    }
    
    private var filteredCourses: [Course] {
        var courses = viewModel.courses
        
        if let category = selectedCategory {
            courses = courses.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            courses = courses.filter { course in
                course.title.localizedCaseInsensitiveContains(searchText) ||
                course.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return courses
    }
}

struct CourseCard: View {
    let course: Course
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    // Category and Level
                    HStack {
                        Label(course.category.displayName, systemImage: "tag")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label(course.level.displayName, systemImage: "chart.bar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Title
                    Text(course.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Description
                    Text(course.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Progress or Enroll button
                    if course.isEnrolled {
                        ProgressView(value: course.progress)
                            .tint(.blue)
                        
                        Text("\(Int(course.progress * 100))% завершено")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("\(course.duration) мин")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("Записаться")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    CourseListView(viewModel: CourseListViewModel(
        fetchCoursesUseCase: MockFetchCoursesUseCase(),
        enrollCourseUseCase: MockEnrollCourseUseCase()
    ))
    .environmentObject(AppCoordinator())
} 