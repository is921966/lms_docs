//
//  RoleManagementViewModel.swift
//  LMS
//
//  Created on 27/01/2025.
//

import Foundation
import SwiftUI

class RoleManagementViewModel: ObservableObject {
    @Published var roles: [Role] = []
    @Published var roleStatistics: [RoleStatistic] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        loadRoles()
        loadRoleStatistics()
    }

    func loadRoles() {
        isLoading = true

        // In real app this would be an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.roles = [
                Role(
                    name: "Студент",
                    permissions: [
                        "Просмотр курсов",
                        "Прохождение тестов",
                        "Просмотр результатов",
                        "Скачивание сертификатов"
                    ],
                    usersCount: 1_234
                ),
                Role(
                    name: "Преподаватель",
                    permissions: [
                        "Создание курсов",
                        "Создание тестов",
                        "Просмотр статистики",
                        "Выдача сертификатов",
                        "Оценка студентов"
                    ],
                    usersCount: 45
                ),
                Role(
                    name: "Администратор",
                    permissions: [
                        "Управление пользователями",
                        "Управление ролями",
                        "Системные настройки",
                        "Полный доступ к контенту",
                        "Просмотр всей статистики"
                    ],
                    usersCount: 5
                ),
                Role(
                    name: "Супер администратор",
                    permissions: [
                        "Полный доступ",
                        "Управление администраторами",
                        "Удаление системных данных",
                        "Настройка интеграций",
                        "Доступ к логам"
                    ],
                    usersCount: 2
                )
            ]
            self?.isLoading = false
        }
    }

    func loadRoleStatistics() {
        // In real app this would be calculated from user data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.roleStatistics = [
                RoleStatistic(roleName: "Студенты", count: 1_234),
                RoleStatistic(roleName: "Преподаватели", count: 45),
                RoleStatistic(roleName: "Администраторы", count: 7)
            ]
        }
    }

    func updateRolePermissions(_ role: Role, permissions: [String]) {
        if let index = roles.firstIndex(where: { $0.id == role.id }) {
            var updatedRole = roles[index]
            updatedRole.permissions = permissions
            roles[index] = updatedRole
        }
    }

    func createRole(name: String, permissions: [String]) {
        let newRole = Role(
            name: name,
            permissions: permissions,
            usersCount: 0
        )
        roles.append(newRole)
    }

    func deleteRole(_ role: Role) {
        roles.removeAll { $0.id == role.id }
    }
}
