import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("ЦУМ: Корпоративный университет")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Login form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                    
                    Button(action: {
                        Task {
                            await viewModel.login(email: email, password: password)
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Войти")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Demo mode
                Button("Войти в демо-режиме") {
                    coordinator.isAuthenticated = true
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            .alert("Ошибка", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Ошибка входа")
            }
        }
    }
}

struct LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let loginUseCase: LoginUseCaseProtocol
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }
    
    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        showError = false
        
        do {
            try await loginUseCase.execute(email: email, password: password)
            // Success is handled by AppCoordinator
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
} 