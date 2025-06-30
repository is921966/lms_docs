//
//  TestQuestionView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestQuestionView: View {
    let question: Question
    let points: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question type badge
            HStack {
                Image(systemName: question.type.icon)
                Text(question.type.rawValue)
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue)
            .cornerRadius(8)

            // Question text
            Text(question.text)
                .font(.title3)
                .fontWeight(.semibold)

            // Question image if exists
            if let imageUrl = question.imageUrl {
                // В реальном приложении загружать изображение
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Text("Изображение")
                            .foregroundColor(.gray)
                    )
            }

            // Points
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text("\(points) баллов")
                    .foregroundColor(.secondary)
            }
            .font(.caption)

            // Hint if available
            if let hint = question.hint {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                    Text(hint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}
