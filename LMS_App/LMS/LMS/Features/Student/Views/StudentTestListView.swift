//
//  StudentTestListView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct StudentTestListView: View {
    @StateObject private var viewModel = TestViewModel()
    @State private var selectedTab = 0
    @State private var searchText = ""

    var filteredTests: [Test] {
        let tests: [Test]
        switch selectedTab {
        case 0: tests = viewModel.assignedTests
        case 1: tests = viewModel.completedTests
        case 2: tests = viewModel.practiceTests
        default: tests = []
        }

        if searchText.isEmpty {
            return tests
        }

        return tests.filter { test in
            test.title.localizedCaseInsensitiveContains(searchText) ||
            test.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            Picker("Тесты", selection: $selectedTab) {
                Text("Назначенные").tag(0)
                Text("Пройденные").tag(1)
                Text("Тренировочные").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Поиск тестов", text: $searchText)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)

            // Test list
            if filteredTests.isEmpty {
                EmptyTestStateView(selectedTab: selectedTab)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredTests) { test in
                            StudentTestCard(
                                test: test,
                                testType: StudentTestType(rawValue: selectedTab) ?? .assigned
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Тесты")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadTests()
        }
    }
}

// MARK: - Test Type
enum StudentTestType: Int {
    case assigned = 0
    case completed = 1
    case practice = 2
}

// MARK: - Student Test Card
struct StudentTestCard: View {
    let test: Test
    let testType: StudentTestType
    @State private var showingTestPlayer = false

    var cardColor: Color {
        switch testType {
        case .assigned: return test.deadline?.isWithinNext24Hours ?? false ? .red : .blue
        case .completed: return test.isPassed ? .green : .orange
        case .practice: return .purple
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                // Test icon
                Image(systemName: iconForTestType)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(cardColor)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(test.title)
                        .font(.headline)
                        .lineLimit(2)

                    if let courseName = test.courseName {
                        Text(courseName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Result or status
                if testType == .completed {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(test.score ?? 0)%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(test.isPassed ? .green : .orange)

                        Text(test.isPassed ? "Пройден" : "Не пройден")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Description

            Text(test.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Test info
            HStack(spacing: 16) {
                TestInfoChip(
                    icon: "questionmark.circle",
                    text: "\(test.questionsCount) вопросов"
                )

                TestInfoChip(
                    icon: "clock",
                    text: "\(test.duration) мин"
                )

                if test.attempts > 0 {
                    TestInfoChip(
                        icon: "arrow.counterclockwise",
                        text: "\(test.attempts) попыток"
                    )
                }

                if let deadline = test.deadline, testType == .assigned {
                    TestInfoChip(
                        icon: "calendar",
                        text: deadline.daysUntilString,
                        isUrgent: deadline.isWithinNext24Hours
                    )
                }
            }

            // Action button
            actionButton
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingTestPlayer) {
            TestPlayerView(test: test, viewModel: TestViewModel())
        }
    }

    private var iconForTestType: String {
        switch testType {
        case .assigned: return "doc.text.magnifyingglass"
        case .completed: return "checkmark.seal.fill"
        case .practice: return "pencil.and.ellipsis.rectangle"
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch testType {
        case .assigned:
            Button(action: {
                showingTestPlayer = true
            }) {
                HStack {
                    Text("Начать тест")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Image(systemName: "play.circle.fill")
                }
                .foregroundColor(.white)
                .padding()
                .background(cardColor)
                .cornerRadius(10)
            }

        case .completed:
            HStack(spacing: 12) {
                NavigationLink(destination: TestResultView(test: test)) {
                    HStack {
                        Text("Результаты")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }

                if test.allowsRetake && !test.isPassed {
                    Button(action: {
                        showingTestPlayer = true
                    }) {
                        HStack {
                            Text("Пересдать")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "arrow.counterclockwise")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

        case .practice:
            Button(action: {
                showingTestPlayer = true
            }) {
                HStack {
                    Text("Начать тренировку")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Image(systemName: "play.circle.fill")
                }
                .foregroundColor(.purple)
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Test Info Chip
struct TestInfoChip: View {
    let icon: String
    let text: String
    var isUrgent: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(isUrgent ? .red : .secondary)
    }
}

// MARK: - Empty State View
struct EmptyTestStateView: View {
    let selectedTab: Int
    
    struct EmptyStateInfo {
        let icon: String
        let title: String
        let subtitle: String
    }

    var emptyStateInfo: EmptyStateInfo {
        switch selectedTab {
        case 0: return EmptyStateInfo(
            icon: "doc.text.magnifyingglass",
            title: "Нет назначенных тестов",
            subtitle: "Когда преподаватель назначит вам тест, он появится здесь"
        )
        case 1: return EmptyStateInfo(
            icon: "checkmark.seal",
            title: "Нет пройденных тестов",
            subtitle: "Здесь будут отображаться результаты пройденных тестов"
        )
        case 2: return EmptyStateInfo(
            icon: "pencil.and.ellipsis.rectangle",
            title: "Нет тренировочных тестов",
            subtitle: "Тренировочные тесты помогут вам подготовиться к экзаменам"
        )
        default: return EmptyStateInfo(icon: "", title: "", subtitle: "")
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: emptyStateInfo.icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(emptyStateInfo.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(emptyStateInfo.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

// MARK: - Date Extension
extension Date {
    var isWithinNext24Hours: Bool {
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        return self >= now && self <= tomorrow
    }

    var daysUntilString: String {
        let now = Date()
        let days = Calendar.current.dateComponents([.day], from: now, to: self).day ?? 0

        if days < 0 {
            return "Просрочено"
        } else if days == 0 {
            return "Сегодня"
        } else if days == 1 {
            return "Завтра"
        } else {
            return "Через \(days) дн."
        }
    }
}

#Preview {
    NavigationView {
        StudentTestListView()
    }
}
