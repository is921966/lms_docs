import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoggingIn = false

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

                            TextField("your.email@tsum.ru", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .disabled(isLoggingIn)
                                .accessibilityIdentifier("emailField")
                                .onChange(of: email) { oldValue, newValue in
                                    UIEventLogger.shared.logTextInput("email", oldValue: oldValue, newValue: newValue, in: "LoginView")
                                }
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            SecureField("••••••••", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoggingIn)
                                .accessibilityIdentifier("passwordField")
                                .onChange(of: password) { oldValue, newValue in
                                    UIEventLogger.shared.logTextInput("password", oldValue: oldValue.isEmpty ? "" : "***", newValue: newValue.isEmpty ? "" : "***", in: "LoginView")
                                }
                        }

                        // Login button
                        Button(action: {
                            login()
                        }) {
                            HStack {
                                if isLoggingIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Text("Войти")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(email.isEmpty || password.isEmpty || isLoggingIn ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                        .accessibilityIdentifier("loginButton")

                        // Quick login buttons
                        VStack(spacing: 10) {
                            Text("Быстрый вход для тестирования:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack(spacing: 10) {
                                // User quick login
                                Button(action: {
                                    UIEventLogger.shared.logButtonTap("Quick Login Пользователь", in: "LoginView", details: [
                                        "email": "test@tsum.ru",
                                        "role": "user"
                                    ])
                                    email = "test@tsum.ru"
                                    password = "password123"
                                    ComprehensiveLogger.shared.log(.data, .info, "Login credentials set", details: [
                                        "email": "test@tsum.ru",
                                        "role": "user",
                                        "action": "quick_login"
                                    ])
                                    login()
                                }) {
                                    VStack {
                                        Image(systemName: "person.fill")
                                            .font(.title2)
                                        Text("Пользователь")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                                }
                                .accessibilityIdentifier("quickLoginUser")

                                // Admin quick login
                                Button(action: {
                                    UIEventLogger.shared.logButtonTap("Quick Login Администратор", in: "LoginView", details: [
                                        "email": "admin@tsum.ru",
                                        "role": "admin"
                                    ])
                                    email = "admin@tsum.ru"
                                    password = "admin123"
                                    ComprehensiveLogger.shared.log(.data, .info, "Login credentials set", details: [
                                        "email": "admin@tsum.ru",
                                        "role": "admin",
                                        "action": "quick_login"
                                    ])
                                    login()
                                }) {
                                    VStack {
                                        Image(systemName: "person.badge.shield.checkmark.fill")
                                            .font(.title2)
                                        Text("Администратор")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(10)
                                }
                                .accessibilityIdentifier("quickLoginAdmin")
                            }
                        }
                        .padding(.top, 20)
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
        .onAppear {
            NavigationTracker.shared.trackScreen("LoginView", metadata: ["module": "Auth"])
            UIEventLogger.shared.logViewState("LoginView", state: [
                "emailFieldEmpty": email.isEmpty,
                "passwordFieldEmpty": password.isEmpty,
                "isLoading": isLoggingIn,
                "hasError": !alertMessage.isEmpty
            ])
        }
    }

    private func login() {
        UIEventLogger.shared.logButtonTap("Login", in: "LoginView", details: [
            "email": email,
            "authMethod": "standard"
        ])
        
        UIEventLogger.shared.logLoadingState(true, in: "LoginView", reason: "Authentication")
        
        isLoggingIn = true
        alertMessage = ""

        Task {
            do {
                _ = try await authService.login(email: email, password: password)
                UIEventLogger.shared.logLoadingState(false, in: "LoginView", reason: "Authentication")
                ComprehensiveLogger.shared.log(.auth, .info, "Login successful", details: [
                    "email": email,
                    "method": "manual"
                ])
            } catch {
                UIEventLogger.shared.logLoadingState(false, in: "LoginView", reason: "Authentication")
                UIEventLogger.shared.logErrorState(error, in: "LoginView", context: [
                    "email": email
                ])
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoggingIn = false
        }
    }
}
