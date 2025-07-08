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
    
    let activity: Cmi5Activity
    let sessionId: String
    let launchParameters: [String: String]
    
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0
    @State private var error: Error?
    @State private var webView: WKWebView?
    @State private var showControls = true
    @State private var isFullScreen = false
    
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
            url: buildLaunchURL(),
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
                handleStatement(statement)
            }
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
                    Text(activity.title)
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
    
    private func buildLaunchURL() -> URL {
        var components = URLComponents(string: activity.launchUrl)!
        
        // Add launch parameters
        var queryItems = launchParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Add session ID
        queryItems.append(URLQueryItem(name: "session", value: sessionId))
        
        // Add endpoint
        queryItems.append(URLQueryItem(name: "endpoint", value: lrsService.endpoint))
        
        // Add auth token
        queryItems.append(URLQueryItem(name: "auth", value: lrsService.authToken))
        
        components.queryItems = queryItems
        
        return components.url!
    }
    
    private func launchActivity() {
        Task {
            do {
                // Send launched statement
                let launchedStatement = XAPIStatementBuilder()
                    .setActor(lrsService.currentActor)
                    .setVerb(XAPIStatementBuilder.Cmi5Verb.launched)
                    .setObject(XAPIObject.activity(activity.toXAPIActivity()))
                    .setCmi5Context(sessionId: sessionId, registration: UUID().uuidString)
                    .build()
                
                try await lrsService.sendStatement(launchedStatement)
                handleStatement(launchedStatement)
            } catch {
                self.error = error
            }
        }
    }
    
    private func sendInitializedStatement() {
        Task {
            do {
                let initializedStatement = XAPIStatementBuilder()
                    .setActor(lrsService.currentActor)
                    .setVerb(XAPIStatementBuilder.Cmi5Verb.initialized)
                    .setObject(XAPIObject.activity(activity.toXAPIActivity()))
                    .setCmi5Context(sessionId: sessionId, registration: UUID().uuidString)
                    .build()
                
                try await lrsService.sendStatement(initializedStatement)
                handleStatement(initializedStatement)
            } catch {
                print("Failed to send initialized statement: \(error)")
            }
        }
    }
    
    private func terminateActivity() {
        Task {
            do {
                let terminatedStatement = XAPIStatementBuilder()
                    .setActor(lrsService.currentActor)
                    .setVerb(XAPIStatementBuilder.Cmi5Verb.terminated)
                    .setObject(XAPIObject.activity(activity.toXAPIActivity()))
                    .setCmi5Context(sessionId: sessionId, registration: UUID().uuidString)
                    .build()
                
                try await lrsService.sendStatement(terminatedStatement)
                handleStatement(terminatedStatement)
            } catch {
                print("Failed to send terminated statement: \(error)")
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
        } else if statement.verb.id == XAPIStatementBuilder.Cmi5Verb.failed.id {
            onCompletion?(false)
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
            guard message.name == "xapi",
                  let messageBody = message.body as? [String: Any],
                  let statementData = try? JSONSerialization.data(withJSONObject: messageBody),
                  let statement = try? JSONDecoder().decode(XAPIStatement.self, from: statementData) else {
                return
            }
            
            parent.onStatement(statement)
        }
    }
}

// MARK: - Preview

struct Cmi5PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Cmi5PlayerView(
                activity: Cmi5Activity(
                    id: UUID(),
                    packageId: UUID(),
                    activityId: "activity-1",
                    title: "Тестовая активность",
                    description: "Описание активности",
                    launchUrl: "https://example.com/cmi5/activity",
                    launchMethod: .ownWindow,
                    moveOn: .passed,
                    masteryScore: nil,
                    activityType: "http://adlnet.gov/expapi/activities/course",
                    duration: nil
                ),
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