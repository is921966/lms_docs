//
//  StudentCoursePreviewView.swift
//  LMS
//
//  Full student experience preview for admins
//

import SwiftUI

struct StudentCoursePreviewView: View {
    let course: ManagedCourse
    @Environment(\.dismiss) var dismiss
    @State private var currentModuleIndex = 0
    @State private var completedModules: Set<UUID> = []
    @State private var showingModuleContent = false
    @State private var isNavigating = false
    
    init(course: ManagedCourse) {
        self.course = course
        print("🎯 [StudentCoursePreviewView] Initializing with course:")
        print("   - Title: \(course.title)")
        print("   - ID: \(course.id)")
        print("   - cmi5PackageId: \(String(describing: course.cmi5PackageId))")
        print("   - Modules count: \(course.modules.count)")
        for (index, module) in course.modules.enumerated() {
            print("   - Module \(index): \(module.title)")
            print("     - contentType: \(module.contentType)")
            print("     - contentUrl: \(String(describing: module.contentUrl))")
        }
    }
    
    private var currentModule: ManagedCourseModule? {
        guard currentModuleIndex < course.modules.count else { return nil }
        return course.modules[currentModuleIndex]
    }
    
    private var progress: Double {
        guard !course.modules.isEmpty else { return 0 }
        return Double(completedModules.count) / Double(course.modules.count)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                progressBar
                
                // Module Content
                if let module = currentModule {
                    moduleContentView(module)
                } else {
                    completedView
                }
                
                // Navigation Controls
                navigationControls
            }
            .navigationTitle(course.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Выйти") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(Array(course.modules.enumerated()), id: \.element.id) { index, module in
                            Button {
                                currentModuleIndex = index
                            } label: {
                                Label(
                                    "\(index + 1). \(module.title)",
                                    systemImage: completedModules.contains(module.id) ? "checkmark.circle.fill" : "circle"
                                )
                            }
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showingModuleContent) {
            if let module = currentModule {
                ModuleContentPreviewView(
                    module: module,
                    cmi5PackageId: course.cmi5PackageId,
                    onComplete: {
                        completedModules.insert(module.id)
                        showingModuleContent = false
                        if currentModuleIndex < course.modules.count - 1 {
                            withAnimation {
                                currentModuleIndex += 1
                            }
                        }
                    }
                )
                .environmentObject(Cmi5Service())
                .environmentObject(LRSService.shared)
            }
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Прогресс курса")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Module Content View
    
    private func moduleContentView(_ module: ManagedCourseModule) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Module Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Модуль \(currentModuleIndex + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if completedModules.contains(module.id) {
                                Label("Пройден", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text(module.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(module.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Module Type Card
                    moduleTypeCard(module)
                        .padding(.horizontal)
                    
                    // Learning Objectives
                    if !module.description.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("В этом модуле вы узнаете:")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(generateModuleObjectives(module), id: \.self) { objective in
                                    HStack(alignment: .top) {
                                        Text("•")
                                        Text(objective)
                                    }
                                    .font(.body)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Start Module Button
            Button {
                showingModuleContent = true
            } label: {
                HStack {
                    Image(systemName: iconForContentType(module.contentType))
                    Text(completedModules.contains(module.id) ? "Пройти заново" : "Начать модуль")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(completedModules.contains(module.id) ? Color.green : Color.blue)
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private func moduleTypeCard(_ module: ManagedCourseModule) -> some View {
        HStack(spacing: 16) {
            Image(systemName: iconForContentType(module.contentType))
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nameForContentType(module.contentType))
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Label("\(module.duration) мин", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let contentId = module.contentUrl, !contentId.isEmpty {
                        Label("ID: \(contentId)", systemImage: "number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Completed View
    
    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Поздравляем!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Вы прошли все модули курса")
                .font(.title3)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Пройдено модулей:")
                    Spacer()
                    Text("\(course.modules.count)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Общее время:")
                    Spacer()
                    Text("\(course.modules.reduce(0) { $0 + $1.duration }) минут")
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button {
                currentModuleIndex = 0
                completedModules.removeAll()
            } label: {
                Label("Начать заново", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Navigation Controls
    
    private var navigationControls: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation {
                    if currentModuleIndex > 0 {
                        currentModuleIndex -= 1
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Назад")
                }
                .font(.subheadline)
                .foregroundColor(currentModuleIndex > 0 ? .blue : .gray)
            }
            .disabled(currentModuleIndex == 0)
            
            Spacer()
            
            Text("\(currentModuleIndex + 1) из \(course.modules.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                if let module = currentModule, !completedModules.contains(module.id) {
                    // Нужно сначала пройти модуль
                    showingModuleContent = true
                } else if currentModuleIndex < course.modules.count - 1 {
                    withAnimation {
                        currentModuleIndex += 1
                    }
                }
            } label: {
                HStack {
                    Text("Далее")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .foregroundColor(currentModuleIndex < course.modules.count - 1 ? .blue : .gray)
            }
            .disabled(currentModuleIndex >= course.modules.count - 1)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Helper Methods
    
    private func iconForContentType(_ type: ManagedCourseModule.ContentType) -> String {
        switch type {
        case .video: return "play.circle.fill"
        case .document: return "doc.text.fill"
        case .quiz: return "questionmark.circle.fill"
        case .cmi5: return "cube.box.fill"
        }
    }
    
    private func nameForContentType(_ type: ManagedCourseModule.ContentType) -> String {
        switch type {
        case .video: return "Видео урок"
        case .document: return "Текстовый материал"
        case .quiz: return "Тестирование"
        case .cmi5: return "Интерактивный курс"
        }
    }
    
    private func generateModuleObjectives(_ module: ManagedCourseModule) -> [String] {
        // В реальном приложении это может быть отдельное поле
        switch module.contentType {
        case .video:
            return [
                "Просмотр обучающего видеоматериала",
                "Изучение ключевых концепций темы",
                "Визуальные примеры и демонстрации"
            ]
        case .document:
            return [
                "Чтение теоретического материала",
                "Изучение примеров и кейсов",
                "Дополнительные ссылки и ресурсы"
            ]
        case .quiz:
            return [
                "Проверка полученных знаний",
                "Закрепление изученного материала",
                "Получение обратной связи"
            ]
        case .cmi5:
            return [
                "Интерактивное взаимодействие",
                "Практические упражнения",
                "Симуляции реальных ситуаций"
            ]
        }
    }
}

// MARK: - Module Content Preview

struct ModuleContentPreviewView: View {
    let module: ManagedCourseModule
    let cmi5PackageId: UUID?
    let onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var progress: Double = 0
    @State private var isCompleted = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                LinearProgressView(progress: progress)
                    .frame(height: 4)
                
                // Content based on type
                Group {
                    switch module.contentType {
                    case .video:
                        VideoModulePreview(module: module, progress: $progress)
                    case .document:
                        DocumentModulePreview(module: module, progress: $progress)
                    case .quiz:
                        QuizModulePreview(module: module, progress: $progress)
                    case .cmi5:
                        Cmi5ModulePreview(
                            module: module, 
                            cmi5PackageId: cmi5PackageId,
                            progress: $progress
                        )
                    }
                }
                
                // Complete button
                if progress >= 1.0 && !isCompleted {
                    Button {
                        isCompleted = true
                        onComplete()
                    } label: {
                        Text("Завершить модуль")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle(module.title)
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
}

// MARK: - Progress View

struct LinearProgressView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
    }
} 