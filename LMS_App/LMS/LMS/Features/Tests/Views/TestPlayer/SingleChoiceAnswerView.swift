//
//  SingleChoiceAnswerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct SingleChoiceAnswerView: View {
    let options: [AnswerOption]
    @Binding var selectedAnswers: Set<UUID>

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                AnswerOptionView(
                    option: option,
                    isSelected: selectedAnswers.contains(option.id),
                    isSingleChoice: true
                ) {
                    selectedAnswers = [option.id]
                }
            }
        }
    }
}

struct MultipleChoiceAnswerView: View {
    let options: [AnswerOption]
    @Binding var selectedAnswers: Set<UUID>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Выберите все правильные ответы")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(options) { option in
                AnswerOptionView(
                    option: option,
                    isSelected: selectedAnswers.contains(option.id),
                    isSingleChoice: false
                ) {
                    if selectedAnswers.contains(option.id) {
                        selectedAnswers.remove(option.id)
                    } else {
                        selectedAnswers.insert(option.id)
                    }
                }
            }
        }
    }
}

struct AnswerOptionView: View {
    let option: AnswerOption
    let isSelected: Bool
    let isSingleChoice: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected
                      ? (isSingleChoice ? "circle.fill" : "checkmark.square.fill")
                      : (isSingleChoice ? "circle" : "square"))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)

                Text(option.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let imageUrl = option.imageUrl {
                    // В реальном приложении загружать изображение
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
