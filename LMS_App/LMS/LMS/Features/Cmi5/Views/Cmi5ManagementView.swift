//
//  Cmi5ManagementView.swift
//  LMS
//
//  Created on Sprint 40 Day 5 - Feature Registry Integration
//

import SwiftUI

struct Cmi5ManagementView: View {
    @StateObject private var viewModel = Cmi5ManagementViewModel()
    @State private var searchText = ""
    @State private var showingImport = false
    @State private var selectedPackage: Cmi5Package?
    @State private var showingAnalytics = false
    
    var filteredPackages: [Cmi5Package] {
        if searchText.isEmpty {
            return viewModel.packages
        }
        return viewModel.packages.filter { package in
            package.title.localizedCaseInsensitiveContains(searchText) ||
            package.description?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Statistics
            HStack(spacing: 20) {
                Cmi5StatCard(title: "Всего пакетов:", value: "\(viewModel.packages.count)", color: .blue)
                    .accessibilityIdentifier("totalPackagesStat")
                Cmi5StatCard(title: "Активных:", value: "\(viewModel.activePackagesCount)", color: .green)
                    .accessibilityIdentifier("activePackagesStat")
            }
            .padding()
            
            // Search and import button
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск пакетов", text: $searchText)
                        .accessibilityIdentifier("packageSearchField")
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button(action: { showingImport = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Импортировать пакет")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .accessibilityIdentifier("importPackageButton")
            }
            .padding()
            
            // Package list
            if filteredPackages.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cube.box")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Нет Cmi5 пакетов")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Импортируйте первый пакет для начала работы")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("emptyState")
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPackages) { package in
                            Cmi5PackageCard(package: package) {
                                selectedPackage = package
                            }
                            .accessibilityIdentifier("packageCard_\(package.id)")
                        }
                    }
                    .padding()
                }
                .accessibilityIdentifier("packageListScrollView")
            }
        }
        .navigationTitle("Управление Cmi5")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAnalytics = true }) {
                    Label("Аналитика Cmi5", systemImage: "chart.bar")
                }
                .accessibilityIdentifier("analyticsButton")
            }
        }
        .sheet(isPresented: $showingImport) {
            NavigationView {
                Cmi5ImportView(courseId: nil) { package in
                    Task {
                        await viewModel.loadPackages()
                    }
                }
            }
        }
        .sheet(item: $selectedPackage) { package in
            NavigationView {
                Cmi5PackagePreviewView(package: package)
            }
        }
        .sheet(isPresented: $showingAnalytics) {
            NavigationView {
                AnalyticsDashboardView()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadPackages()
            }
        }
    }
}

// MARK: - Cmi5 Stat Card
struct Cmi5StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Cmi5 Package Card
struct Cmi5PackageCard: View {
    let package: Cmi5Package
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Package icon
                Image(systemName: "cube.box.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50)
                
                // Package info
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .accessibilityIdentifier("packageTitle")
                    
                    if let description = package.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 12) {
                        Label("\(package.activities.count) активностей", systemImage: "play.circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Label("v\(package.version)", systemImage: "info.circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status indicator
                VStack {
                    Image(systemName: package.isActive ? "checkmark.circle.fill" : "clock.fill")
                        .foregroundColor(package.isActive ? .green : .orange)
                    
                    Text(package.isActive ? "Активен" : "Неактивен")
                        .font(.caption2)
                        .foregroundColor(package.isActive ? .green : .orange)
                }
                .accessibilityIdentifier("packageStatus")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extension for Cmi5Package
extension Cmi5Package {
    var isActive: Bool {
        // Mock implementation
        return activities.count > 0
    }
}

#Preview {
    NavigationView {
        Cmi5ManagementView()
    }
} 