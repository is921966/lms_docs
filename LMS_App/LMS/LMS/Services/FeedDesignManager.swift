import SwiftUI
import Combine

/// Глобальный менеджер для управления дизайном ленты
class FeedDesignManager: ObservableObject {
    static let shared = FeedDesignManager()
    
    static let feedDesignChangedNotification = Foundation.Notification.Name("feedDesignChanged")
    
    @Published var useNewDesign: Bool {
        didSet {
            print("🎯 FeedDesignManager: useNewDesign changed to \(useNewDesign)")
            ComprehensiveLogger.shared.log(.ui, .info, "Feed design changed", details: [
                "oldValue": oldValue,
                "newValue": useNewDesign,
                "source": "direct"
            ])
            
            UserDefaults.standard.set(useNewDesign, forKey: "useNewFeedDesign")
            UserDefaults.standard.synchronize()
            
            // Отправляем уведомление для обновления всех view
            NotificationCenter.default.post(
                name: FeedDesignManager.feedDesignChangedNotification,
                object: nil,
                userInfo: ["useNewDesign": useNewDesign]
            )
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // По умолчанию используем новый дизайн для TestFlight
        #if DEBUG
        // В debug режиме проверяем сохраненное значение
        let savedValue = UserDefaults.standard.object(forKey: "useNewFeedDesign") as? Bool
        self.useNewDesign = savedValue ?? false // По умолчанию false (классическая лента)
        #else
        // В release (TestFlight) всегда используем новый дизайн
        self.useNewDesign = true
        UserDefaults.standard.set(true, forKey: "useNewFeedDesign")
        #endif
        
        print("🎯 FeedDesignManager init: useNewDesign = \(useNewDesign)")
        ComprehensiveLogger.shared.log(.ui, .info, "FeedDesignManager initialized", details: [
            "useNewDesign": useNewDesign,
            "isDebug": true
        ])
        
        // Слушаем изменения UserDefaults
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let newValue = UserDefaults.standard.bool(forKey: "useNewFeedDesign")
                if self?.useNewDesign != newValue {
                    print("🎯 FeedDesignManager: detected external change to \(newValue)")
                    ComprehensiveLogger.shared.log(.ui, .info, "Feed design external change detected", details: [
                        "currentValue": self?.useNewDesign ?? false,
                        "newValue": newValue,
                        "source": "UserDefaults"
                    ])
                    // Обновляем значение
                    self?.useNewDesign = newValue
                    // Отправляем уведомление об изменении
                    NotificationCenter.default.post(name: FeedDesignManager.feedDesignChangedNotification, object: nil)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Переключить дизайн ленты
    func toggleDesign() {
        print("🎯 FeedDesignManager: toggle called")
        ComprehensiveLogger.shared.log(.ui, .info, "Feed design toggle called", details: [
            "beforeToggle": useNewDesign
        ])
        useNewDesign.toggle()
    }
    
    /// Установить конкретное значение
    func setDesign(_ useNew: Bool) {
        print("🎯 FeedDesignManager: setDesign(\(useNew))")
        UserDefaults.standard.set(useNew, forKey: "useNewFeedDesign")
        UserDefaults.standard.synchronize()
        self.useNewDesign = useNew
        
        // Уведомляем об изменении
        NotificationCenter.default.post(name: FeedDesignManager.feedDesignChangedNotification, object: nil)
        
        print("🎯 FeedDesignManager: useNewDesign changed to \(useNewDesign)")
        ComprehensiveLogger.shared.log(.ui, .info, "Feed design changed", details: [
            "newValue": useNew,
            "source": "Manual"
        ])
    }
    
    func forceRefresh() {
        let currentValue = UserDefaults.standard.bool(forKey: "useNewFeedDesign")
        if currentValue != useNewDesign {
            print("🔄 FeedDesignManager: forceRefresh detected mismatch - updating from \(useNewDesign) to \(currentValue)")
            self.useNewDesign = currentValue
            NotificationCenter.default.post(name: FeedDesignManager.feedDesignChangedNotification, object: nil)
        }
    }
    
    /// Сбросить на значение по умолчанию
    func resetToDefault() {
        #if DEBUG
        setDesign(true) // В debug режиме по умолчанию новый дизайн
        #else
        setDesign(true) // В release всегда новый дизайн
        #endif
    }
} 