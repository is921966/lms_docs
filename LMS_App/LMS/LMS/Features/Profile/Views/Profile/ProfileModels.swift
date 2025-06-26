import SwiftUI

// MARK: - Models
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    let date: String
    
    static let mockAchievements = [
        Achievement(title: "Первый курс", icon: "star.fill", color: .yellow, isUnlocked: true, date: "15.06.2025"),
        Achievement(title: "Отличник", icon: "graduationcap.fill", color: .blue, isUnlocked: true, date: "20.06.2025"),
        Achievement(title: "Быстрый старт", icon: "hare.fill", color: .green, isUnlocked: true, date: "16.06.2025"),
        Achievement(title: "Марафонец", icon: "figure.run", color: .orange, isUnlocked: false, date: ""),
        Achievement(title: "Эксперт", icon: "crown.fill", color: .purple, isUnlocked: false, date: ""),
        Achievement(title: "Наставник", icon: "person.2.fill", color: .red, isUnlocked: false, date: "")
    ]
}

struct WeeklyActivity: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
    
    static let mockData = [
        WeeklyActivity(day: "Пн", minutes: 45),
        WeeklyActivity(day: "Вт", minutes: 60),
        WeeklyActivity(day: "Ср", minutes: 30),
        WeeklyActivity(day: "Чт", minutes: 90),
        WeeklyActivity(day: "Пт", minutes: 120),
        WeeklyActivity(day: "Сб", minutes: 15),
        WeeklyActivity(day: "Вс", minutes: 75)
    ]
}

struct Activity: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    static let mockActivities = [
        Activity(title: "Завершен модуль \"Работа с возражениями\"", time: "2 часа назад", icon: "checkmark.circle.fill", color: .green),
        Activity(title: "Начат курс \"Визуальный мерчандайзинг\"", time: "Вчера", icon: "play.circle.fill", color: .blue),
        Activity(title: "Получен сертификат по курсу \"Работа с кассой\"", time: "3 дня назад", icon: "rosette", color: .orange),
        Activity(title: "Пройден тест по модулю \"Типы клиентов\"", time: "Неделю назад", icon: "doc.text.fill", color: .purple)
    ]
}

struct Skill: Identifiable {
    let id = UUID()
    let name: String
    let level: Double
    let color: Color
    
    static let mockSkills = [
        Skill(name: "Продажи", level: 0.85, color: .blue),
        Skill(name: "Клиентский сервис", level: 0.92, color: .green),
        Skill(name: "Работа с кассой", level: 1.0, color: .orange),
        Skill(name: "Визуальный мерчандайзинг", level: 0.45, color: .purple),
        Skill(name: "Товароведение", level: 0.68, color: .red)
    ]
}
