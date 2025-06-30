//
//  CourseTestLinkView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CourseTestLinkView: View {
    @Binding var course: Course
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTestId: UUID?
    @State private var searchText = ""
    @State private var showingCreateTest = false

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
                // Course info header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: course.icon)
                            .font(.title2)
                            .foregroundColor(course.color)

                        VStack(alignment: .leading) {
                            Text(course.title)
                                .font(.headline)
                            Text("Связать с тестом")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()

                    if let testId = course.testId,
                       let currentTest = tests.first(where: { $0.id == testId }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Текущий тест:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)

                                VStack(alignment: .leading) {
                                    Text(currentTest.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    Text("\(currentTest.questions.count) вопросов • \(currentTest.timeLimit ?? 0) мин")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button("Удалить") {
                                    selectedTestId = nil
                                    saveTest()
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                .background(Color(.systemGroupedBackground))

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Поиск тестов", text: $searchText)
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

                // Create new test button
                Button(action: { showingCreateTest = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Создать новый тест")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Test list
                List(filteredTests) { test in
                    TestSelectionRow(
                        test: test,
                        isSelected: selectedTestId == test.id || course.testId == test.id,
                        onSelect: {
                            selectedTestId = test.id
                            saveTest()
                        }
                    )
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Выбор теста")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCreateTest) {
                // In real app, would show TestAddView
                Text("Создание теста будет доступно в следующей версии")
                    .padding()
            }
        }
        .onAppear {
            selectedTestId = course.testId
        }
    }

    private func saveTest() {
        course.testId = selectedTestId

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

#Preview {
    CourseTestLinkView(
        course: .constant(Course.createMockCourses().first!)
    )
}
