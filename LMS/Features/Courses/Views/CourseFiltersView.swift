//
//  CourseFiltersView.swift
//  LMS
//
//  Created on 19/01/2025.
//

import SwiftUI

struct CourseFiltersView: View {
    @ObservedObject var viewModel: CourseViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Сортировка
                Section("Сортировка") {
                    Picker("Сортировать по", selection: $viewModel.sortOption) {
                        ForEach(CourseViewModel.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                // Уровень сложности
                Section("Уровень сложности") {
                    ForEach(CourseLevel.allCases, id: \.self) { level in
                        HStack {
                            Image(systemName: level.icon)
                                .foregroundColor(level.color)
                            Text(level.rawValue)
                            Spacer()
                            if viewModel.selectedLevel == level {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.selectedLevel == level {
                                viewModel.selectedLevel = nil
                            } else {
                                viewModel.selectedLevel = level
                            }
                        }
                    }
                }
                
                // Формат обучения
                Section("Формат обучения") {
                    ForEach(CourseFormat.allCases, id: \.self) { format in
                        HStack {
                            Image(systemName: format.icon)
                                .foregroundColor(.blue)
                            Text(format.rawValue)
                            Spacer()
                            if viewModel.selectedFormat == format {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.selectedFormat == format {
                                viewModel.selectedFormat = nil
                            } else {
                                viewModel.selectedFormat = format
                            }
                        }
                    }
                }
                
                // Дополнительные фильтры
                Section("Дополнительно") {
                    Toggle("Показать только мои курсы", isOn: $viewModel.showOnlyEnrolled)
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        resetFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetFilters() {
        viewModel.selectedLevel = nil
        viewModel.selectedFormat = nil
        viewModel.selectedCategory = "Все"
        viewModel.showOnlyEnrolled = false
        viewModel.sortOption = .popular
        viewModel.searchText = ""
    }
} 