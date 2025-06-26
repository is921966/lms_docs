//
//  TestLoadingView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Загрузка теста...")
                .foregroundColor(.secondary)
        }
    }
}
