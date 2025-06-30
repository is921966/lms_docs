//
//  TestBookmarkButton.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestBookmarkButton: View {
    @ObservedObject var viewModel: TestViewModel

    var body: some View {
        Button(action: toggleMark) {
            Image(systemName: viewModel.isCurrentQuestionMarked() ? "bookmark.fill" : "bookmark")
                .foregroundColor(.orange)
        }
    }

    private func toggleMark() {
        if viewModel.isCurrentQuestionMarked() {
            viewModel.unmarkCurrentQuestion()
        } else {
            viewModel.markCurrentQuestion()
        }
    }
}
