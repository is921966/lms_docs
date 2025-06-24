//
//  ContentView.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingWelcome = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo placeholder
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                // Title
                Text("TSUM LMS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Subtitle
                Text("Корпоративный университет")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Login button
                Button(action: {
                    // TODO: Implement login
                    print("Login tapped")
                }) {
                    Text("Войти")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                
                // Version info
                Text("Версия 1.0.1")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
