//
//  LMSApp+ReleaseNews.swift
//  LMS
//
//  Интеграция автоматических новостей о релизах
//

import SwiftUI

extension LMSApp {
    /// Инициализация сервиса новостей о релизах
    func setupReleaseNewsService() {
        let releaseService = ReleaseNewsService.shared
        
        // Проверяем и публикуем новость при запуске
        releaseService.checkAndPublishOnAppLaunch()
        
        // Подписываемся на уведомления о новых релизах
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NewReleaseAvailable"),
            object: nil,
            queue: .main
        ) { notification in
            if let userInfo = notification.userInfo,
               let version = userInfo["version"] as? String,
               let build = userInfo["build"] as? String {
                
                // Показываем in-app уведомление
                showReleaseAlert(version: version, build: build)
            }
        }
    }
    
    /// Показать алерт о новой версии
    private func showReleaseAlert(version: String, build: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "🎉 Новая версия!",
            message: "Доступна версия \(version) (Build \(build)). Проверьте ленту новостей для подробной информации.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Посмотреть", style: .default) { _ in
            // Переход к ленте новостей
            NotificationCenter.default.post(
                name: NSNotification.Name("NavigateToFeed"),
                object: nil
            )
        })
        
        alert.addAction(UIAlertAction(title: "Позже", style: .cancel))
        
        rootViewController.present(alert, animated: true)
    }
}

// MARK: - Debug Menu Extension

#if DEBUG
extension DebugMenuView {
    /// Секция для тестирования новостей о релизах
    var releaseNewsSection: some View {
        Section("Release News Testing") {
            Button("Simulate New Release") {
                simulateNewRelease()
            }
            
            Button("Clear Release History") {
                clearReleaseHistory()
            }
            
            Button("Show Current Version") {
                showCurrentVersion()
            }
        }
    }
    
    private func simulateNewRelease() {
        let releaseService = ReleaseNewsService.shared
        
        // Очищаем историю
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedAppVersion")
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedBuildNumber")
        
        // Проверяем снова
        releaseService.checkForNewRelease()
        
        // Публикуем новость
        Task {
            await releaseService.publishReleaseNews()
        }
    }
    
    private func clearReleaseHistory() {
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedAppVersion")
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedBuildNumber")
        UserDefaults.standard.removeObject(forKey: "currentReleaseNotes")
        
        print("Release history cleared")
    }
    
    private func showCurrentVersion() {
        let releaseService = ReleaseNewsService.shared
        print("Version: \(releaseService.currentAppVersion)")
        print("Build: \(releaseService.currentBuildNumber)")
        print("Has new release: \(releaseService.hasNewRelease)")
    }
}
#endif

// MARK: - Feed Integration

extension FeedView {
    /// Проверить наличие новостей о релизе при открытии ленты
    func checkForReleaseNews() {
        let releaseService = ReleaseNewsService.shared
        
        if releaseService.hasNewRelease {
            // Новость будет автоматически добавлена при запуске
            // Но можно форсировать если пользователь открыл ленту раньше
            Task {
                await releaseService.publishReleaseNews()
            }
        }
    }
}

// MARK: - Settings Integration

extension SettingsView {
    /// Секция с информацией о версии
    var versionSection: some View {
        Section("О приложении") {
            HStack {
                Text("Версия")
                Spacer()
                Text("\(ReleaseNewsService.shared.currentAppVersion) (\(ReleaseNewsService.shared.currentBuildNumber))")
                    .foregroundColor(.secondary)
            }
            
            Button("Что нового") {
                showReleaseNotes()
            }
        }
    }
    
    private func showReleaseNotes() {
        let notes = ReleaseNewsService.shared.getCurrentReleaseNotes()
        
        // Можно показать в модальном окне или перейти к новости в ленте
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowReleaseNotes"),
            object: nil,
            userInfo: ["notes": notes]
        )
    }
} 