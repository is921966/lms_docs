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
        # TestFlight Release v\(currentAppVersion)
        
        **Build**: \(currentBuildNumber)
        
        ## 🎯 Основные изменения
        
        ### ✨ Новые функции
        - Обновленный интерфейс
        - Улучшенная производительность
        - Исправлены ошибки
        
        ## 📋 Что нового для тестировщиков
        
        ### Проверьте следующие функции:
        - Общая стабильность приложения
        - Корректность отображения данных
        - Скорость загрузки
        
        ## 🐛 Известные проблемы
        - Продолжаем работу над оптимизацией
        
        ---
        
        Спасибо за участие в тестировании! 🙏
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