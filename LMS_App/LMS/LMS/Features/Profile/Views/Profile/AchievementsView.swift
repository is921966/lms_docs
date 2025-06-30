import SwiftUI

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
