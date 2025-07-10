//
//  Cmi5PackagePreviewView.swift
//  LMS
//
//  Created on Sprint 40 Day 2 - Package Preview UI
//

import SwiftUI

struct Cmi5PackagePreviewView: View {
    let package: Cmi5Package
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(package.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let description = package.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Package info
                VStack(spacing: 16) {
                    PackageInfoRow(label: "ID пакета", value: package.packageId)
                    PackageInfoRow(label: "Версия", value: package.version)
                    PackageInfoRow(label: "Размер", value: formatFileSize(package.size))
                    PackageInfoRow(label: "Загружен", value: formatDate(package.uploadedAt))
                    PackageInfoRow(label: "Активностей", value: "\(package.activities.count)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Activities
                if !package.activities.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Активности")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(package.activities) { activity in
                            ActivityCard(activity: activity)
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Validation status
                if !package.isValid {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Ошибки валидации", systemImage: "exclamationmark.triangle")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        ForEach(package.validationErrors, id: \.self) { error in
                            Text("• \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Детали пакета")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct PackageInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

struct ActivityCard: View {
    let activity: Cmi5Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForActivityType(activity.activityType))
                    .foregroundColor(.blue)
                
                Text(activity.title)
                    .font(.headline)
                
                Spacer()
                
                if let duration = activity.duration {
                    Text(formatDuration(duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let description = activity.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 16) {
                Label(activity.launchMethod.localizedName, systemImage: "arrow.up.right.square")
                    .font(.caption2)
                
                Label(activity.moveOn.localizedName, systemImage: "checkmark.circle")
                    .font(.caption2)
                
                if let score = activity.masteryScore {
                    Label("\(Int(score * 100))%", systemImage: "target")
                        .font(.caption2)
                }
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func iconForActivityType(_ type: String) -> String {
        if type.contains("assessment") || type.contains("quiz") {
            return "checkmark.square"
        } else if type.contains("video") || type.contains("media") {
            return "play.rectangle"
        } else if type.contains("document") {
            return "doc.text"
        } else {
            return "book"
        }
    }
    
    private func formatDuration(_ iso8601: String) -> String {
        // Simple parsing for common durations
        if iso8601.contains("PT") {
            let cleaned = iso8601.replacingOccurrences(of: "PT", with: "")
            if cleaned.contains("H") {
                let hours = cleaned.replacingOccurrences(of: "H", with: "")
                return "\(hours) ч"
            } else if cleaned.contains("M") {
                let minutes = cleaned.replacingOccurrences(of: "M", with: "")
                return "\(minutes) мин"
            }
        }
        return iso8601
    }
}

#Preview {
    NavigationView {
        Cmi5PackagePreviewView(package: Cmi5Package(
            packageId: "test-package",
            title: "Тестовый пакет",
            description: "Описание тестового пакета",
            manifest: Cmi5Manifest(
                identifier: "test",
                title: "Test",
                course: Cmi5Course(
                    id: "course1",
                    auCount: 3,
                    rootBlock: Cmi5Block(
                        id: "block1",
                        title: [Cmi5LangString(lang: "ru", value: "Блок 1")],
                        activities: []
                    )
                )
            ),
            filePath: "/test",
            size: 1024 * 1024 * 5,
            uploadedBy: UUID()
        ))
    }
} 