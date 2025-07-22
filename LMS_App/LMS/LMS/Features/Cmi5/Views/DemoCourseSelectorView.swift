//
//  DemoCourseSelectorView.swift
//  LMS
//
//  Created on 12/07/2025.
//

import SwiftUI

struct DemoCourseSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCourse: DemoCourse?
    @State private var searchText = ""
    
    var filteredCourses: [DemoCourse] {
        if searchText.isEmpty {
            return DemoCourse.allCourses
        } else {
            return DemoCourse.allCourses.filter { course in
                course.name.localizedCaseInsensitiveContains(searchText) ||
                course.description.localizedCaseInsensitiveContains(searchText) ||
                course.type.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Поиск курсов...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Courses list
                    ForEach(filteredCourses) { course in
                        DemoCourseCard(course: course) {
                            selectedCourse = course
                            dismiss()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Демо курсы Cmi5")
            .navigationBarItems(
                trailing: Button("Отмена") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Demo Course Card
struct DemoCourseCard: View {
    let course: DemoCourse
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: course.type.icon)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(course.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Label(course.type.rawValue, systemImage: "tag")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Label(course.language, systemImage: "globe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                
                // Description
                Text(course.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Features based on type
                if course.type == .multiAU {
                    HStack(spacing: 16) {
                        Label("Модульная структура", systemImage: "square.stack")
                        Label("Интерактивный", systemImage: "hand.tap")
                    }
                    .font(.caption2)
                    .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct DemoCourseSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DemoCourseSelectorView(selectedCourse: .constant(nil))
    }
} 