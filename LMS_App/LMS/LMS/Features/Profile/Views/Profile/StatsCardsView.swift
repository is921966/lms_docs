import SwiftUI

struct StatsCardsView: View {
    @StateObject private var onboardingService = OnboardingMockService.shared
    @StateObject private var authService = MockAuthService.shared
    
    var userOnboardingProgress: Int {
        guard let userIdString = authService.currentUser?.id,
              let userId = UUID(uuidString: userIdString) else { return 0 }
        let programs = onboardingService.getPrograms().filter { $0.employeeId == userId && $0.status == .inProgress }
        guard !programs.isEmpty else { return 0 }
        let totalProgress = programs.reduce(0) { $0 + $1.overallProgress }
        return Int((totalProgress / Double(programs.count)) * 100)
    }
    
    var hasActiveOnboarding: Bool {
        guard let userIdString = authService.currentUser?.id,
              let userId = UUID(uuidString: userIdString) else { return false }
        return !onboardingService.getPrograms().filter { $0.employeeId == userId && $0.status == .inProgress }.isEmpty
    }
    
    var body: some View {
        HStack(spacing: 15) {
            if hasActiveOnboarding {
                ProfileStatCard(
                    icon: "person.badge.clock",
                    value: "\(userOnboardingProgress)%",
                    title: "Онбординг",
                    color: .purple
                )
            }
            
            ProfileStatCard(
                icon: "book.fill",
                value: "12",
                title: "Курсов",
                color: .blue
            )
            
            ProfileStatCard(
                icon: "rosette",
                value: "4",
                title: "Сертификатов",
                color: .green
            )
            
            if !hasActiveOnboarding {
                ProfileStatCard(
                    icon: "clock.fill",
                    value: "48ч",
                    title: "Обучения",
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
    }
}
