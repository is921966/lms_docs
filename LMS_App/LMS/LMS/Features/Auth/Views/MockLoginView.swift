import SwiftUI

struct MockLoginView: View {
    @StateObject private var authService = MockAuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo
                    Image(systemName: "building.2.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("ЦУМ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Корпоративный университет")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("(Режим разработки)")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 5)
                    }
                    
                    Spacer()
                    
                    // Mock Login Buttons
                    VStack(spacing: 15) {
                        // Student login
                        Button(action: {
                            authService.mockLogin(asAdmin: false)
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Войти как Студент")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(authService.isLoading)
                        
                        // Admin login
                        Button(action: {
                            authService.mockLogin(asAdmin: true)
                        }) {
                            HStack {
                                Image(systemName: "person.badge.shield.checkmark.fill")
                                Text("Войти как Админ")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                        .disabled(authService.isLoading)
                    }
                    .padding(.horizontal, 40)
                    
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    
                    // Info text
                    VStack(spacing: 5) {
                        Text("Это тестовый режим")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("VK ID будет доступен позже")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onReceive(authService.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    MockLoginView()
} 