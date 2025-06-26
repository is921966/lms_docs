import SwiftUI
import Charts

struct ProfileView: View {
    // TEMPORARY: Use mock service for TestFlight testing
    @StateObject private var authService = MockAuthService.shared
    
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                ProfileHeaderView(user: authService.currentUser)
                
                // Stats cards
                StatsCardsView()
                
                // Quick actions
                QuickActionsView()
                
                // Tab selector
                Picker("", selection: $selectedTab) {
                    Text("Достижения").tag(0)
                    Text("Активность").tag(1)
                    Text("Навыки").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab content
                switch selectedTab {
                case 0:
                    AchievementsView()
                case 1:
                    ActivityView()
                case 2:
                    SkillsView()
                default:
                    EmptyView()
                }
                
                // Settings section
                VStack(spacing: 12) {
                    Text("Настройки")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // Logout button
                    Button(action: {
                        authService.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.body)
                            Text("Выйти из аккаунта")
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    }
                    .padding(.horizontal)
                    
                    // Version info
                    Text("Версия 2.0.1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
                .padding(.bottom, 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.gray.opacity(0.05))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    authService.logout()
                }) {
                    HStack {
                        Text("Выйти")
                            .font(.subheadline)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.subheadline)
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    let user: UserResponse?
    
    var body: some View {
        VStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(initials)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // User info
            if let user = user {
                VStack(spacing: 5) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(user.position ?? "Сотрудник")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(user.department ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Email
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private var initials: String {
        guard let user = user else { return "?" }
        let firstInitial = user.firstName.prefix(1)
        let lastInitial = user.lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Stats Cards
struct StatsCardsView: View {
    var body: some View {
        HStack(spacing: 15) {
            StatCard(
                icon: "book.fill",
                value: "12",
                title: "Курсов",
                color: .blue
            )
            
            StatCard(
                icon: "rosette",
                value: "4",
                title: "Сертификатов",
                color: .green
            )
            
            StatCard(
                icon: "clock.fill",
                value: "48ч",
                title: "Обучения",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: CertificateListView()) {
                QuickActionRow(
                    icon: "seal.fill",
                    title: "Мои сертификаты",
                    count: "4",
                    color: .green
                )
            }
            
            NavigationLink(destination: LearningListView()) {
                QuickActionRow(
                    icon: "book.closed.fill",
                    title: "Активные курсы",
                    count: "3",
                    color: .blue
                )
            }
        }
        .padding(.horizontal)
    }
}

struct QuickActionRow: View {
    let icon: String
    let title: String
    let count: String
    let color: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 5) {
                Text(count)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    let achievements = Achievement.mockAchievements
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Мои достижения")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            if achievement.isUnlocked {
                Text(achievement.date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
}

// MARK: - Activity View
struct ActivityView: View {
    let weeklyData = WeeklyActivity.mockData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Активность за неделю")
                .font(.headline)
                .padding(.horizontal)
            
            // Chart
            Chart(weeklyData) { item in
                BarMark(
                    x: .value("День", item.day),
                    y: .value("Минуты", item.minutes)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
            .padding(.horizontal)
            
            // Activity list
            VStack(alignment: .leading, spacing: 15) {
                Text("Последняя активность")
                    .font(.headline)
                
                ForEach(Activity.mockActivities) { activity in
                    HStack {
                        Image(systemName: activity.icon)
                            .foregroundColor(activity.color)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(activity.title)
                                .font(.subheadline)
                            Text(activity.time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

// MARK: - Skills View
struct SkillsView: View {
    let skills = Skill.mockSkills
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Мои навыки")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(skills) { skill in
                SkillRow(skill: skill)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

struct SkillRow: View {
    let skill: Skill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(skill.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(skill.level * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(skill.color)
                        .frame(width: geometry.size.width * skill.level, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

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

#Preview {
    NavigationView {
        ProfileView()
    }
}
