import SwiftUI

struct CourseListView: View {
    @StateObject private var viewModel = CourseViewModel()
    @State private var showingFilters = false
    @State private var viewStyle: ViewStyle = .grid
    @State private var selectedCourse: Course?
    
    enum ViewStyle {
        case grid
        case list
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBar
            
            // Filter Pills
            if showingFilters {
                filterSection
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Content
            if viewModel.isLoading && viewModel.courses.isEmpty {
                LoadingView(message: "Loading courses...")
            } else if viewModel.filteredCourses.isEmpty {
                emptyView
            } else {
                ScrollView {
                    // Featured Section
                    if !viewModel.searchText.isEmpty || viewModel.selectedCategory != nil {
                        // Don't show featured when filtering
                    } else if !viewModel.featuredCourses.isEmpty {
                        featuredSection
                    }
                    
                    // Courses Grid/List
                    coursesSection
                }
            }
        }
        .navigationTitle("Courses")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .task {
            await viewModel.loadCourses()
        }
        .refreshable {
            await viewModel.loadCourses()
        }
        .sheet(item: $selectedCourse) { course in
            Text("Course Detail: \(course.title)")
        }
        .animation(.easeInOut(duration: 0.2), value: showingFilters)
    }
    
    // MARK: - Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search courses...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All Categories",
                        isSelected: viewModel.selectedCategory == nil,
                        action: { viewModel.selectedCategory = nil }
                    )
                    
                    ForEach(Course.Category.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: viewModel.selectedCategory == category,
                            color: category.color,
                            action: { viewModel.selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Additional Filters
            HStack(spacing: 8) {
                // Difficulty
                Menu {
                    Button("All Levels") {
                        viewModel.selectedDifficulty = nil
                    }
                    ForEach(Course.Difficulty.allCases, id: \.self) { difficulty in
                        Button(difficulty.rawValue) {
                            viewModel.selectedDifficulty = difficulty
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text(viewModel.selectedDifficulty?.rawValue ?? "All Levels")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedDifficulty != nil ? Color.accentColor : Color(uiColor: .systemGray5))
                    .foregroundColor(viewModel.selectedDifficulty != nil ? .white : .primary)
                    .cornerRadius(16)
                }
                
                // Sort
                Menu {
                    ForEach(CourseViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            viewModel.sortOption = option
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(viewModel.sortOption.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .systemGray5))
                    .cornerRadius(16)
                }
                
                // Enrolled Only
                Toggle(isOn: $viewModel.showEnrolledOnly) {
                    Text("My Courses")
                        .font(.caption)
                }
                .toggleStyle(FilterToggleStyle())
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Courses")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredCourses) { course in
                        CourseCard(course: course) {
                            selectedCourse = course
                        }
                        .frame(width: 280)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var coursesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Courses")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(viewModel.filteredCourses.count) courses")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if viewStyle == .grid {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.filteredCourses) { course in
                        CourseCard(course: course) {
                            selectedCourse = course
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredCourses) { course in
                        CourseListCard(course: course) {
                            selectedCourse = course
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No courses found")
                .font(.headline)
            
            Text("Try adjusting your search or filters")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Clear Filters") {
                viewModel.searchText = ""
                viewModel.selectedCategory = nil
                viewModel.selectedDifficulty = nil
                viewModel.showEnrolledOnly = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button(action: { showingFilters.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(showingFilters ? .fill : .none)
                }
                
                Button(action: { 
                    viewStyle = viewStyle == .grid ? .list : .grid
                }) {
                    Image(systemName: viewStyle == .grid ? "square.grid.2x2" : "list.bullet")
                }
            }
        }
    }
}

// MARK: - Filter Chip with Icon
extension FilterChip {
    init(title: String, icon: String? = nil, isSelected: Bool, color: Color? = nil, action: @escaping () -> Void) {
        self.init(title: title, isSelected: isSelected, action: action)
        // In real implementation, modify FilterChip to support icons
    }
}

// MARK: - Filter Toggle Style
struct FilterToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(configuration.isOn ? Color.accentColor : Color(uiColor: .systemGray5))
        .foregroundColor(configuration.isOn ? .white : .primary)
        .cornerRadius(16)
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

// MARK: - Preview
struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CourseListView()
        }
    }
} 