//  Cmi5PlayerView.swift
//  LMS
//
//  Created by LMS on 17.01.2025.
//

import SwiftUI
import WebKit

/// View для воспроизведения Cmi5 контента с поддержкой xAPI
struct Cmi5PlayerView: View {
    // MARK: - Properties
    
    let packageId: UUID?
    let activityId: String?
    let sessionId: String
    let launchParameters: [String: String]
    
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0
    @State private var error: Error?
    @State private var webView: WKWebView?
    @State private var showControls = true
    @State private var isFullScreen = false
    @State private var activity: Cmi5Activity?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cmi5Service: Cmi5Service
    @EnvironmentObject private var lrsService: LRSService
    
    // MARK: - Callbacks
    
    var onStatement: ((XAPIStatement) -> Void)?
    var onCompletion: ((Bool) -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // WebView container
            webViewContainer
                .ignoresSafeArea(isFullScreen ? .all : .init())
            
            // Loading overlay
            if isLoading {
                loadingOverlay
            }
            
            // Error view
            if let error = error {
                errorView(error)
            }
            
            // Controls overlay
            if showControls && !isLoading {
                controlsOverlay
            }
        }
        .navigationBarHidden(isFullScreen)
        .statusBar(hidden: isFullScreen)
        .onAppear {
            launchActivity()
        }
        .onDisappear {
            terminateActivity()
        }
    }
    
    // MARK: - Views
    
    private var webViewContainer: some View {
        WebViewRepresentable(
            url: buildLaunchURL() ?? URL(string: "about:blank")!,
            onLoadStart: { webView in
                self.webView = webView
                isLoading = true
            },
            onLoadProgress: { progress in
                loadingProgress = progress
            },
            onLoadComplete: { success in
                isLoading = false
                if success {
                    sendInitializedStatement()
                }
            },
            onError: { error in
                self.error = error
                isLoading = false
            },
            onStatement: { statement in
                self.onStatement?(statement)
            },
            onCompletion: self.onCompletion
        )
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Загрузка контента...")
                    .foregroundColor(.white)
                    .font(.headline)
                
                ProgressView(value: loadingProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 200)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Ошибка загрузки")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("Повторить") {
                    self.error = nil
                    launchActivity()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Закрыть") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: 400)
    }
    
    private var controlsOverlay: some View {
        VStack {
            // Top controls
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: toggleFullScreen) {
                    Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding()
            
            Spacer()
            
            // Bottom info bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity?.title ?? "Loading...")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Session: \(sessionId)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.7), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .opacity(showControls ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: showControls)
        .onTapGesture {
            withAnimation {
                showControls.toggle()
            }
        }
    }
    
    // MARK: - Methods
    
    private func buildLaunchURL() -> URL? {
        guard let packageId = packageId,
              let activityId = activityId else {
            print("❌ [Cmi5PlayerView] Missing packageId or activityId")
            return nil
        }
        
        print("🔍 [Cmi5PlayerView] buildLaunchURL() started")
        print("   - packageId: \(packageId)")
        print("   - activityId: \(activityId)")
        
        let fileManager = FileManager.default
        
        // Получаем путь к папке документов
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ [Cmi5PlayerView] Could not find documents directory")
            return nil
        }
        
        // Путь к папке пакета в Cmi5Storage
        let packagePath = documentsPath.appendingPathComponent("Cmi5Storage").appendingPathComponent(packageId.uuidString)
        
        print("📁 [Cmi5PlayerView] Package path: \(packagePath.path)")
        print("📁 [Cmi5PlayerView] Package exists: \(fileManager.fileExists(atPath: packagePath.path))")
        
        // Проверяем существование папки пакета
        guard fileManager.fileExists(atPath: packagePath.path) else {
            print("❌ [Cmi5PlayerView] Package directory not found")
            return nil
        }
        
        // Пробуем найти файл активности
        // Сначала попробуем загрузить cmi5.xml чтобы найти URL активности
        let cmi5XmlPath = packagePath.appendingPathComponent("cmi5.xml")
        
        if fileManager.fileExists(atPath: cmi5XmlPath.path),
           let xmlData = try? Data(contentsOf: cmi5XmlPath) {
            
            do {
                let parser = Cmi5XMLParser()
                let parseResult = try parser.parseManifest(xmlData, baseURL: packagePath)
                let manifest = parseResult.manifest
                
                // Ищем активность по ID
                if let activity = findActivityInManifest(manifest, activityId: activityId) {
                    print("✅ [Cmi5PlayerView] Found activity: \(activity.title)")
                    print("   - Launch URL: \(activity.launchUrl)")
                    
                    // Проверяем существование файла
                    let contentUrl = packagePath.appendingPathComponent(activity.launchUrl)
                    
                    if fileManager.fileExists(atPath: contentUrl.path) {
                        print("✅ [Cmi5PlayerView] Content file exists: \(contentUrl.path)")
                        return contentUrl
                    } else {
                        print("❌ [Cmi5PlayerView] Content file not found: \(contentUrl.path)")
                        
                        // Пробуем альтернативные пути
                        let alternativePaths = [
                            packagePath.appendingPathComponent("index.html"),
                            packagePath.appendingPathComponent("content/index.html"),
                            packagePath.appendingPathComponent("content.html")
                        ]
                        
                        for altPath in alternativePaths {
                            if fileManager.fileExists(atPath: altPath.path) {
                                print("✅ [Cmi5PlayerView] Found alternative content: \(altPath.path)")
                                return altPath
                            }
                        }
                    }
                } else {
                    print("❌ [Cmi5PlayerView] Activity not found in manifest")
                }
            } catch {
                print("❌ [Cmi5PlayerView] Error parsing manifest: \(error)")
            }
        }
        
        // Если не нашли через манифест, пробуем найти index.html напрямую
        let indexPath = packagePath.appendingPathComponent("index.html")
        if fileManager.fileExists(atPath: indexPath.path) {
            print("✅ [Cmi5PlayerView] Found index.html: \(indexPath.path)")
            return indexPath
        }
        
        print("❌ [Cmi5PlayerView] No content file found")
        
        // Логируем содержимое директории для отладки
        if let contents = try? fileManager.contentsOfDirectory(atPath: packagePath.path) {
            print("📁 [Cmi5PlayerView] Package contents:")
            for file in contents {
                print("   - \(file)")
            }
        }
        
        return nil
    }
    
    private func findActivityInManifest(_ manifest: Cmi5Manifest, activityId: String) -> Cmi5Activity? {
        // Проверяем в корневом блоке
        if let rootBlock = manifest.course?.rootBlock {
            return findActivityInBlock(rootBlock, activityId: activityId)
        }
        return nil
    }
    
    private func findActivityInBlock(_ block: Cmi5Block, activityId: String) -> Cmi5Activity? {
        // Проверяем активности в текущем блоке
        for activity in block.activities {
            if activity.activityId == activityId {
                return activity
            }
        }
        
        // Рекурсивно проверяем вложенные блоки
        for subBlock in block.blocks {
            if let activity = findActivityInBlock(subBlock, activityId: activityId) {
                return activity
            }
        }
        
        return nil
    }
    
    private func launchActivity() {
        // Сначала загружаем активность из манифеста
        Task {
            await loadActivity()
            
            if activity != nil {
                // Отправляем launched statement в LRS
                do {
                    let statement = try XAPIStatementBuilder()
                        .setActor(lrsService.currentActor)
                        .setVerb(XAPIStatementBuilder.Cmi5Verb.launched)
                        .setObject(XAPIObject.activity(activity!.toXAPIActivity()))
                        .setCmi5Context(sessionId: sessionId, registration: UUID().uuidString)
                        .build()
                    
                    try await lrsService.sendStatement(statement)
                    onStatement?(statement)
                } catch {
                    print("❌ [Cmi5PlayerView] Error creating/sending launched statement: \(error)")
                }
            }
        }
    }
    
    @MainActor
    private func loadActivity() async {
        guard let packageId = packageId,
              let activityId = activityId else {
            print("❌ [Cmi5PlayerView] Missing packageId or activityId")
            return
        }
        
        // Загружаем манифест из файловой системы
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let packagePath = documentsPath.appendingPathComponent("Cmi5Storage").appendingPathComponent(packageId.uuidString)
        let cmi5XmlPath = packagePath.appendingPathComponent("cmi5.xml")
        
        if fileManager.fileExists(atPath: cmi5XmlPath.path),
           let xmlData = try? Data(contentsOf: cmi5XmlPath) {
            
            do {
                let parser = Cmi5XMLParser()
                let parseResult = try parser.parseManifest(xmlData, baseURL: packagePath)
                let manifest = parseResult.manifest
                
                // Ищем активность в манифесте
                if let foundActivity = findActivityInManifest(manifest, activityId: activityId) {
                    self.activity = foundActivity
                    print("✅ [Cmi5PlayerView] Activity loaded: \(foundActivity.title)")
                }
            } catch {
                print("❌ [Cmi5PlayerView] Error parsing manifest: \(error)")
            }
        }
    }
    
    private func sendInitializedStatement() {
        Task {
            if let activity = activity {
                do {
                    let statement = try XAPIStatementBuilder()
                        .setActor(lrsService.currentActor)
                        .setVerb(XAPIStatementBuilder.Cmi5Verb.initialized)
                        .setObject(XAPIObject.activity(activity.toXAPIActivity()))
                        .setCmi5Context(sessionId: sessionId, registration: UUID().uuidString)
                        .build()
                    
                    try await lrsService.sendStatement(statement)
                    onStatement?(statement)
                } catch {
                    print("❌ [Cmi5PlayerView] Error sending initialized statement: \(error)")
                }
            }
        }
    }
    
    private func terminateActivity() {
        Task {
            if let activity = activity {
                do {
                    let statement = try XAPIStatementBuilder()
                        .setActor(lrsService.currentActor)
                        .setVerb(XAPIStatementBuilder.Cmi5Verb.terminated)
                        .setObject(XAPIObject.activity(activity.toXAPIActivity()))
                        .setCmi5Context(sessionId: sessionId, registration: UUID().uuidString)
                        .build()
                    
                    try await lrsService.sendStatement(statement)
                    onStatement?(statement)
                    onCompletion?(true)
                } catch {
                    print("❌ [Cmi5PlayerView] Error sending terminated statement: \(error)")
                }
            }
        }
    }
    
    private func handleStatement(_ statement: XAPIStatement) {
        // Notify callback
        onStatement?(statement)
        
        // Check for completion
        if statement.verb.id == XAPIStatementBuilder.Cmi5Verb.completed.id ||
           statement.verb.id == XAPIStatementBuilder.Cmi5Verb.passed.id {
            onCompletion?(true)
            // Закрываем view
            DispatchQueue.main.async {
                self.dismiss()
            }
        } else if statement.verb.id == XAPIStatementBuilder.Cmi5Verb.failed.id {
            onCompletion?(false)
        }
    }
    
    private func handleCmi5Message(_ message: [String: Any]) {
        print("📨 [Cmi5PlayerView] Received Cmi5 message: \(message)")
        
        // Обработка различных типов сообщений от Cmi5 контента
        if let command = message["command"] as? String {
            switch command {
            case "terminate":
                terminateActivity()
            case "complete":
                // Обработка завершения активности
                onCompletion?(true)
            case "pass":
                // Обработка успешного прохождения
                onCompletion?(true)
            case "fail":
                // Обработка неудачного прохождения
                onCompletion?(false)
            default:
                print("⚠️ [Cmi5PlayerView] Unknown Cmi5 command: \(command)")
            }
        }
    }
    
    private func toggleFullScreen() {
        withAnimation {
            isFullScreen.toggle()
            showControls = false
        }
    }
}

