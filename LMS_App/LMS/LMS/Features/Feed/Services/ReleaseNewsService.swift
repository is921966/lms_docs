//
//  ReleaseNewsService.swift
//  LMS
//
//  Сервис для управления новостями о релизах приложения
//

import SwiftUI

@MainActor
class ReleaseNewsService: ObservableObject {
    static let shared = ReleaseNewsService()
    
    // MARK: - Properties
    
    @Published var hasNewRelease: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let lastVersionKey = "lastAnnouncedAppVersion"
    private let lastBuildKey = "lastAnnouncedBuildNumber"
    private let releaseNotesKey = "currentReleaseNotes"
    
    // Current app info
    var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var currentBuildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Initialization
    
    private init() {
        checkForNewRelease()
    }
    
    // MARK: - Public Methods
    
    /// Проверить наличие новой версии
    func checkForNewRelease() {
        let lastVersion = userDefaults.string(forKey: lastVersionKey)
        let lastBuild = userDefaults.string(forKey: lastBuildKey)
        
        hasNewRelease = (lastVersion != currentAppVersion || lastBuild != currentBuildNumber)
    }
    
    /// Опубликовать новость о релизе в ленте
    func publishReleaseNews(releaseNotes: String? = nil) async {
        guard hasNewRelease else { return }
        
        // Получаем или создаем release notes
        let notes = releaseNotes ?? getCurrentReleaseNotes()
        
        // Сохраняем release notes
        userDefaults.set(notes, forKey: releaseNotesKey)
        
        // Создаем новость из release notes
        let releaseNews = BuildReleaseNews.fromReleaseNotes(
            version: currentAppVersion,
            buildNumber: currentBuildNumber,
            releaseNotesContent: notes
        )
        
        // Преобразуем в FeedItem
        let feedItem = releaseNews.toFeedItem()
        
        // Добавляем в ленту через FeedService
        await FeedService.shared.addNewsItem(feedItem)
        
        // Обновляем сохраненные версии
        userDefaults.set(currentAppVersion, forKey: lastVersionKey)
        userDefaults.set(currentBuildNumber, forKey: lastBuildKey)
        
        // Сбрасываем флаг
        hasNewRelease = false
        
        // Отправляем уведомление
        sendNewReleaseNotification()
    }
    
    /// Получить текущие release notes
    func getCurrentReleaseNotes() -> String {
        if let saved = userDefaults.string(forKey: releaseNotesKey) {
            return saved
        }
        
        // Пытаемся загрузить из файла
        if let bundlePath = Bundle.main.path(forResource: "RELEASE_NOTES", ofType: "md"),
           let content = try? String(contentsOfFile: bundlePath) {
            return content
        }
        
        // Возвращаем дефолтные release notes
        return generateDefaultReleaseNotes()
    }
    
    /// Проверить и опубликовать при запуске приложения
    func checkAndPublishOnAppLaunch() {
        checkForNewRelease()
        
        if hasNewRelease {
            // Публикуем с задержкой, чтобы UI успел загрузиться
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды
                await publishReleaseNews()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func generateDefaultReleaseNotes() -> String {
        """
        <div style="font-family: -apple-system, system-ui; padding: 10px;">
            <h1 style="font-size: 24px; margin-bottom: 15px;">
                TestFlight Release v\(currentAppVersion)
            </h1>
            
            <p style="font-size: 18px; color: #666; margin-bottom: 20px;">
                <strong>Build:</strong> \(currentBuildNumber)
            </p>
            
            <div style="margin-top: 20px;">
                <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                    🎯 Основные изменения
                </h2>
                
                <div style="margin-top: 15px;">
                    <h3 style="font-size: 18px; color: #333; margin-bottom: 8px;">
                        ✨ Новые функции
                    </h3>
                    <ul style="margin: 0; padding-left: 20px;">
                        <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Обновленный интерфейс</li>
                        <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Улучшенная производительность</li>
                        <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Исправлены ошибки</li>
                    </ul>
                </div>
            </div>
            
            <div style="margin-top: 20px;">
                <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                    📋 Что нового для тестировщиков
                </h2>
                
                <h3 style="font-size: 18px; color: #333; margin-bottom: 8px;">
                    Проверьте следующие функции:
                </h3>
                <ul style="margin: 0; padding-left: 20px;">
                    <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Общая стабильность приложения</li>
                    <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Корректность отображения данных</li>
                    <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Скорость загрузки</li>
                </ul>
            </div>
            
            <div style="margin-top: 20px;">
                <h2 style="font-size: 20px; color: #FF6B6B; margin-bottom: 10px;">
                    🐛 Известные проблемы
                </h2>
                <ul style="margin: 0; padding-left: 20px;">
                    <li style="margin-bottom: 5px; color: #FF6B6B; line-height: 1.5;">Продолжаем работу над оптимизацией</li>
                </ul>
            </div>
            
            <hr style="margin: 25px 0; border: none; border-top: 1px solid #e0e0e0;">
            
            <p style="text-align: center; color: #666; font-size: 16px; margin-top: 20px;">
                Спасибо за участие в тестировании! 🙏
            </p>
        </div>
        """
    }
    
    private func sendNewReleaseNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name("NewReleaseAvailable"),
            object: nil,
            userInfo: [
                "version": currentAppVersion,
                "build": currentBuildNumber
            ]
        )
    }
    
    // MARK: - Helper Methods for Testing
    
    func loadReleaseNotesFromFile(path: String) async -> String? {
        return await Task {
            try? String(contentsOfFile: path)
        }.value
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ReleaseNewsService {
    /// Сбросить сохраненную версию для тестирования
    func resetForTesting() {
        userDefaults.removeObject(forKey: lastVersionKey)
        userDefaults.removeObject(forKey: lastBuildKey)
        userDefaults.removeObject(forKey: releaseNotesKey)
        checkForNewRelease()
    }
    
    /// Установить кастомные release notes для тестирования
    func setTestReleaseNotes(_ notes: String) {
        userDefaults.set(notes, forKey: releaseNotesKey)
    }
}
#endif 