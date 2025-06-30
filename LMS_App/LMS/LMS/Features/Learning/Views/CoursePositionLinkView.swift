//
//  CoursePositionLinkView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CoursePositionLinkView: View {
    @Binding var course: Course
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPositions: Set<UUID> = []
    @State private var searchText = ""

    // Mock positions
    let positions = [
        Position(
            name: "Продавец-консультант",
            description: "Консультирует клиентов, оформляет продажи",
            department: "Продажи",
            level: .junior
        ),
        Position(
            name: "Старший продавец",
            description: "Ведущий специалист по продажам",
            department: "Продажи",
            level: .middle
        ),
        Position(
            name: "Менеджер по продажам",
            description: "Управляет командой продавцов",
            department: "Продажи",
            level: .senior
        ),
        Position(
            name: "Товаровед",
            description: "Управляет ассортиментом товаров",
            department: "Товароведение",
            level: .middle
        ),
        Position(
            name: "Визуальный мерчандайзер",
            description: "Оформление торгового пространства",
            department: "Маркетинг",
            level: .middle
        )
    ]

    var filteredPositions: [Position] {
        if searchText.isEmpty {
            return positions
        }
        return positions.filter { position in
            position.name.localizedCaseInsensitiveContains(searchText) ||
            position.department.localizedCaseInsensitiveContains(searchText) ||
            position.description.localizedCaseInsensitiveContains(searchText)
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
                            Text("Связать с должностями")
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

                    TextField("Поиск должностей", text: $searchText)
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
                if !selectedPositions.isEmpty {
                    HStack {
                        Text("Выбрано: \(selectedPositions.count)")
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        Spacer()

                        Button("Снять выделение") {
                            selectedPositions.removeAll()
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)
                }

                // Position list
                List(filteredPositions) { position in
                    CoursePositionSelectionRow(
                        position: position,
                        isSelected: selectedPositions.contains(position.id) || course.positionIds.contains(position.id),
                        onToggle: {
                            if selectedPositions.contains(position.id) {
                                selectedPositions.remove(position.id)
                            } else {
                                selectedPositions.insert(position.id)
                            }
                        }
                    )
                }
                .listStyle(PlainListStyle())

                // Save button
                Button(action: savePositions) {
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
            .navigationTitle("Должности для курса")
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
            // Initialize with existing positions
            selectedPositions = Set(course.positionIds)
        }
    }

    private func savePositions() {
        // Update course with selected positions
        course.positionIds = Array(selectedPositions)

        // In real app, would save to backend
        // await courseService.updatePositions(courseId: course.id, positionIds: selectedPositions)

        dismiss()
    }
}

// MARK: - Position Selection Row
struct CoursePositionSelectionRow: View {
    let position: Position
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(position.name)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(position.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Text(position.department)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        PositionLevelBadge(level: position.level)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Position Level Badge
struct PositionLevelBadge: View {
    let level: PositionLevel

    var body: some View {
        Text(level.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(level.color.opacity(0.2))
            .foregroundColor(level.color)
            .cornerRadius(4)
    }
}

#Preview {
    CoursePositionLinkView(
        course: .constant(Course.createMockCourses().first!)
    )
}
