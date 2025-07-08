//
//  Cmi5LessonView.swift
//  LMS
//
//  Created on Sprint 40 Day 3 - Lesson Integration
//

import SwiftUI
import WebKit

/// View для отображения Cmi5 активности в уроке
struct Cmi5LessonView: View {
    let activity: Cmi5Activity
    let studentId: UUID
    let sessionId: UUID
    
    @StateObject private var viewModel = Cmi5LessonViewModel()
    @State private var showingFullScreen = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else if viewModel.isReady {
                contentView
            } else {
                preparingView
            }
        }
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingFullScreen = true }) {
                        Label("Полноэкранный режим", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                    
                    Button(action: viewModel.refresh) {
                        Label("Обновить", systemImage: "arrow.clockwise")
                    }
                    
                    if viewModel.hasProgress {
                        Button(action: viewModel.resetProgress) {
                            Label("Сбросить прогресс", systemImage: "xmark.circle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await viewModel.prepare(
                activity: activity,
                studentId: studentId,
                sessionId: sessionId
            )
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            Cmi5FullScreenView(
                activity: activity,
                launchURL: viewModel.launchURL
            )
        }
    }
    
    // MARK: - Views
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Загрузка активности...")
                .font(.headline)
            
            if let progress = viewModel.loadingProgress {
                Text(progress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var preparingView: some View {
        VStack(spacing: 30) {
            // Activity icon
            Image(systemName: activityIcon)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                .symbolEffect(.bounce, value: viewModel.isReady)
            
            VStack(spacing: 12) {
                Text(activity.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let description = activity.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(.horizontal)
            
            // Activity details
            VStack(spacing: 16) {
                DetailRow(
                    icon: "clock",
                    title: "Продолжительность",
                    value: formatDuration(activity.duration)
                )
                
                DetailRow(
                    icon: "checkmark.circle",
                    title: "Критерий завершения",
                    value: activity.moveOn.localizedName
                )
                
                if let score = activity.masteryScore {
                    DetailRow(
                        icon: "percent",
                        title: "Проходной балл",
                        value: "\(Int(score * 100))%"
                    )
                }
                
                DetailRow(
                    icon: activity.launchMethod == .ownWindow ? "macwindow" : "rectangle.on.rectangle",
                    title: "Режим запуска",
                    value: activity.launchMethod.localizedName
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button(action: {
                viewModel.launch()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Начать")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            // Progress bar
            if viewModel.hasProgress {
                ProgressBar(
                    progress: viewModel.progress,
                    isCompleted: viewModel.isCompleted,
                    isPassed: viewModel.isPassed
                )
            }
            
            // WebView
            Cmi5WebView(
                url: viewModel.launchURL,
                onMessage: viewModel.handleMessage,
                onNavigate: viewModel.handleNavigation,
                onError: viewModel.handleError
            )
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Ошибка загрузки активности")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button(action: viewModel.refresh) {
                    Label("Повторить", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { dismiss() }) {
                    Text("Закрыть")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    private var activityIcon: String {
        if activity.activityType.contains("assessment") {
            return "checkmark.square"
        } else if activity.activityType.contains("media") {
            return "play.square"
        } else if activity.activityType.contains("module") {
            return "book.square"
        } else {
            return "square.stack.3d.up"
        }
    }
    
    private func formatDuration(_ iso8601: String?) -> String {
        guard let duration = iso8601 else { return "Не указано" }
        
        if duration.contains("PT") {
            let cleaned = duration.replacingOccurrences(of: "PT", with: "")
            if cleaned.contains("H") && cleaned.contains("M") {
                let components = cleaned.components(separatedBy: "H")
                if components.count == 2 {
                    let hours = components[0]
                    let minutes = components[1].replacingOccurrences(of: "M", with: "")
                    return "\(hours) ч \(minutes) мин"
                }
            } else if cleaned.contains("H") {
                let hours = cleaned.replacingOccurrences(of: "H", with: "")
                return "\(hours) ч"
            } else if cleaned.contains("M") {
                let minutes = cleaned.replacingOccurrences(of: "M", with: "")
                return "\(minutes) мин"
            }
        }
        return duration
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Progress Bar

private struct ProgressBar: View {
    let progress: Double
    let isCompleted: Bool
    let isPassed: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Прогресс: \(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 12) {
                    if isCompleted {
                        Label("Завершено", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if isPassed {
                        Label("Пройдено", systemImage: "star.circle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
    
    private var progressColor: Color {
        if isPassed {
            return .green
        } else if isCompleted {
            return .blue
        } else {
            return .accentColor
        }
    }
}

// MARK: - WebView

struct Cmi5WebView: UIViewRepresentable {
    let url: URL?
    let onMessage: (String) -> Void
    let onNavigate: (URL) -> Bool
    let onError: (Error) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // Настройки для Cmi5
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // JavaScript message handler
        configuration.userContentController.add(
            context.coordinator,
            name: "cmi5Handler"
        )
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onMessage: onMessage,
            onNavigate: onNavigate,
            onError: onError
        )
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let onMessage: (String) -> Void
        let onNavigate: (URL) -> Bool
        let onError: (Error) -> Void
        
        init(
            onMessage: @escaping (String) -> Void,
            onNavigate: @escaping (URL) -> Bool,
            onError: @escaping (Error) -> Void
        ) {
            self.onMessage = onMessage
            self.onNavigate = onNavigate
            self.onError = onError
        }
        
        // WKScriptMessageHandler
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "cmi5Handler",
               let body = message.body as? String {
                onMessage(body)
            }
        }
        
        // WKNavigationDelegate
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                if onNavigate(url) {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.allow)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onError(error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onError(error)
        }
    }
}

// MARK: - Full Screen View

struct Cmi5FullScreenView: View {
    let activity: Cmi5Activity
    let launchURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let url = launchURL {
                Cmi5WebView(
                    url: url,
                    onMessage: { _ in },
                    onNavigate: { _ in true },
                    onError: { _ in }
                )
                .ignoresSafeArea()
            }
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white, .black.opacity(0.5))
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - View Model

@MainActor
final class Cmi5LessonViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var isReady = false
    @Published var error: Error?
    @Published var launchURL: URL?
    @Published var loadingProgress: String?
    
    @Published var progress: Double = 0
    @Published var isCompleted = false
    @Published var isPassed = false
    @Published var hasProgress = false
    
    private var activity: Cmi5Activity?
    private var studentId: UUID?
    private var sessionId: UUID?
    private let service = Cmi5Service()
    
    func prepare(activity: Cmi5Activity, studentId: UUID, sessionId: UUID) async {
        self.activity = activity
        self.studentId = studentId
        self.sessionId = sessionId
        
        isLoading = true
        loadingProgress = "Подготовка сессии..."
        
        do {
            // Получаем URL для запуска
            launchURL = try await service.getLaunchURL(
                for: activity,
                studentId: studentId,
                sessionId: sessionId
            )
            
            // TODO: Загрузить прогресс из LRS
            
            isLoading = false
            isReady = false // Показываем экран подготовки
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func launch() {
        isReady = true
    }
    
    func refresh() {
        guard let activity = activity,
              let studentId = studentId,
              let sessionId = sessionId else { return }
        
        Task {
            await prepare(
                activity: activity,
                studentId: studentId,
                sessionId: sessionId
            )
        }
    }
    
    func resetProgress() {
        progress = 0
        isCompleted = false
        isPassed = false
        hasProgress = false
        
        // TODO: Сбросить прогресс в LRS
    }
    
    func handleMessage(_ message: String) {
        // Обработка сообщений от Cmi5 контента
        print("Cmi5 message: \(message)")
        
        // TODO: Парсить xAPI statements
    }
    
    func handleNavigation(_ url: URL) -> Bool {
        // Разрешаем навигацию внутри контента
        return true
    }
    
    func handleError(_ error: Error) {
        self.error = error
    }
} 