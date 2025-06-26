//
//  TestPlayerHeader.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestPlayerHeader: View {
    @ObservedObject var viewModel: TestViewModel
    let isTimeRunningOut: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * viewModel.currentAttempt!.progress, height: 4)
                }
            }
            .frame(height: 4)
            
            HStack {
                // Question counter
                Text("Вопрос \(viewModel.currentQuestionIndex + 1) из \(viewModel.totalQuestions)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Timer
                if let remainingTime = viewModel.currentAttempt?.formattedRemainingTime {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundColor(isTimeRunningOut ? .red : .blue)
                        Text(remainingTime)
                            .foregroundColor(isTimeRunningOut ? .red : .primary)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
    }
}
