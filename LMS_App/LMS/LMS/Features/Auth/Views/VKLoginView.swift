import SwiftUI
// TODO: Uncomment when VK ID SDK is installed
// import VKID

struct VKLoginView: View {
    @StateObject private var authService = VKIDAuthService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingMockLogin = false
    
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
                    }
                    
                    Spacer()
                    
                    // VK Login Button
                    VKLoginButton(showingMockLogin: $showingMockLogin)
                        .frame(height: 50)
                        .padding(.horizontal, 40)
                    
                    // Info text
                    VStack(spacing: 8) {
                        Text("Войдите через VK ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("После входа администратор должен")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("одобрить вашу учетную запись")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Development mode button (for when VK ID is not available)
                    Button(action: {
                        showingMockLogin = true
                    }) {
                        HStack {
                            Image(systemName: "hammer.fill")
                            Text("Войти в режиме разработки")
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .alert("Информация", isPresented: $showingAlert) {
                Button("OK") { 
                    // After showing the VK ID not installed error, show dev mode option
                    if alertMessage.contains("VK ID SDK не установлен") {
                        showingMockLogin = true
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingMockLogin) {
                MockLoginView()
            }
            .onReceive(authService.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
            .onReceive(authService.$error) { error in
                if let error = error {
                    alertMessage = error
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - VK Login Button
struct VKLoginButton: UIViewControllerRepresentable {
    @StateObject private var authService = VKIDAuthService.shared
    @Binding var showingMockLogin: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Create VK ID button
        let vkButton = UIButton(type: .system)
        vkButton.backgroundColor = UIColor(red: 0/255, green: 119/255, blue: 255/255, alpha: 1)
        vkButton.setTitle("Войти через VK ID", for: .normal)
        vkButton.setTitleColor(.white, for: .normal)
        vkButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        vkButton.layer.cornerRadius = 10
        vkButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add VK logo
        if let vkImage = UIImage(systemName: "v.circle.fill") {
            vkButton.setImage(vkImage, for: .normal)
            vkButton.tintColor = .white
            vkButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        }
        
        vkButton.addTarget(context.coordinator, action: #selector(Coordinator.loginTapped), for: .touchUpInside)
        
        viewController.view.addSubview(vkButton)
        
        NSLayoutConstraint.activate([
            vkButton.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            vkButton.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            vkButton.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            vkButton.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(authService: authService, showingMockLogin: $showingMockLogin)
    }
    
    class Coordinator: NSObject {
        let authService: VKIDAuthService
        @Binding var showingMockLogin: Bool
        
        init(authService: VKIDAuthService, showingMockLogin: Binding<Bool>) {
            self.authService = authService
            self._showingMockLogin = showingMockLogin
        }
        
        @objc func loginTapped() {
            // Since VK ID SDK is not installed, directly show mock login
            showingMockLogin = true
            
            // Original code for when VK ID is available:
            // guard let viewController = UIApplication.shared.windows.first?.rootViewController else { return }
            // authService.loginWithVK(from: viewController)
        }
    }
}

#Preview {
    VKLoginView()
} 