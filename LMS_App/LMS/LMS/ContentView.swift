//
//  ContentView.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            // App icon
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // App title
            Text("TSUM LMS")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Login button
            Button(action: {
                print("Login tapped")
            }) {
                Text("Войти")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            // Version info - CI/CD success!
            Text("Version 1.0.5")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 5)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
