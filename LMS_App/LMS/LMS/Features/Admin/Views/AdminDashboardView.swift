//
//  AdminDashboardView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingNotifications = false
    @State private var showingPendingUsers = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Панель администратора")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if let userName = authViewModel.currentUser?.firstName {
                        Text("Добро пожаловать, \(userName)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Pending approvals alert
                if notificationService.pendingApprovals > 0 {
                    Button(action: {
                        showingPendingUsers = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.clock")
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ожидают одобрения")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(notificationService.pendingApprovals) новых пользователей")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                // System statistics
                SystemStatsSection()

                // Quick actions
                QuickActionsSection()

                // Recent activity
                RecentActivitySection()

                // System health
                SystemHealthSection()

                Spacer(minLength: 100)
            }
            .padding(.vertical)
        }
        .navigationTitle("Главная")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingNotifications = true
                }) {
                    ZStack {
                        Image(systemName: "bell")
                            .font(.system(size: 20))

                        if notificationService.unreadCount > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text("\(notificationService.unreadCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationListView()
        }
        .sheet(isPresented: $showingPendingUsers) {
            NavigationView {
                PendingUsersView()
            }
        }
    }
}

// MARK: - System Stats Section
struct SystemStatsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика системы")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AdminStatCard(
                    icon: "person.3.fill",
                    title: "Пользователи",
                    value: "1,234",
                    change: "+12%",
                    color: .blue
                )

                AdminStatCard(
                    icon: "book.fill",
                    title: "Курсы",
                    value: "156",
                    change: "+8%",
                    color: .green
                )

                AdminStatCard(
                    icon: "doc.text.magnifyingglass",
                    title: "Тесты",
                    value: "423",
                    change: "+15%",
                    color: .orange
                )

                AdminStatCard(
                    icon: "seal.fill",
                    title: "Сертификаты",
                    value: "892",
                    change: "+23%",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Быстрые действия")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionCard(
                        icon: "person.badge.plus",
                        title: "Добавить пользователя",
                        color: .blue,
                        destination: AnyView(Text("Add User View"))
                    )

                    QuickActionCard(
                        icon: "book.badge.plus",
                        title: "Создать курс",
                        color: .green,
                        destination: AnyView(CourseAddView { _ in })
                    )

                    QuickActionCard(
                        icon: "doc.badge.plus",
                        title: "Создать тест",
                        color: .orange,
                        destination: AnyView(TestAddView { _ in })
                    )

                    QuickActionCard(
                        icon: "chart.bar.doc.horizontal",
                        title: "Отчеты",
                        color: .purple,
                        destination: AnyView(ReportsListView())
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Recent Activity Section
struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Последняя активность")
                    .font(.headline)

                Spacer()

                NavigationLink(destination: AdminActivityLogView()) {
                    Text("Все")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                AdminActivityRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Новый пользователь зарегистрирован",
                    subtitle: "Иван Петров • 5 минут назад",
                    color: .blue
                )

                AdminActivityRow(
                    icon: "book.closed.fill",
                    title: "Курс завершен",
                    subtitle: "iOS Development • 156 студентов • 1 час назад",
                    color: .green
                )

                AdminActivityRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Тест провален",
                    subtitle: "Advanced SwiftUI • 23% прошли • 2 часа назад",
                    color: .red
                )

                AdminActivityRow(
                    icon: "seal.fill",
                    title: "Выдан сертификат",
                    subtitle: "Mobile Development • Мария Иванова • 3 часа назад",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - System Health Section
struct SystemHealthSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Состояние системы")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                SystemHealthRow(
                    title: "Сервер API",
                    status: .operational,
                    responseTime: "45ms"
                )

                SystemHealthRow(
                    title: "База данных",
                    status: .operational,
                    responseTime: "12ms"
                )

                SystemHealthRow(
                    title: "Хранилище файлов",
                    status: .operational,
                    responseTime: "156ms"
                )

                SystemHealthRow(
                    title: "Email сервис",
                    status: .degraded,
                    responseTime: "2.3s"
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Helper Views
struct AdminStatCard: View {
    let icon: String
    let title: String
    let value: String
    let change: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                Text(change)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .cornerRadius(15)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
            .padding(.vertical, 8)
        }
    }
}

struct AdminActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

enum SystemStatus {
    case operational
    case degraded
    case down

    var color: Color {
        switch self {
        case .operational: return .green
        case .degraded: return .orange
        case .down: return .red
        }
    }

    var icon: String {
        switch self {
        case .operational: return "checkmark.circle.fill"
        case .degraded: return "exclamationmark.triangle.fill"
        case .down: return "xmark.circle.fill"
        }
    }
}

struct SystemHealthRow: View {
    let title: String
    let status: SystemStatus
    let responseTime: String

    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .foregroundColor(status.color)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text(responseTime)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Placeholder Views
struct AdminActivityLogView: View {
    var body: some View {
        Text("Activity Log")
            .navigationTitle("Журнал активности")
    }
}

#Preview {
    NavigationView {
        AdminDashboardView()
            .environmentObject(AuthViewModel())
    }
}
