import SwiftUI
import UIKit
import PencilKit
import PhotosUI
import Foundation

struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var feedbackType: FeedbackType = .bug
    @State private var screenshot: UIImage?
    @State private var annotatedScreenshot: UIImage?
    @State private var isSubmitting = false
    @State private var showScreenshotEditor = false
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) var dismiss
    
    enum FeedbackType: String, CaseIterable {
        case bug = "Ошибка"
        case feature = "Предложение"
        case improvement = "Улучшение"
        case question = "Вопрос"
        
        var icon: String {
            switch self {
            case .bug: return "ladybug"
            case .feature: return "lightbulb"
            case .improvement: return "wand.and.stars"
            case .question: return "questionmark.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .bug: return .red
            case .feature: return .blue
            case .improvement: return .orange
            case .question: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    // Тип отзыва
                    Section("Тип обращения") {
                        Picker("Тип", selection: $feedbackType) {
                            ForEach(FeedbackType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Текст отзыва
                    Section("Опишите подробно") {
                        TextEditor(text: $feedbackText)
                            .frame(minHeight: 120)
                            .overlay(
                                Group {
                                    if feedbackText.isEmpty {
                                        Text("Расскажите, что произошло...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 8)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    // Скриншот
                    Section("Скриншот") {
                        if let image = annotatedScreenshot ?? screenshot {
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if screenshot != nil {
                                            showScreenshotEditor = true
                                        }
                                    }
                                
                                HStack {
                                    if annotatedScreenshot != nil {
                                        Label("Отредактировано", systemImage: "pencil.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { 
                                        screenshot = nil
                                        annotatedScreenshot = nil
                                    }) {
                                        Label("Удалить", systemImage: "trash")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        } else {
                            Button(action: takeScreenshot) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Сделать скриншот")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Информация об устройстве
                    Section("Информация об устройстве") {
                        InfoRow(label: "Устройство", value: UIDevice.current.model)
                        InfoRow(label: "iOS", value: UIDevice.current.systemVersion)
                        InfoRow(label: "Версия приложения", value: getAppVersion())
                        InfoRow(label: "Сборка", value: getBuildNumber())
                    }
                }
                
                // Кнопка отправки
                VStack {
                    Spacer()
                    
                    Button(action: submitFeedback) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Отправить")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            feedbackText.isEmpty ? Color.gray : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(feedbackText.isEmpty || isSubmitting)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationTitle("Обратная связь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showScreenshotEditor) {
                if let screenshot = screenshot {
                    ScreenshotEditorView(image: screenshot) { editedImage in
                        self.annotatedScreenshot = editedImage
                        self.showScreenshotEditor = false
                    }
                }
            }
            .alert("Успешно отправлено!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Спасибо за ваш отзыв! Мы рассмотрим его в ближайшее время.")
            }
        }
        .onAppear {
            // Автоматический скриншот при открытии
            if screenshot == nil {
                takeScreenshot()
            }
        }
    }
    
    private func takeScreenshot() {
        // Скрываем текущий view перед скриншотом
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
            let image = renderer.image { context in
                window.layer.render(in: context.cgContext)
            }
            
            self.screenshot = image
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        let feedback = FeedbackModel(
            type: feedbackType.rawValue,
            text: feedbackText,
            screenshot: (annotatedScreenshot ?? screenshot)?.pngData()?.base64EncodedString(),
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: getAppVersion(),
                buildNumber: getBuildNumber()
            ),
            timestamp: Date()
        )
        
        FeedbackService.shared.submit(feedback) { success in
            DispatchQueue.main.async {
                isSubmitting = false
                if success {
                    showSuccessAlert = true
                }
            }
        }
    }
    
    private func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private func getBuildNumber() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Shake Gesture Extension
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: NSNotification.Name("deviceDidShake"), object: nil)
        }
    }
} 