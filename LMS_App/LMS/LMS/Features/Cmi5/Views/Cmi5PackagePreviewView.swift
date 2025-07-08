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
    let extendedCourse: Cmi5FullParser.Cmi5ExtendedCourse?
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
                    if let extended = extendedCourse {
                        courseStructureSection(extended)
                    } else {
                        simpleActivityList
                    }
                    
                    Divider()
                    
                    // Metadata section
                    if let metadata = extendedCourse?.metadata {
                        metadataSection(metadata)
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
                    Text(package.packageName)
                        .fontWeight(.medium)
                }
                
                if let version = package.packageVersion {
                    HStack {
                        Label("Версия", systemImage: "number.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(version)
                    }
                }
                
                HStack {
                    Label("Размер", systemImage: "doc.zipper")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text(package.formattedFileSize)
                }
                
                HStack {
                    Label("Активностей", systemImage: "list.bullet")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text("\(package.activities.count)")
                }
                
                HStack {
                    Label("Статус", systemImage: "checkmark.circle")
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Cmi5StatusBadge(status: package.status)
                }
            }
            .font(.callout)
        }
    }
    
    // MARK: - Course Structure Section
    
    private func courseStructureSection(_ extended: Cmi5FullParser.Cmi5ExtendedCourse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Структура курса")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                // Course title
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .foregroundColor(.blue)
                    Text(extended.course.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                if let description = extended.course.description {
                    Text(description)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                }
            }
            .padding(.bottom, 8)
            
            // Render course nodes
            ForEach(Array(extended.structure.enumerated()), id: \.offset) { index, node in
                renderNode(node, level: 0)
            }
        }
    }
    
    // MARK: - Node Rendering
    
    @ViewBuilder
    private func renderNode(_ node: Cmi5FullParser.Cmi5CourseNode, level: Int) -> some View {
        switch node {
        case .block(let block):
            renderBlock(block, level: level)
        case .activity(let activity):
            renderActivity(activity, level: level)
        }
    }
    
    private func renderBlock(_ block: Cmi5FullParser.Cmi5Block, level: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
                Button(action: {
                    toggleExpanded(block.id)
                }) {
                    Image(systemName: isExpanded(block.id) ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Block icon
                Image(systemName: "folder.fill")
                    .foregroundColor(.orange)
                
                // Block title
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.title)
                        .fontWeight(.medium)
                    
                    if let description = block.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Objectives
                    if !block.objectives.isEmpty {
                        HStack {
                            Image(systemName: "target")
                                .font(.caption2)
                            Text("\(block.objectives.count) цели")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Child count
                Text("\(block.children.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            .contentShape(Rectangle())
            
            // Block children (if expanded)
            if isExpanded(block.id) {
                ForEach(Array(block.children.enumerated()), id: \.offset) { index, child in
                    renderNode(child, level: level + 1)
                }
                
                // Show objectives if any
                if !block.objectives.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(block.objectives, id: \.self) { objective in
                            HStack(spacing: 4) {
                                // Indentation
                                ForEach(0..<(level + 1), id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 2, height: 16)
                                        .padding(.leading, 12)
                                }
                                
                                Image(systemName: "target")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                
                                Text(objective)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
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
                
                HStack(spacing: 12) {
                    // Launch method
                    HStack(spacing: 4) {
                        Image(systemName: activity.launchMethod == .ownWindow ? "macwindow" : "rectangle.on.rectangle")
                            .font(.caption2)
                        Text(activity.launchMethod == .ownWindow ? "Новое окно" : "Любое окно")
                            .font(.caption2)
                    }
                    
                    // Move on criteria
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle")
                            .font(.caption2)
                        Text(moveOnText(for: activity.moveOn))
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
    
    // MARK: - Simple Activity List
    
    private var simpleActivityList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Активности")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(package.activities) { activity in
                renderActivity(activity, level: 0)
            }
        }
    }
    
    // MARK: - Metadata Section
    
    private func metadataSection(_ metadata: Cmi5FullParser.Cmi5Metadata) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Метаданные")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                if let publisher = metadata.publisher {
                    HStack {
                        Label("Издатель", systemImage: "building.2")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(publisher)
                    }
                }
                
                if let rights = metadata.rights {
                    HStack {
                        Label("Права", systemImage: "lock.shield")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(rights)
                            .font(.caption)
                    }
                }
                
                if let language = metadata.language {
                    HStack {
                        Label("Язык", systemImage: "globe")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(language)
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
            
            Button(action: {
                // TODO: Implement validation
            }) {
                Label("Валидировать", systemImage: "checkmark.shield")
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
    
    private func moveOnText(for criteria: Cmi5Activity.MoveOnCriteria) -> String {
        switch criteria {
        case .passed:
            return "Пройдено"
        case .completed:
            return "Завершено"
        case .completedAndPassed:
            return "Завершено и пройдено"
        case .completedOrPassed:
            return "Завершено или пройдено"
        case .notApplicable:
            return "Не применимо"
        }
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

// MARK: - Status Badge

private struct Cmi5StatusBadge: View {
    let status: Cmi5Package.PackageStatus
    
    var body: some View {
        Text(status.localizedName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .processing:
            return .orange.opacity(0.2)
        case .valid:
            return .green.opacity(0.2)
        case .invalid:
            return .red.opacity(0.2)
        case .archived:
            return .gray.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .processing:
            return .orange
        case .valid:
            return .green
        case .invalid:
            return .red
        case .archived:
            return .gray
        }
    }
} 