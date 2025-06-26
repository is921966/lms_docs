//
//  FillInBlanksAnswerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct FillInBlanksAnswerView: View {
    let textWithBlanks: String
    let blanksAnswers: [String: [String]]
    @Binding var fillInBlanksAnswers: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Заполните пропуски")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Простая версия - показываем текст и поля ввода отдельно
            Text(textWithBlanks)
                .font(.body)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            ForEach(Array(blanksAnswers.keys.sorted()), id: \.self) { blankId in
                HStack {
                    Text("[\(blankId)]:")
                        .fontWeight(.semibold)
                    
                    TextField("Введите ответ", text: Binding(
                        get: { fillInBlanksAnswers[blankId] ?? "" },
                        set: { fillInBlanksAnswers[blankId] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }
}
