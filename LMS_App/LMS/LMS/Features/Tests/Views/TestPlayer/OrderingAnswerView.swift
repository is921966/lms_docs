//
//  OrderingAnswerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct OrderingAnswerView: View {
    @Binding var orderingAnswer: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Расположите в правильном порядке")
                .font(.caption)
                .foregroundColor(.secondary)

            // В реальном приложении использовать drag and drop
            ForEach(Array(orderingAnswer.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text("\(index + 1).")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    Text(item)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 4) {
                        if index > 0 {
                            Button(action: { moveUp(index: index) }) {
                                Image(systemName: "chevron.up")
                                    .foregroundColor(.blue)
                            }
                        }

                        if index < orderingAnswer.count - 1 {
                            Button(action: { moveDown(index: index) }) {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private func moveUp(index: Int) {
        guard index > 0 else { return }
        orderingAnswer.swapAt(index, index - 1)
    }

    private func moveDown(index: Int) {
        guard index < orderingAnswer.count - 1 else { return }
        orderingAnswer.swapAt(index, index + 1)
    }
}
