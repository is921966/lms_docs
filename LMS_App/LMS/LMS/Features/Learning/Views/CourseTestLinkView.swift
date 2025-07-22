//
//  CourseTestLinkView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CourseTestLinkView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTestId: UUID?
    @State private var searchText = ""
    @State private var showingCreateTest = false
    @State private var selectedTest: Test?
    @State private var showingTest = false

    // Mock tests from TestMockService
    var tests: [Test] {
        TestMockService.shared.tests
    }

    var filteredTests: [Test] {
        if searchText.isEmpty {
            return tests
        }
        return tests.filter { test in
            test.title.localizedCaseInsensitiveContains(searchText) ||
            test.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                courseHeader
                testsList
                    .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(course.title)
                        .font(.headline)
                    Text("Выберите тест для прохождения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
    
    private var testsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(tests) { test in
                    TestRowView(test: test) {
                        selectedTest = test
                        showingTest = true
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    private func saveTest() {
        // course.testId = selectedTestId

        // In real app, would save to backend
        // await courseService.updateTest(courseId: course.id, testId: selectedTestId)

        dismiss()
    }
}

// MARK: - Test Selection Row
struct TestSelectionRow: View {
    let test: Test
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(test.title)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(test.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Label("\(test.questions.count) вопросов", systemImage: "questionmark.circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if let timeLimit = test.timeLimit {
                            Text("•")
                                .foregroundColor(.secondary)

                            Label("\(timeLimit) мин", systemImage: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        Text("•")
                            .foregroundColor(.secondary)

                        Text(test.type.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(test.type.color.opacity(0.2))
                            .foregroundColor(test.type.color)
                            .cornerRadius(4)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TestRowView: View {
    let test: Test
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(test.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label("\(test.questions.count) вопросов", systemImage: "questionmark.circle")
                        if let timeLimit = test.timeLimit {
                            Label("\(timeLimit) мин", systemImage: "clock")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        CourseTestLinkView(
            course: Course.mockCourses.first!
        )
    }
}
