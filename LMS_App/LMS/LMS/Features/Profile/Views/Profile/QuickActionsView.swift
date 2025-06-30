import SwiftUI

struct QuickActionsView: View {
    @StateObject private var onboardingService = OnboardingMockService.shared
    @StateObject private var authService = MockAuthService.shared

    var userOnboardingPrograms: [OnboardingProgram] {
        guard let userIdString = authService.currentUser?.id,
              let userId = UUID(uuidString: userIdString) else { return [] }
        return onboardingService.getPrograms().filter { $0.employeeId == userId }
    }

    var activeOnboardingCount: Int {
        userOnboardingPrograms.filter { $0.status == .inProgress }.count
    }

    var body: some View {
        VStack(spacing: 12) {
            // Onboarding programs (if any)
            if !userOnboardingPrograms.isEmpty {
                NavigationLink(destination: MyOnboardingProgramsView()) {
                    QuickActionRow(
                        icon: "person.badge.clock",
                        title: "Программа адаптации",
                        count: "\(activeOnboardingCount)",
                        color: .purple
                    )
                }
            }

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
