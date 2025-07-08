//
//  Cmi5ActivitySelector.swift
//  LMS
//
//  Created on Sprint 40 Day 3 - Course Builder Integration
//

import SwiftUI

/// View для выбора Cmi5 активности при создании урока
struct Cmi5ActivitySelector: View {
    @StateObject private var viewModel = Cmi5ActivitySelectorViewModel()
    @Binding var selectedActivity: Cmi5Activity?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.packages.isEmpty {
                    LoadingView(message: "Загрузка пакетов...")
                } else if viewModel.packages.isEmpty {
                    emptyState
                } else {
                    packageList
                }
            }
            .navigationTitle("Выбор Cmi5 активности")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Выбрать") {
                        if let activity = viewModel.selectedActivity {
                            selectedActivity = activity
                            dismiss()
                        }
                    }
                    .disabled(viewModel.selectedActivity == nil)
                }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Неизвестная ошибка")
            }
        }
    }
    
    // MARK: - Views
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.zipper")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет загруженных Cmi5 пакетов")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Сначала импортируйте Cmi5 пакеты в систему")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // TODO: Navigate to import
            }) {
                Label("Импортировать пакет", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var packageList: some View {
        List {
            ForEach(viewModel.packages) { package in
                PackageSection(
                    package: package,
                    isExpanded: viewModel.expandedPackages.contains(package.id),
                    selectedActivity: viewModel.selectedActivity,
                    onToggleExpand: {
                        viewModel.togglePackageExpansion(package.id)
                    },
                    onSelectActivity: { activity in
                        viewModel.selectActivity(activity)
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Package Section

private struct PackageSection: View {
    let package: Cmi5Package
    let isExpanded: Bool
    let selectedActivity: Cmi5Activity?
    let onToggleExpand: () -> Void
    let onSelectActivity: (Cmi5Activity) -> Void
    
    var body: some View {
        Section {
            // Package header
            Button(action: onToggleExpand) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.packageName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let version = package.packageVersion {
                            Text("Версия: \(version)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("\(package.activities.count)", systemImage: "doc.text")
                            
                            Spacer()
                            
                            Text(package.formattedFileSize)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Activities
            if isExpanded {
                ForEach(package.activities) { activity in
                    ActivityRow(
                        activity: activity,
                        isSelected: selectedActivity?.id == activity.id,
                        onSelect: {
                            onSelectActivity(activity)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Activity Row

private struct ActivityRow: View {
    let activity: Cmi5Activity
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    if let description = activity.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 12) {
                        // Activity type
                        Label(activityTypeText, systemImage: activityTypeIcon)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        // Move on criteria
                        Text(activity.moveOn.localizedName)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                        
                        // Duration
                        if let duration = activity.duration {
                            Text(formatDuration(duration))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var activityTypeText: String {
        if activity.activityType.contains("assessment") {
            return "Тест"
        } else if activity.activityType.contains("media") {
            return "Медиа"
        } else if activity.activityType.contains("module") {
            return "Модуль"
        } else {
            return "Активность"
        }
    }
    
    private var activityTypeIcon: String {
        if activity.activityType.contains("assessment") {
            return "checkmark.circle"
        } else if activity.activityType.contains("media") {
            return "play.circle"
        } else if activity.activityType.contains("module") {
            return "book.circle"
        } else {
            return "circle"
        }
    }
    
    private func formatDuration(_ iso8601: String) -> String {
        // Простой парсер ISO 8601 duration
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

// MARK: - View Model

@MainActor
final class Cmi5ActivitySelectorViewModel: ObservableObject {
    @Published var packages: [Cmi5Package] = []
    @Published var selectedActivity: Cmi5Activity?
    @Published var expandedPackages: Set<UUID> = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service = Cmi5Service()
    
    init() {
        Task {
            await loadPackages()
        }
    }
    
    func loadPackages() async {
        isLoading = true
        error = nil
        
        do {
            await service.loadPackages()
            packages = service.packages.filter { $0.status == .valid }
            
            // Автоматически раскрываем первый пакет
            if let firstPackage = packages.first {
                expandedPackages.insert(firstPackage.id)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func togglePackageExpansion(_ packageId: UUID) {
        if expandedPackages.contains(packageId) {
            expandedPackages.remove(packageId)
        } else {
            expandedPackages.insert(packageId)
        }
    }
    
    func selectActivity(_ activity: Cmi5Activity) {
        if selectedActivity?.id == activity.id {
            selectedActivity = nil
        } else {
            selectedActivity = activity
        }
    }
}

// MARK: - Preview

struct Cmi5ActivitySelector_Previews: PreviewProvider {
    static var previews: some View {
        Cmi5ActivitySelector(selectedActivity: .constant(nil))
    }
} 