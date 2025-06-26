//
//  EssayAnswerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct EssayAnswerView: View {
    @Binding var essayAnswer: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Развернутый ответ")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $essayAnswer)
                .focused($isFocused)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("\(essayAnswer.count) символов")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EssayAnswerView(essayAnswer: .constant(""))
        .padding()
} 