import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // Profile Section
            profileSection
            
            // Admin Section (if applicable)
            if viewModel.isAdmin {
                adminSection
            }
            
            // Notifications Section
            notificationsSection
            
            // App Settings Section
            appSettingsSection
            
            // Support Section
            supportSection
            
            // Account Section
            accountSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Logout", isPresented: $viewModel.showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $viewModel.showingDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                }
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .loadingOverlay(isLoading: viewModel.isLoading)
    }
    
    // MARK: - Sections
    
    private var profileSection: some View {
        Section {
            if let user = viewModel.currentUser {
                HStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                        
                        Text(user.initials)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // User Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: roleIcon(for: user.role))
                                .font(.caption2)
                            Text(roleTitle(for: user.role))
                                .font(.caption2)
                        }
                        .foregroundColor(roleColor(for: user.role))
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var adminSection: some View {
        Section("Admin") {
            Toggle(isOn: $viewModel.isAdminMode) {
                Label("Admin Mode", systemImage: "shield.fill")
            }
            .tint(.purple)
            
            NavigationLink(destination: Text("Admin Dashboard")) {
                Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
            }
            
            NavigationLink(destination: Text("System Settings")) {
                Label("System Settings", systemImage: "server.rack")
            }
        }
    }
    
    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle(isOn: $viewModel.pushNotificationsEnabled) {
                Label("Push Notifications", systemImage: "bell.fill")
            }
            .onChange(of: viewModel.pushNotificationsEnabled) { _ in
                Task { await viewModel.updateNotificationSettings() }
            }
            
            Toggle(isOn: $viewModel.emailNotificationsEnabled) {
                Label("Email Notifications", systemImage: "envelope.fill")
            }
            .onChange(of: viewModel.emailNotificationsEnabled) { _ in
                Task { await viewModel.updateNotificationSettings() }
            }
            
            Toggle(isOn: $viewModel.courseUpdatesEnabled) {
                Label("Course Updates", systemImage: "book.circle")
            }
            .onChange(of: viewModel.courseUpdatesEnabled) { _ in
                Task { await viewModel.updateNotificationSettings() }
            }
            
            Toggle(isOn: $viewModel.gradeNotificationsEnabled) {
                Label("Grade Notifications", systemImage: "checkmark.seal.fill")
            }
            .onChange(of: viewModel.gradeNotificationsEnabled) { _ in
                Task { await viewModel.updateNotificationSettings() }
            }
        }
    }
    
    private var appSettingsSection: some View {
        Section("App Settings") {
            Toggle(isOn: $viewModel.biometricAuthEnabled) {
                Label("Face ID / Touch ID", systemImage: "faceid")
            }
            .onChange(of: viewModel.biometricAuthEnabled) { _ in
                Task { await viewModel.updateAppSettings() }
            }
            
            Toggle(isOn: $viewModel.downloadOverWifiOnly) {
                Label("Download over Wi-Fi only", systemImage: "wifi")
            }
            .onChange(of: viewModel.downloadOverWifiOnly) { _ in
                Task { await viewModel.updateAppSettings() }
            }
            
            Toggle(isOn: $viewModel.autoplayVideos) {
                Label("Autoplay Videos", systemImage: "play.circle")
            }
            .onChange(of: viewModel.autoplayVideos) { _ in
                Task { await viewModel.updateAppSettings() }
            }
            
            Picker("Theme", selection: $viewModel.appTheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            
            HStack {
                Label("Cache Size", systemImage: "internaldrive")
                Spacer()
                Text(viewModel.cacheSize)
                    .foregroundColor(.secondary)
                Button("Clear") {
                    Task { await viewModel.clearCache() }
                }
                .font(.caption)
            }
        }
    }
    
    private var supportSection: some View {
        Section("Support") {
            NavigationLink(destination: Text("Help Center")) {
                Label("Help Center", systemImage: "questionmark.circle")
            }
            
            NavigationLink(destination: Text("Contact Support")) {
                Label("Contact Support", systemImage: "message")
            }
            
            NavigationLink(destination: Text("Privacy Policy")) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            NavigationLink(destination: Text("Terms of Service")) {
                Label("Terms of Service", systemImage: "doc.text")
            }
            
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var accountSection: some View {
        Section("Account") {
            Button(action: { viewModel.showingLogoutConfirmation = true }) {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
            }
            
            Button(action: { viewModel.showingDeleteAccountConfirmation = true }) {
                Label("Delete Account", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
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
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
} 