import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    let template: OnboardingTemplate

    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section("Основная информация") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Название", systemImage: "tag")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(template.title)
                            .font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Описание", systemImage: "text.alignleft")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(template.description)
                    }

                    HStack {
                        Label("Должность", systemImage: "person.fill")
                        Spacer()
                        Text(template.targetPosition)
                            .foregroundColor(.secondary)
                    }

                    if let department = template.targetDepartment {
                        HStack {
                            Label("Департамент", systemImage: "building.2")
                            Spacer()
                            Text(department)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Label("Длительность", systemImage: "calendar")
                        Spacer()
                        Text("\(template.duration) дней")
                            .foregroundColor(.secondary)
                    }
                }

                // Stages Section
                Section("Этапы программы (\(template.stages.count))") {
                    ForEach(template.stages) { stage in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label(stage.title, systemImage: "\(stage.order).circle.fill")
                                    .font(.headline)
                                Spacer()
                                Text("\(stage.duration) дней")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text(stage.description)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Image(systemName: "checklist")
                                    .foregroundColor(.blue)
                                Text("\(stage.tasks.count) задач")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Summary Section
                Section("Сводка") {
                    HStack {
                        Label("Общая длительность", systemImage: "calendar")
                        Spacer()
                        Text("\(totalDuration) дней")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Количество задач", systemImage: "checklist")
                        Spacer()
                        Text("\(totalTasks)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Активный", systemImage: "checkmark.circle.fill")
                        Spacer()
                        Text(template.isActive ? "Да" : "Нет")
                            .foregroundColor(template.isActive ? .green : .red)
                    }
                }

                // Info Section
                Section("Информация") {
                    HStack {
                        Label("Создан", systemImage: "clock")
                        Spacer()
                        Text(template.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Обновлен", systemImage: "arrow.clockwise")
                        Spacer()
                        Text(template.updatedAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                }

                // Actions Section (View-only for MVP)
                Section {
                    Text("Редактирование шаблонов будет доступно в следующей версии")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .navigationTitle("Просмотр шаблона")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Computed properties
    private var totalDuration: Int {
        template.stages.reduce(0) { $0 + $1.duration }
    }

    private var totalTasks: Int {
        template.stages.reduce(0) { $0 + $1.tasks.count }
    }
}

#Preview {
    EditTemplateView(template: OnboardingMockService.shared.templates[0])
}
