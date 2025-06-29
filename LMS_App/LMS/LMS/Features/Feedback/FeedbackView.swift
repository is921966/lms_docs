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
    
    // Получаем скриншот из FeedbackManager
    @StateObject private var feedbackManager = FeedbackManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    // Тип отзыва
                    Section("Тип обращения") {
                        Picker("Тип", selection: $feedbackType) {
                            ForEach(FeedbackType.allCases, id: \.self) { type in
                                Label(type.title, systemImage: type.icon)
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
                        if let image = annotatedScreenshot ?? screenshot ?? feedbackManager.screenshot {
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if screenshot != nil || feedbackManager.screenshot != nil {
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
                                        feedbackManager.screenshot = nil
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
                if let image = screenshot ?? feedbackManager.screenshot {
                    ScreenshotEditorView(image: image) { editedImage in
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
            // Используем скриншот из FeedbackManager, если он есть
            if let managerScreenshot = feedbackManager.screenshot {
                self.screenshot = managerScreenshot
            }
        }
    }
    
    private func takeScreenshot() {
        // Делаем новый скриншот текущего состояния
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { context in
            window.layer.render(in: context.cgContext)
        }
        
        self.screenshot = image
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        let finalScreenshot = annotatedScreenshot ?? screenshot ?? feedbackManager.screenshot
        
        let feedback = FeedbackModel(
            type: feedbackType.rawValue,
            text: feedbackText,
            screenshot: finalScreenshot?.pngData()?.base64EncodedString(),
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: getAppVersion(),
                buildNumber: getBuildNumber(),
                locale: Locale.current.identifier,
                screenSize: "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))"
            ),
            timestamp: Date()
        )
        
        Task {
            let success = await FeedbackService.shared.createFeedback(feedback)
            await MainActor.run {
                isSubmitting = false
                if success {
                    showSuccessAlert = true
                    // Очищаем скриншот в FeedbackManager после отправки
                    feedbackManager.screenshot = nil
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