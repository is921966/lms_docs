import SwiftUI

struct CourseManagementView: View {
    @StateObject private var viewModel = CourseManagementViewModel()
    @State private var showingCreateCourse = false
    @State private var searchText = ""
    @State private var selectedCourses = Set<UUID>()
    @State private var isEditMode = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск курсов...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("courseSearchField")
                }
                .padding(.horizontal)
                
                // Course list
                List(viewModel.filteredCourses(searchText: searchText), selection: $selectedCourses) { course in
                    CourseRowView(course: course)
                        .accessibilityIdentifier("courseRow_\(course.id)")
                }
                .accessibilityIdentifier("courseList")
                .listStyle(PlainListStyle())
                .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))
                
                // Bulk operations toolbar
                if isEditMode && !selectedCourses.isEmpty {
                    HStack {
                        Button("Удалить") {
                            viewModel.deleteCourses(ids: Array(selectedCourses))
                            selectedCourses.removeAll()
                        }
                        .foregroundColor(.red)
                        .accessibilityIdentifier("bulkDeleteButton")
                        
                        Spacer()
                        
                        Button("Архивировать") {
                            viewModel.archiveCourses(ids: Array(selectedCourses))
                            selectedCourses.removeAll()
                        }
                        .accessibilityIdentifier("bulkArchiveButton")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                }
            }
            .navigationTitle("Управление курсами")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditMode ? "Готово" : "Выбрать") {
                        isEditMode.toggle()
                        if !isEditMode {
                            selectedCourses.removeAll()
                        }
                    }
                    .accessibilityIdentifier("editModeButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateCourse = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("createCourseButton")
                }
            }
            .sheet(isPresented: $showingCreateCourse) {
                CreateCourseView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadCourses()
        }
    }
}

struct CourseRowView: View {
    let course: ManagedCourse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(course.title)
                    .font(.headline)
                    .accessibilityIdentifier("courseTitle")
                
                Spacer()
                
                CourseStatusBadge(status: course.status)
                    .accessibilityIdentifier("courseStatus")
            }
            
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .accessibilityIdentifier("courseDescription")
            
            HStack {
                Label("\(course.duration) часов", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !course.competencies.isEmpty {
                    Label("\(course.competencies.count) компетенций", systemImage: "checkmark.seal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CourseStatusBadge: View {
    let status: ManagedCourseStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .cornerRadius(4)
    }
}

#Preview {
    CourseManagementView()
} 