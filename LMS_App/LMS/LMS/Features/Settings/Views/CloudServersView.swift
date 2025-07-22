import SwiftUI
import WebKit

struct CloudServersView: View {
    @State private var selectedServer = 0
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingShareSheet = false
    @State private var currentURL: URL?
    @State private var showingSettings = false
    @State private var webViewKey = UUID() // Добавляем ключ для управления пересозданием WebView
    
    private var servers: [CloudServer] {
        [
            CloudServer(
                name: "📊 Log Dashboard",
                url: CloudServerManager.shared.logServerURL,
                description: "Просмотр логов приложения в реальном времени",
                icon: "doc.text.magnifyingglass",
                color: .blue
            ),
            CloudServer(
                name: "💬 Feedback Dashboard",
                url: CloudServerManager.shared.feedbackServerURL,
                description: "Управление отзывами пользователей",
                icon: "bubble.left.and.bubble.right.fill",
                color: .green
            )
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Server selector
            Picker("Server", selection: $selectedServer) {
                ForEach(servers.indices, id: \.self) { index in
                    Label(servers[index].name, systemImage: servers[index].icon)
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedServer) { oldValue, newValue in
                ComprehensiveLogger.shared.log(.ui, .info, "Server switched", details: [
                    "from": servers[safe: oldValue]?.name ?? "unknown",
                    "to": servers[safe: newValue]?.name ?? "unknown"
                ])
                // Обновляем ключ чтобы пересоздать WebView при смене сервера
                webViewKey = UUID()
                isLoading = true
                errorMessage = nil
            }
            
            // Server info card with health status
            ServerInfoCard(server: servers[selectedServer])
                .padding(.horizontal)
            
            // Web view
            ZStack {
                CloudServerWebView(
                    url: servers[selectedServer].url,
                    isLoading: $isLoading,
                    errorMessage: $errorMessage
                )
                .id(webViewKey) // Используем ключ для управления жизненным циклом
                
                if isLoading {
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
                
                if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Ошибка подключения")
                            .font(.headline)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            Button("Попробовать снова") {
                                errorMessage = nil
                                isLoading = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Настройки серверов") {
                                showingSettings = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                }
            }
        }
        .navigationTitle("Cloud Servers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        currentURL = URL(string: servers[selectedServer].url)
                        showingShareSheet = true
                        ComprehensiveLogger.shared.log(.ui, .info, "Share server URL", details: [
                            "server": servers[selectedServer].name
                        ])
                    }) {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        if let url = URL(string: servers[selectedServer].url) {
                            UIApplication.shared.open(url)
                            ComprehensiveLogger.shared.log(.ui, .info, "Open in Safari", details: [
                                "url": url.absoluteString
                            ])
                        }
                    }) {
                        Label("Открыть в Safari", systemImage: "safari")
                    }
                    
                    Button(action: {
                        isLoading = true
                        errorMessage = nil
                        ComprehensiveLogger.shared.log(.ui, .info, "Refresh dashboard", details: [
                            "server": servers[selectedServer].name
                        ])
                    }) {
                        Label("Обновить", systemImage: "arrow.clockwise")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        showingSettings = true
                        ComprehensiveLogger.shared.log(.ui, .info, "Open server settings")
                    }) {
                        Label("Настройки серверов", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = currentURL {
                CloudServerShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showingSettings) {
            CloudServerSettingsView()
        }
    }
}

// MARK: - Server Info Card
struct ServerInfoCard: View {
    let server: CloudServer
    @State private var isHealthy = false
    @State private var isChecking = true
    @State private var hasChecked = false // Добавляем флаг для предотвращения повторных проверок
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: server.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(server.color)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.headline)
                
                Text(server.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(server.url)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isChecking {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: isHealthy ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(isHealthy ? .green : .orange)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear {
            if !hasChecked {
                checkHealth()
                hasChecked = true
            }
            ComprehensiveLogger.shared.log(.ui, .info, "ServerInfoCard appeared", details: [
                "server": server.name
            ])
        }
    }
    
    private func checkHealth() {
        isChecking = true
        
        CloudServerManager.shared.checkServerHealth { logHealthy, feedbackHealthy in
            DispatchQueue.main.async {
                if server.name.contains("Log") {
                    isHealthy = logHealthy
                } else {
                    isHealthy = feedbackHealthy
                }
                isChecking = false
                
                ComprehensiveLogger.shared.log(.network, .info, "Server health check completed", details: [
                    "server": server.name,
                    "healthy": isHealthy
                ])
            }
        }
    }
}

// MARK: - Settings View
struct CloudServerSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var logServerURL = CloudServerManager.shared.logServerURL
    @State private var feedbackServerURL = CloudServerManager.shared.feedbackServerURL
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Server")) {
                    TextField("URL", text: $logServerURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Default: https://lms-log-server-production.up.railway.app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Feedback Server")) {
                    TextField("URL", text: $feedbackServerURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Default: https://lms-feedback-server-production.up.railway.app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Сохранить изменения") {
                        CloudServerManager.shared.updateURLs(
                            logServer: logServerURL,
                            feedbackServer: feedbackServerURL
                        )
                        ComprehensiveLogger.shared.log(.ui, .info, "Server URLs updated", details: [
                            "logServer": logServerURL,
                            "feedbackServer": feedbackServerURL
                        ])
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    
                    Button("Сбросить на значения по умолчанию") {
                        showingResetAlert = true
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Настройки серверов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert("Сбросить настройки?", isPresented: $showingResetAlert) {
                Button("Сбросить", role: .destructive) {
                    CloudServerManager.shared.resetToDefaults()
                    logServerURL = CloudServerManager.shared.logServerURL
                    feedbackServerURL = CloudServerManager.shared.feedbackServerURL
                    ComprehensiveLogger.shared.log(.ui, .warning, "Server URLs reset to defaults")
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("URL серверов будут сброшены на значения по умолчанию")
            }
        }
    }
}

// MARK: - Web View
struct CloudServerWebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: CloudServerWebView
        var hasLoadedInitialURL = false
        
        init(_ parent: CloudServerWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.errorMessage = nil
            ComprehensiveLogger.shared.log(.network, .debug, "WebView started loading", details: [
                "url": webView.url?.absoluteString ?? "unknown"
            ])
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            hasLoadedInitialURL = true
            ComprehensiveLogger.shared.log(.network, .info, "WebView finished loading", details: [
                "url": webView.url?.absoluteString ?? "unknown"
            ])
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription
            ComprehensiveLogger.shared.log(.network, .error, "WebView failed to load", details: [
                "error": error.localizedDescription
            ])
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription
            ComprehensiveLogger.shared.log(.network, .error, "WebView failed provisional navigation", details: [
                "error": error.localizedDescription
            ])
        }
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Настройки для лучшего отображения
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // Загружаем URL сразу при создании
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Не обновляем если уже загружен начальный URL
        guard !context.coordinator.hasLoadedInitialURL else { return }
        
        // Проверяем, изменился ли URL
        if let currentURL = webView.url?.absoluteString,
           currentURL != url,
           let newURL = URL(string: url) {
            let request = URLRequest(url: newURL)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Models
struct CloudServer {
    let name: String
    let url: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Share Sheet
struct CloudServerShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct CloudServersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CloudServersView()
        }
    }
} 