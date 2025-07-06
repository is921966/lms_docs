import SwiftUI

struct ProfileView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showingEditProfile = false
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader
                
                // Statistics Overview
                statisticsSection
                
                // Tab Selection
                Picker("View", selection: $selectedTab) {
                    Text("Courses").tag(0)
                    Text("Certificates").tag(1)
                    Text("Achievements").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab Content
                switch selectedTab {
                case 0:
                    coursesSection
                case 1:
                    certificatesSection
                case 2:
                    achievementsSection
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditProfile = true
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            Text("Edit Profile View")
        }
    }
    
    // MARK: - Sections
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                if let user = authViewModel.currentUser {
                    Text(user.initials)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // User Info
            if let user = authViewModel.currentUser {
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(user.email)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: roleIcon(for: user.role))
                            .font(.caption)
                        Text(roleTitle(for: user.role))
                            .font(.caption)
                    }
                    .foregroundColor(roleColor(for: user.role))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(roleColor(for: user.role).opacity(0.2))
                    .cornerRadius(12)
                }
            }
            
            // Member Since
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text("Member since January 2023")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var statisticsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatisticCard(
                title: "Courses",
                value: "12",
                subtitle: "Enrolled",
                icon: "book.fill",
                color: .blue
            )
            
            StatisticCard(
                title: "Completed",
                value: "8",
                subtitle: "Courses",
                icon: "checkmark.seal.fill",
                color: .green
            )
            
            StatisticCard(
                title: "Certificates",
                value: "6",
                subtitle: "Earned",
                icon: "medal.fill",
                color: .orange
            )
            
            StatisticCard(
                title: "Learning Time",
                value: "156",
                subtitle: "Hours",
                icon: "clock.fill",
                color: .purple
            )
        }
        .padding(.horizontal)
    }
    
    private var coursesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // In Progress
            VStack(alignment: .leading, spacing: 12) {
                Text("In Progress")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(0..<2) { _ in
                    ProgressCourseCard()
                        .padding(.horizontal)
                }
            }
            
            // Completed
            VStack(alignment: .leading, spacing: 12) {
                Text("Completed")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                
                ForEach(0..<3) { _ in
                    CompletedCourseCard()
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
    
    private var certificatesSection: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { _ in
                CertificateCard()
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var achievementsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(achievements) { achievement in
                AchievementBadge(achievement: achievement)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func roleIcon(for role: User.Role) -> String {
        switch role {
        case .student: return "graduationcap"
        case .instructor: return "person.fill"
        case .admin: return "shield.fill"
        case .superAdmin: return "star.fill"
        }
    }
    
    private func roleTitle(for role: User.Role) -> String {
        switch role {
        case .student: return "Student"
        case .instructor: return "Instructor"
        case .admin: return "Administrator"
        case .superAdmin: return "Super Administrator"
        }
    }
    
    private func roleColor(for role: User.Role) -> Color {
        switch role {
        case .student: return .blue
        case .instructor: return .green
        case .admin: return .purple
        case .superAdmin: return .red
        }
    }
    
    // Sample data
    private let achievements = [
        Achievement(id: UUID(), title: "First Steps", icon: "shoe.2.fill", isUnlocked: true),
        Achievement(id: UUID(), title: "Quick Learner", icon: "bolt.fill", isUnlocked: true),
        Achievement(id: UUID(), title: "Dedicated", icon: "flame.fill", isUnlocked: true),
        Achievement(id: UUID(), title: "Expert", icon: "star.fill", isUnlocked: false),
        Achievement(id: UUID(), title: "Master", icon: "crown.fill", isUnlocked: false),
        Achievement(id: UUID(), title: "Legend", icon: "trophy.fill", isUnlocked: false)
    ]
}

// MARK: - Supporting Views

struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ProgressCourseCard: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "swift")
                        .font(.title2)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("iOS Development")
                    .font(.headline)
                Text("65% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: 0.65)
                    .tint(.blue)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CompletedCourseCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Web Development Basics")
                    .font(.headline)
                Text("Completed on Dec 15, 2023")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("4.8")
                        .font(.caption)
                }
                Text("View Certificate")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CertificateCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "seal.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("Verified")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Text("Certificate of Completion")
                .font(.headline)
            
            Text("iOS Development with SwiftUI")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("Dec 20, 2023", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("View") {
                    // Show certificate
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct Achievement: Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let isUnlocked: Bool
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            }
            
            Text(achievement.title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
        }
    }
} 