import SwiftUI

struct CourseManagementView: View {
    @StateObject private var viewModel = CourseManagementViewModel()
    @State private var searchText = ""
    @State private var showingCreateCourse = false
    @State private var showingFilter = false
    
    // Filter ViewModel
    @StateObject private var filterViewModel: CourseFilterViewModel
    
    init() {
        _filterViewModel = StateObject(wrappedValue: CourseFilterViewModel(courses: []))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Active filters bar
                ActiveFiltersBar(filterViewModel: filterViewModel)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск курсов...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("courseSearchField")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Course list
                List(filteredCoursesWithSearch) { course in
                    if viewModel.isSelectionMode {
                        HStack {
                            Image(systemName: viewModel.selectedCourseIds.contains(course.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedCourseIds.contains(course.id) ? .blue : .gray)
                                .onTapGesture {
                                    viewModel.toggleCourseSelection(course.id)
                                }
                            
                            CourseRowView(course: course)
                        }
                        .accessibilityIdentifier("selectableCourseRow_\(course.id)")
                    } else {
                        NavigationLink(destination: ManagedCourseDetailView(courseId: course.id)) {
                            CourseRowView(course: course)
                                .accessibilityIdentifier("courseRow_\(course.id)")
                        }
                    }
                }
                .accessibilityIdentifier("courseList")
                .listStyle(PlainListStyle())
                
                // Bulk operations toolbar
                if viewModel.isSelectionMode && viewModel.isBulkOperationAvailable {
                    BulkOperationsToolbar(viewModel: viewModel)
                }
            }
            .navigationTitle("Управление курсами")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.isSelectionMode {
                        Button("Отмена") {
                            viewModel.toggleSelectionMode()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if viewModel.isSelectionMode {
                            Button("Выбрать все") {
                                viewModel.selectAllCourses()
                            }
                            .disabled(viewModel.courses.isEmpty)
                        } else {
                            Button {
                                showingFilter = true
                            } label: {
                                Image(systemName: filterViewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                    .foregroundColor(filterViewModel.hasActiveFilters ? .blue : .primary)
                            }
                            .accessibilityIdentifier("filterButton")
                            
                            Button {
                                viewModel.toggleSelectionMode()
                            } label: {
                                Label("Выбрать", systemImage: "checkmark.circle")
                            }
                            
                            Button {
                                showingCreateCourse = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            .accessibilityIdentifier("addCourseButton")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateCourse) {
                CreateCourseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilter) {
                CourseFilterView(filterViewModel: filterViewModel)
            }
        }
        .onAppear {
            print("📚 CourseManagementView: onAppear called, loading courses...")
            viewModel.loadCourses()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Cmi5CourseImported"))) { notification in
            // Обновляем список курсов после импорта Cmi5
            print("📚 CourseManagementView: Received Cmi5CourseImported notification")
            if let userInfo = notification.userInfo,
               let courseId = userInfo["courseId"] as? UUID,
               let courseTitle = userInfo["courseTitle"] as? String {
                print("📚 CourseManagementView: Imported course: \(courseTitle) (ID: \(courseId))")
            }
            print("📚 CourseManagementView: Reloading courses...")
            viewModel.loadCourses()
        }
        .refreshable {
            // Поддержка pull-to-refresh
            print("📚 CourseManagementView: Pull-to-refresh triggered")
            viewModel.loadCourses()
        }
        .onChange(of: viewModel.courses) { newCourses in
            // Update filter view model when courses change
            updateFilterViewModel(with: newCourses)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredCoursesWithSearch: [ManagedCourse] {
        let filtered = filterViewModel.filteredCourses
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { course in
                course.title.localizedCaseInsensitiveContains(searchText) ||
                course.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Methods
    
    private func updateFilterViewModel(with courses: [ManagedCourse]) {
        filterViewModel.updateCourses(courses)
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
                
                // Индикатор Cmi5 курса
                if course.cmi5PackageId != nil {
                    Label("Cmi5", systemImage: "cube.box.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                        .accessibilityIdentifier("cmi5Indicator")
                }
                
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
                
                if course.cmi5PackageId != nil {
                    Label("\(course.modules.count) модулей", systemImage: "rectangle.stack")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
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