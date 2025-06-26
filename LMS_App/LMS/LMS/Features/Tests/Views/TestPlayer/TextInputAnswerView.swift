//
//  TextInputAnswerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TextInputAnswerView: View {
    @Binding var textAnswer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Введите ответ")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("Ваш ответ", text: $textAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
    }
}

struct EssayAnswerView: View {
    @Binding var essayAnswer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Напишите развернутый ответ")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $essayAnswer)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}
