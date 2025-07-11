//
//  FeedError.swift
//  LMS
//
//  Ошибки для модуля Feed
//

import Foundation

enum FeedError: Error, LocalizedError {
    case noPermission
    case postNotFound
    case commentNotFound
    case networkError(Error)
    case invalidData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .noPermission:
            return "У вас нет прав для выполнения этого действия"
        case .postNotFound:
            return "Запись не найдена"
        case .commentNotFound:
            return "Комментарий не найден"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .invalidData:
            return "Неверный формат данных"
        case .unauthorized:
            return "Необходима авторизация"
        }
    }
} 