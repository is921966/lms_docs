//
//  CoursePreviewView.swift
//  LMS
//
//  Preview how course will look to students
//

import SwiftUI

struct CoursePreviewView: View {
    let course: ManagedCourse
    @Environment(\.dismiss) var dismiss
    @State private var selectedModule: ManagedCourseModule?
    @State private var showingStudentPreview = false
    @StateObject private var cmi5Service = Cmi5Service()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Course Info
                    courseInfoSection
                    
                    // Description
                    descriptionSection
                    
                    // What You'll Learn
                    learningObjectivesSection
                    
                    // Course Content
                    courseContentSection
                    
                    // Competencies
                    if !course.competencies.isEmpty {
                        competenciesSection
                    }
                    
                    // Enroll Button (for preview)
                    enrollButton
                }
                .padding()
            }
            .navigationTitle("Предпросмотр курса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedModule) { module in
                ModulePreviewView(module: module)
            }
            .sheet(isPresented: $showingStudentPreview) {
                StudentCoursePreviewView(course: course)
                    .environmentObject(cmi5Service)
                    .environmentObject(LRSService.shared)
                    .task {
                        // Загружаем Cmi5 пакеты при открытии превью
                        print("🔄 [CoursePreviewView] Loading Cmi5 packages for preview...")
                        await cmi5Service.loadPackages()
                        print("🔄 [CoursePreviewView] Cmi5 packages loaded, count: \(cmi5Service.packages.count)")
                    }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Course image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        Text(course.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                )
            
            // Full preview button
            Button {
                showingStudentPreview = true
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Просмотреть как студент")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            // Course Type Badge
            if course.cmi5PackageId != nil {
                HStack {
                    Label("Интерактивный курс", systemImage: "cube.box.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                }
            }
            
            Text(course.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
            
            // Author placeholder
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                Text("Корпоративный университет ЦУМ")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
    }
    
    private var courseInfoSection: some View {
        HStack(spacing: 20) {
            // Duration
            VStack(alignment: .leading) {
                Label("\(course.duration) часов", systemImage: "clock")
                    .font(.headline)
                Text("Длительность")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // Modules
            VStack(alignment: .leading) {
                Label("\(course.modules.count)", systemImage: "rectangle.stack")
                    .font(.headline)
                Text("Модулей")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // Level
            VStack(alignment: .leading) {
                Label("Все уровни", systemImage: "chart.bar")
                    .font(.headline)
                Text("Сложность")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("О курсе")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(course.description)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var learningObjectivesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Что вы изучите")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(generateLearningObjectives(), id: \.self) { objective in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.body)
                        Text(objective)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
    
    private var courseContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Содержание курса")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("\(course.modules.count) модулей • \(calculateTotalMinutes()) минут")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 0) {
                ForEach(Array(course.modules.enumerated()), id: \.element.id) { index, module in
                    ModuleRowPreview(
                        module: module,
                        index: index + 1,
                        isLast: index == course.modules.count - 1
                    ) {
                        selectedModule = module
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    private var competenciesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Развиваемые компетенции")
                .font(.title2)
                .fontWeight(.semibold)
            
            CompetencyFlowLayout(spacing: 8) {
                ForEach(course.competencies, id: \.self) { competencyId in
                    // В реальном приложении здесь будет загрузка названий компетенций
                    CourseCompetencyChip(competencyId: competencyId)
                }
            }
        }
    }
    
    private var enrollButton: some View {
        VStack(spacing: 16) {
            Button {
                // Preview mode - no action
            } label: {
                Text("Записаться на курс")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .disabled(true)
            .opacity(0.8)
            
            Text("Это предпросмотр курса. Запись недоступна.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Methods
    
    private func generateLearningObjectives() -> [String] {
        // В реальном приложении это может быть отдельное поле в модели
        return [
            "Основные концепции и принципы темы",
            "Практические навыки применения знаний",
            "Решение типовых задач и кейсов",
            "Работа с современными инструментами"
        ]
    }
    
    private func calculateTotalMinutes() -> Int {
        course.modules.reduce(0) { $0 + $1.duration }
    }
}

// MARK: - Module Row Preview

struct ModuleRowPreview: View {
    let module: ManagedCourseModule
    let index: Int
    let isLast: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Module number
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 40)
                    
                    Text("\(index)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                // Module info
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: iconForContentType(module.contentType))
                            .font(.caption)
                        Text(nameForContentType(module.contentType))
                            .font(.caption)
                        Text("•")
                            .font(.caption)
                        Text("\(module.duration) мин")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        
        if !isLast {
            Divider()
                .padding(.leading, 72)
        }
    }
    
    private func iconForContentType(_ type: ManagedCourseModule.ContentType) -> String {
        switch type {
        case .video: return "play.circle"
        case .document: return "doc.text"
        case .quiz: return "questionmark.circle"
        case .cmi5: return "cube.box"
        }
    }
    
    private func nameForContentType(_ type: ManagedCourseModule.ContentType) -> String {
        switch type {
        case .video: return "Видео"
        case .document: return "Документ"
        case .quiz: return "Тест"
        case .cmi5: return "Интерактив"
        }
    }
}

// MARK: - Module Preview

struct ModulePreviewView: View {
    let module: ManagedCourseModule
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Module type icon
                Image(systemName: iconForModule())
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding()
                
                Text(module.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(module.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Module info
                HStack(spacing: 40) {
                    VStack {
                        Text("\(module.duration)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("минут")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Image(systemName: iconForModule())
                            .font(.title3)
                        Text(typeForModule())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                Text("В режиме предпросмотра контент модуля недоступен")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    dismiss()
                } label: {
                    Text("Закрыть")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Модуль \(module.order)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func iconForModule() -> String {
        switch module.contentType {
        case .video: return "play.rectangle.fill"
        case .document: return "doc.text.fill"
        case .quiz: return "checkmark.square.fill"
        case .cmi5: return "cube.box.fill"
        }
    }
    
    private func typeForModule() -> String {
        switch module.contentType {
        case .video: return "Видео"
        case .document: return "Документ"
        case .quiz: return "Тест"
        case .cmi5: return "Интерактив"
        }
    }
}

// MARK: - Course Competency Chip

struct CourseCompetencyChip: View {
    let competencyId: UUID
    
    var body: some View {
        Text("Компетенция")
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.purple.opacity(0.1))
            .foregroundColor(.purple)
            .cornerRadius(16)
    }
}

// MARK: - Competency Flow Layout

struct CompetencyFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                    y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    CoursePreviewView(
        course: ManagedCourse(
            title: "Основы Swift и iOS разработки",
            description: "Комплексный курс по изучению языка программирования Swift и основ разработки приложений для iOS. Вы научитесь создавать современные мобильные приложения с использованием SwiftUI и лучших практик разработки.",
            duration: 40,
            status: .published,
            modules: [
                ManagedCourseModule(
                    id: UUID(),
                    title: "Введение в Swift",
                    description: "Основные концепции языка программирования Swift",
                    order: 1,
                    contentType: .video,
                    duration: 45
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "Переменные и типы данных",
                    description: "Работа с переменными, константами и базовыми типами",
                    order: 2,
                    contentType: .document,
                    duration: 30
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "Проверка знаний",
                    description: "Тест по основам Swift",
                    order: 3,
                    contentType: .quiz,
                    duration: 15
                )
            ]
        )
    )
} 