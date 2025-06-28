import SwiftUI

struct LoginView: View {
    @StateObject private var authService = MockAuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                    // Logo
                    Image(systemName: "building.2.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                        .accessibilityIdentifier("loginLogo")
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("ЦУМ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .accessibilityIdentifier("appTitle")
                        
                        Text("Корпоративный университет")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .accessibilityIdentifier("appSubtitle")
                    }
                    
                    // Login form
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityIdentifier("emailLabel")
                            
                            TextField("Введите email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .accessibilityIdentifier("emailTextField")
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityIdentifier("passwordLabel")
                            
                            SecureField("Введите пароль", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .accessibilityIdentifier("passwordTextField")
                        }
                        
                        // Login button
                        Button(action: login) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .accessibilityIdentifier("loginProgressView")
                            } else {
                                Text("Войти")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .accessibilityIdentifier("loginButtonText")
                            }
                        }
                        .background(loginButtonColor)
                        .cornerRadius(10)
                        .disabled(!isFormValid || authService.isLoading)
                        .accessibilityIdentifier("loginButton")
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 60)
            }
            .navigationBarHidden(true)
            .alert("Ошибка", isPresented: $showingAlert) {
                Button("OK") { 
                    // Alert dismiss action
                }
                .accessibilityIdentifier("alertOKButton")
            } message: {
                Text(alertMessage)
                    .accessibilityIdentifier("alertMessage")
            }
            .onReceive(authService.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
        }
        .accessibilityIdentifier("loginView")
    }
    
    // MARK: - Private Properties
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private var loginButtonColor: Color {
        isFormValid && !authService.isLoading ? .blue : Color.gray.opacity(0.6)
    }
    
    // MARK: - Private Methods
    private func login() {
        guard isFormValid else { return }
        
        // For mock login, determine if admin based on email
        let isAdmin = email.contains("admin")
        authService.mockLogin(asAdmin: isAdmin)
    }
} 