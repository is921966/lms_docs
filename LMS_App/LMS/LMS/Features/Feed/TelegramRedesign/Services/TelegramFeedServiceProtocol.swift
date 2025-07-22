//
//  TelegramFeedServiceProtocol.swift
//  LMS
//
//  Sprint 50 - Протокол сервиса для работы с лентой новостей
//

import Foundation

/// Протокол для сервиса работы с лентой новостей
protocol TelegramFeedServiceProtocol {
    /// Загрузить список каналов
    func loadChannels() async throws -> [FeedChannel]
    
    /// Отметить канал как прочитанный
    func markAsRead(channelId: UUID) async throws
    
    /// Создать демо-каналы для тестирования

} 