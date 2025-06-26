//
//  TestResultView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct TestResultView: View {
    let test: Test
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Result summary
                Text("Результаты теста")
                    .font(.largeTitle)
                    .padding()
                
                Text(test.title)
                    .font(.title2)
                    .padding()
            }
        }
        .navigationTitle("Результаты")
    }
}