// MARK: - WebView Representable

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    let onLoadStart: (WKWebView) -> Void
    let onLoadProgress: (Double) -> Void
    let onLoadComplete: (Bool) -> Void
    let onError: (Error) -> Void
    let onStatement: (XAPIStatement) -> Void
    let onCompletion: ((Bool) -> Void)?  // Добавляем опциональный callback для завершения
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Add xAPI message handler
        configuration.userContentController.add(
            context.coordinator,
            name: "xapi"
        )
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
            onLoadStart(webView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.onLoadProgress(0)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.onLoadProgress(0.5)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onLoadProgress(1.0)
            parent.onLoadComplete(true)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onError(error)
            parent.onLoadComplete(false)
        }
        
        // MARK: - WKScriptMessageHandler
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "xapi" else { return }
            
            print("📱 [Cmi5PlayerView] Received xAPI message: \(message.body)")
            
            // Обрабатываем простые сообщения из демо-контента
            if let messageBody = message.body as? [String: Any] {
                // Получаем verb
                let verb = messageBody["verb"] as? String ?? "unknown"
                
                // Обрабатываем специальные события
                switch verb {
                case "completed":
                    print("✅ [Cmi5PlayerView] Activity completed!")
                    // Вызываем callback завершения
                    DispatchQueue.main.async {
                        self.parent.onCompletion?(true)
                        
                        // Также можем показать alert
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            let alert = UIAlertController(
                                title: "Поздравляем!",
                                message: "Вы успешно завершили урок.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                // Закрываем view через onCompletion
                                self.parent.onCompletion?(true)
                            })
                            rootViewController.present(alert, animated: true)
                        }
                    }
                    
                case "progressed":
                    if let result = messageBody["result"] as? [String: Any],
                       let extensions = result["extensions"] as? [String: Any],
                       let progress = extensions["progress"] as? Double {
                        print("📊 [Cmi5PlayerView] Progress: \(progress * 100)%")
                    }
                    
                case "initialized":
                    print("🚀 [Cmi5PlayerView] Activity initialized")
                    
                default:
                    print("ℹ️ [Cmi5PlayerView] Unknown verb: \(verb)")
                }
                
                // Пытаемся создать настоящий XAPIStatement (опционально)
                // Это нужно только для полноценных xAPI сообщений
                if let statementData = try? JSONSerialization.data(withJSONObject: messageBody),
                   let statement = try? JSONDecoder().decode(XAPIStatement.self, from: statementData) {
                    parent.onStatement(statement)
                }
            }
        }
    }
}

// MARK: - Preview

struct Cmi5PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Cmi5PlayerView(
                packageId: UUID(),
                activityId: "activity-1",
                sessionId: UUID().uuidString,
                launchParameters: [
                    "lang": "ru",
                    "theme": "light"
                ]
            )
        }
        .environmentObject(Cmi5Service())
        .environmentObject(LRSService())
    }
} 