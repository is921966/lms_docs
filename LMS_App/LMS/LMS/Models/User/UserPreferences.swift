//
//  UserPreferences.swift
//  LMS
//

import Foundation

public struct UserPreferences: Codable {
    public var language: String = "ru"
    public var theme: String = "light"
    public var notifications: Bool = true
    
    public init() {}
}
