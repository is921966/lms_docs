//
//  CourseCompetencyLinkView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CourseCompetencyLinkView: View {
    @Binding var course: Course
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCompetencies: Set<UUID> = []
    @State private var searchText = ""

    // Mock competencies
    let competencies = [
        Competency(
            name: "Продажи",
            description: "Навыки эффективных продаж и работы с клиентами",
            category: .sales
        ),
        Competency(
            name: "Коммуникация",
            description: "Навыки эффективного общения",
            category: .softSkills
        ),
        Competency(
            name: "Товароведение",
            description: "Знание ассортимента и характеристик товаров",
            category: .technical
        ),
        Competency(
            name: "Работа с кассой",
            description: "Навыки работы с кассовым оборудованием",
            category: .technical
        ),
        Competency(
            name: "Визуальный мерчандайзинг",
            description: "Оформление торгового пространства",
            category: .innovation
        )
    ]

    var filteredCompetencies: [Competency] {
        if searchText.isEmpty {
            return competencies
        }
        return competencies.filter { competency in
            competency.name.localizedCaseInsensitiveContains(searchText) ||
            competency.description.localizedCaseInsensitiveContains(searchText) ||
            competency.category.rawValue.localizedCaseInsensitiveContains(searchText)
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
                            Text("Связать с компетенциями")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Поиск компетенций", text: $searchText)
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

                // Selected count
                if !selectedCompetencies.isEmpty {
                    HStack {
                        Text("Выбрано: \(selectedCompetencies.count)")
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        Spacer()

                        Button("Снять выделение") {
                            selectedCompetencies.removeAll()
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)
                }

                // Competency list
                List(filteredCompetencies) { competency in
                    CourseCompetencySelectionRow(
                        competency: competency,
                        isSelected: selectedCompetencies.contains(competency.id) || course.competencyIds.contains(competency.id),
                        onToggle: {
                            if selectedCompetencies.contains(competency.id) {
                                selectedCompetencies.remove(competency.id)
                            } else {
                                selectedCompetencies.insert(competency.id)
                            }
                        }
                    )
                }
                .listStyle(PlainListStyle())

                // Save button
                Button(action: saveCompetencies) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Сохранить связи")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Компетенции курса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Initialize with existing competencies
            selectedCompetencies = Set(course.competencyIds)
        }
    }

    private func saveCompetencies() {
        // Update course with selected competencies
        course.competencyIds = Array(selectedCompetencies)

        // In real app, would save to backend
        // await courseService.updateCompetencies(courseId: course.id, competencyIds: selectedCompetencies)

        dismiss()
    }
}

// MARK: - Competency Selection Row
struct CourseCompetencySelectionRow: View {
    let competency: Competency
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(competency.name)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    Text(competency.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Label(competency.category.rawValue, systemImage: competency.category.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
    CourseCompetencyLinkView(
        course: .constant(Course.createMockCourses().first!)
    )
}
