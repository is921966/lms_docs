//
//  LessonPlayerView.swift
//  LMS
//
//  Created on 19/01/2025.
//

import SwiftUI

struct LessonPlayerView: View {
    let course: Course
    @State private var currentLessonIndex = 0
    @State private var showMaterials = false
    @EnvironmentObject var viewModel: CourseViewModel
    
    private var currentLesson: Lesson? {
        guard currentLessonIndex < course.lessons.count else { return nil }
        return course.lessons[currentLessonIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Lesson content
            if let lesson = currentLesson {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Lesson header
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label(lesson.type.rawValue, systemImage: lesson.type.icon)
                                    .foregroundColor(lesson.type.color)
                                
                                Spacer()
                                
                                Button(action: { showMaterials.toggle() }) {
                                    Label("Материалы", systemImage: "paperclip")
                                        .font(.caption)
                                }
                            }
                            
                            Text("Урок \(currentLessonIndex + 1) из \(course.lessons.count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(lesson.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(lesson.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        // Lesson content placeholder
                        VStack(spacing: 30) {
                            Image(systemName: lesson.type.icon)
                                .font(.system(size: 100))
                                .foregroundColor(lesson.type.color.opacity(0.3))
                            
                            Text("Здесь будет контент урока")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Тип урока: \(lesson.type.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            if lesson.type == .text && !lesson.content.isEmpty {
                                Text(lesson.content)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                        // Complete lesson button
                        Button(action: completeLesson) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Завершить урок")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            
            // Navigation controls
            HStack(spacing: 20) {
                Button(action: previousLesson) {
                    Image(systemName: "chevron.left")
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray5))
                        .cornerRadius(25)
                }
                .disabled(currentLessonIndex == 0)
                
                // Progress indicator
                VStack {
                    ProgressView(value: Double(currentLessonIndex + 1), total: Double(course.lessons.count))
                    Text("\(currentLessonIndex + 1) / \(course.lessons.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Button(action: nextLesson) {
                    Image(systemName: "chevron.right")
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray5))
                        .cornerRadius(25)
                }
                .disabled(currentLessonIndex >= course.lessons.count - 1)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMaterials) {
            if let lesson = currentLesson {
                LessonMaterialsView(lesson: lesson)
            }
        }
    }
    
    private func completeLesson() {
        guard let lesson = currentLesson else { return }
        // For now, just move to next lesson
        // TODO: Implement proper lesson completion tracking
        
        if currentLessonIndex < course.lessons.count - 1 {
            nextLesson()
        }
    }
    
    private func nextLesson() {
        if currentLessonIndex < course.lessons.count - 1 {
            currentLessonIndex += 1
        }
    }
    
    private func previousLesson() {
        if currentLessonIndex > 0 {
            currentLessonIndex -= 1
        }
    }
}

struct LessonMaterialsView: View {
    let lesson: Lesson
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(lesson.materials) { material in
                    HStack {
                        Image(systemName: material.type.icon)
                            .foregroundColor(material.type.color)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(material.title)
                                .font(.headline)
                            
                            HStack {
                                if let size = material.formattedFileSize {
                                    Text(size)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                if let duration = material.formattedDuration {
                                    Text(duration)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Материалы урока")
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