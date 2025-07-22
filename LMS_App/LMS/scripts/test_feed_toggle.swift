#!/usr/bin/env swift

import Foundation

// Функция для получения UserDefaults приложения
func getAppUserDefaults() -> UserDefaults? {
    // Путь к симулятору может варьироваться
    let appBundleId = "com.yourcompany.LMS" // Замените на актуальный bundle ID
    return UserDefaults(suiteName: appBundleId) ?? UserDefaults.standard
}

// Проверка текущего состояния
let defaults = UserDefaults.standard
let currentValue = defaults.bool(forKey: "useNewFeedDesign")

print("📊 UserDefaults Test Script")
print("========================")
print("Current value of 'useNewFeedDesign': \(currentValue)")

// Попробуем изменить значение
print("\n🔄 Testing toggle...")
defaults.set(!currentValue, forKey: "useNewFeedDesign")
defaults.synchronize()

let newValue = defaults.bool(forKey: "useNewFeedDesign")
print("New value: \(newValue)")

// Вернем обратно
defaults.set(currentValue, forKey: "useNewFeedDesign")
defaults.synchronize()

print("\n✅ Test completed. Value restored to: \(defaults.bool(forKey: "useNewFeedDesign"))")

// Проверка всех ключей
print("\n📋 All UserDefaults keys:")
let allKeys = defaults.dictionaryRepresentation().keys.sorted()
for key in allKeys {
    if key.contains("Feed") || key.contains("feed") || key.contains("Design") || key.contains("design") {
        let value = defaults.object(forKey: key) ?? "nil"
        print("  - \(key): \(value)")
    }
} 