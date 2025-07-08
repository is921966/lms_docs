//
//  Cmi5ManagementView.swift
//  LMS
//
//  Created on Sprint 40 Day 5 - Feature Registry Integration
//

import SwiftUI

/// Основной экран для управления Cmi5 пакетами
struct Cmi5ManagementView: View {
    @StateObject private var service = Cmi5Service()
    @State private var showingImport = false
    @State private var selectedPackage: Cmi5Package?
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Cmi5 Контент")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    toolbarContent
                }
                .searchable(text: $searchText, prompt: "Поиск пакетов")
                .refreshable {
                    await loadPackages()
                }
                .sheet(isPresented: $showingImport) {
                    Cmi5ImportView(courseId: nil) { package in
                        // Обновляем список после импорта
                        Task {
                            await loadPackages()
                        }
                    }
                }
                .sheet(item: $selectedPackage) { package in
                    Cmi5PackagePreviewView(package: package)
                }
                .task {
                    await loadPackages()
                }
        }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        if isLoading && service.packages.isEmpty {
            ProgressView("Загрузка пакетов...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if service.packages.isEmpty {
            emptyState
        } else {
            packageList
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.box")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("Нет Cmi5 пакетов")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Импортируйте первый Cmi5 пакет для начала работы")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingImport = true }) {
                Label("Импортировать пакет", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding(.top, 100)
    }
    
    private var packageList: some View {
        List {
            ForEach(filteredPackages) { package in
                PackageRow(package: package)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPackage = package
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await deletePackage(package)
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        if package.courseId == nil {
                            Button {
                                // TODO: Показать выбор курса для привязки
                            } label: {
                                Label("Привязать к курсу", systemImage: "link")
                            }
                            .tint(.blue)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingImport = true }) {
                Image(systemName: "plus")
            }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button(action: { /* TODO: Сортировка по дате */ }) {
                    Label("По дате", systemImage: "calendar")
                }
                Button(action: { /* TODO: Сортировка по названию */ }) {
                    Label("По названию", systemImage: "textformat")
                }
                Button(action: { /* TODO: Сортировка по размеру */ }) {
                    Label("По размеру", systemImage: "doc")
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }
    
    // MARK: - Filtered Data
    
    private var filteredPackages: [Cmi5Package] {
        if searchText.isEmpty {
            return service.packages
        } else {
            return service.packages.filter { package in
                package.title.localizedCaseInsensitiveContains(searchText) ||
                package.packageId.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadPackages() async {
        isLoading = true
        await service.loadPackages()
        isLoading = false
    }
    
    private func deletePackage(_ package: Cmi5Package) async {
        do {
            try await service.deletePackage(id: package.id)
            await loadPackages()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

// MARK: - Package Row

private struct PackageRow: View {
    let package: Cmi5Package
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title и version
            HStack {
                Text(package.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text("v\(package.version)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Description
            if let description = package.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Metadata
            HStack(spacing: 16) {
                // Размер
                Label(formatFileSize(package.size), systemImage: "doc")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // Количество активностей
                Label("\(countActivities(in: package))", systemImage: "list.bullet")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // Статус
                if package.isValid {
                    Label("Валидный", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Label("Ошибки", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Курс
                if let courseId = package.courseId {
                    Label("Привязан", systemImage: "link")
                        .font(.caption2)
                        .foregroundColor(.blue)
                } else {
                    Label("Не привязан", systemImage: "link.badge.plus")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            // Дата загрузки
            Text("Загружен: \(package.uploadedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func countActivities(in package: Cmi5Package) -> Int {
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
}

// MARK: - Preview

struct Cmi5ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        Cmi5ManagementView()
    }
} 