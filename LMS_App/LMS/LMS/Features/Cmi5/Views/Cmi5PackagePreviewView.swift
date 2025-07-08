//
//  Cmi5PackagePreviewView.swift
//  LMS
//
//  Created on Sprint 40 Day 2 - Package Preview UI
//

import SwiftUI

/// View для предпросмотра структуры Cmi5 пакета
struct Cmi5PackagePreviewView: View {
    let package: Cmi5Package
    @State private var expandedNodes: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Package info header
                    packageInfoSection
                    
                    Divider()
                    
                    // Course structure
                    if let rootBlock = package.manifest.rootBlock {
                        courseStructureSection(rootBlock)
                    } else {
                        emptyStateView
                    }
                    
                    Divider()
                    
                    // Vendor info
                    if let vendor = package.manifest.vendor {
                        vendorSection(vendor)
                    }
                    
                    // Actions
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Предпросмотр пакета")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Package Info Section
    
    private var packageInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация о пакете")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Название", systemImage: "book.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text(package.title)
                        .fontWeight(.medium)
                }
                
                if let description = package.description {
                    HStack(alignment: .top) {
                        Label("Описание", systemImage: "text.alignleft")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(description)
                            .font(.callout)
                    }
                }
                
                HStack {
                    Label("Версия", systemImage: "number.circle")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text(package.version)
                }
                
                HStack {
                    Label("Размер", systemImage: "doc.zipper")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text(formatFileSize(package.size))
                }
                
                HStack {
                    Label("Активностей", systemImage: "list.bullet")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text("\(countActivities())")
                }
                
                HStack {
                    Label("Статус", systemImage: "checkmark.circle")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    
                    if package.isValid {
                        Label("Валидный", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else {
                        VStack(alignment: .leading) {
                            Label("Невалидный", systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            
                            if !package.validationErrors.isEmpty {
                                ForEach(package.validationErrors, id: \.self) { error in
                                    Text("• \(error)")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .font(.callout)
        }
    }
    
    // MARK: - Course Structure Section
    
    private func courseStructureSection(_ rootBlock: Cmi5Block) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Структура курса")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let courseTitle = package.manifest.course?.title?.first?.value {
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .foregroundColor(.blue)
                    Text(courseTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 8)
            }
            
            // Render root block
            renderBlock(rootBlock, level: 0)
        }
    }
    
    // MARK: - Block Rendering
    
    @ViewBuilder
    private func renderBlock(_ block: Cmi5Block, level: Int) -> AnyView {
        AnyView(VStack(alignment: .leading, spacing: 8) {
            // Block header
            HStack(spacing: 8) {
                // Indentation
                ForEach(0..<level, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 20)
                        .padding(.leading, 12)
                }
                
                // Expand/Collapse button
                if !block.blocks.isEmpty || !block.activities.isEmpty {
                    Button(action: {
                        toggleExpanded(block.id)
                    }) {
                        Image(systemName: isExpanded(block.id) ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Spacer()
                        .frame(width: 20)
                }
                
                // Block icon
                Image(systemName: "folder.fill")
                    .foregroundColor(.orange)
                
                // Block title
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.title.first?.value ?? "Блок")
                        .fontWeight(.medium)
                    
                    if let description = block.description?.first?.value {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Child count
                let childCount = block.blocks.count + block.activities.count
                if childCount > 0 {
                    Text("\(childCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .contentShape(Rectangle())
            
            // Block children (if expanded)
            if isExpanded(block.id) {
                // Render sub-blocks
                ForEach(block.blocks) { subBlock in
                    renderBlock(subBlock, level: level + 1)
                }
                
                // Render activities
                ForEach(block.activities) { activity in
                    renderActivity(activity, level: level + 1)
                }
            }
        })
    }
    
    private func renderActivity(_ activity: Cmi5Activity, level: Int) -> some View {
        HStack(spacing: 8) {
            // Indentation
            ForEach(0..<level, id: \.self) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: 20)
                    .padding(.leading, 12)
            }
            
            // Activity icon based on type
            activityIcon(for: activity.activityType)
            
            // Activity info
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.callout)
                
                if let description = activity.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    // Launch method
                    HStack(spacing: 4) {
                        Image(systemName: activity.launchMethod == .ownWindow ? "macwindow" : "rectangle.on.rectangle")
                            .font(.caption2)
                        Text(activity.launchMethod.localizedName)
                            .font(.caption2)
                    }
                    
                    // Move on criteria
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle")
                            .font(.caption2)
                        Text(activity.moveOn.localizedName)
                            .font(.caption2)
                    }
                    
                    // Mastery score
                    if let score = activity.masteryScore {
                        HStack(spacing: 4) {
                            Image(systemName: "percent")
                                .font(.caption2)
                            Text("\(Int(score * 100))%")
                                .font(.caption2)
                        }
                    }
                    
                    // Duration
                    if let duration = activity.duration {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.caption2)
                            Text(formatDuration(duration))
                                .font(.caption2)
                        }
                    }
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Структура курса не найдена")
                .font(.headline)
            
            Text("Не удалось загрузить структуру блоков и активностей")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Vendor Section
    
    private func vendorSection(_ vendor: Cmi5Vendor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация о поставщике")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Название", systemImage: "building.2")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text(vendor.name)
                }
                
                if let contact = vendor.contact {
                    HStack {
                        Label("Контакт", systemImage: "person.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(contact)
                    }
                }
                
                if let url = vendor.url {
                    HStack {
                        Label("Сайт", systemImage: "globe")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Link(url, destination: URL(string: url)!)
                            .font(.callout)
                    }
                }
            }
            .font(.callout)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                // TODO: Implement mapping to lessons
            }) {
                Label("Создать уроки", systemImage: "plus.rectangle.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!package.isValid)
            
            Button(action: {
                // TODO: Implement re-validation
            }) {
                Label("Перепроверить", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.top)
    }
    
    // MARK: - Helper Methods
    
    private func isExpanded(_ nodeId: String) -> Bool {
        expandedNodes.contains(nodeId)
    }
    
    private func toggleExpanded(_ nodeId: String) {
        if expandedNodes.contains(nodeId) {
            expandedNodes.remove(nodeId)
        } else {
            expandedNodes.insert(nodeId)
        }
    }
    
    private func countActivities() -> Int {
        guard let rootBlock = package.manifest.rootBlock else { return 0 }
        
        var count = 0
        
        func countInBlock(_ block: Cmi5Block) {
            count += block.activities.count
            for subBlock in block.blocks {
                countInBlock(subBlock)
            }
        }
        
        countInBlock(rootBlock)
        return count
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func activityIcon(for type: String) -> some View {
        let iconName: String
        let color: Color
        
        switch type {
        case let t where t.contains("assessment"):
            iconName = "checkmark.square"
            color = .red
        case let t where t.contains("lesson"):
            iconName = "book"
            color = .blue
        case let t where t.contains("simulation"):
            iconName = "gamecontroller"
            color = .purple
        case let t where t.contains("module"):
            iconName = "square.grid.2x2"
            color = .green
        default:
            iconName = "doc"
            color = .gray
        }
        
        return Image(systemName: iconName)
            .foregroundColor(color)
    }
    
    private func formatDuration(_ isoDuration: String) -> String {
        // Simple ISO 8601 duration parser
        if isoDuration.hasPrefix("PT") {
            let duration = isoDuration.dropFirst(2)
            if duration.hasSuffix("M") {
                return String(duration.dropLast()) + " мин"
            } else if duration.hasSuffix("H") {
                return String(duration.dropLast()) + " ч"
            }
        }
        return isoDuration
    }
}

// MARK: - Preview

struct Cmi5PackagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        Cmi5PackagePreviewView(package: mockPackage)
    }
    
    static var mockPackage: Cmi5Package {
        // Create mock package for preview
        let mockBlock = Cmi5Block(
            id: "block1",
            title: [Cmi5LangString(lang: "ru", value: "Модуль 1")],
            activities: [
                Cmi5Activity(
                    packageId: UUID(),
                    activityId: "activity1",
                    title: "Урок 1",
                    launchUrl: "lesson1.html",
                    launchMethod: .ownWindow,
                    moveOn: .completed,
                    activityType: "lesson"
                )
            ]
        )
        
        let manifest = Cmi5Manifest(
            identifier: "test-package",
            title: "Тестовый пакет",
            course: Cmi5Course(
                id: "course1",
                title: [Cmi5LangString(lang: "ru", value: "Тестовый курс")],
                auCount: 5,
                rootBlock: mockBlock
            )
        )
        
        return Cmi5Package(
            packageId: "test-package",
            title: "Тестовый пакет",
            manifest: manifest,
            filePath: "/test/path",
            size: 1024 * 1024 * 10,
            uploadedBy: UUID()
        )
    }
} 