import Charts
import SwiftUI

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

                    // Quick settings section
                    QuickSettingsSection()
                        .environmentObject(authService)

                    // Logout button
                    Button(action: {
                        Task {
                            try await authService.logout()
                        }
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
                    Text("Версия \(Bundle.main.appVersion)")
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
                    Task {
                        try await authService.logout()
                    }
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

#Preview {
    NavigationView {
        ProfileView()
    }
}
