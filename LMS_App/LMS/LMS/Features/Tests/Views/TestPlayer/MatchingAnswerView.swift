//
//  MatchingAnswerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct MatchingAnswerView: View {
    let matchingPairs: [MatchingPair]
    @Binding var matchingAnswers: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сопоставьте элементы")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(matchingPairs) { pair in
                HStack {
                    Text(pair.left)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)

                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)

                    Menu {
                        ForEach(matchingPairs.map { $0.right }.shuffled(), id: \.self) { right in
                            Button(right) {
                                matchingAnswers[pair.left] = right
                            }
                        }
                    } label: {
                        Text(matchingAnswers[pair.left] ?? "Выберите")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
