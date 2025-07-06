import SwiftUI

struct UserDetailView: View {
    let user: User
    @State private var showingEditView = false
    @AppStorage("isAdminMode") private var isAdminMode = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar Section
                    avatarSection
                    
                    // Basic Info
                    infoSection
                    
                    // Role & Permissions
                    roleSection
                    
                    // Statistics
                    if user.role == .student || user.role == .instructor {
                        statisticsSection
                    }
                    
                    // Actions
                    if isAdminMode {
                        actionsSection
                    }
                }
                .padding()
            }
            .navigationTitle(user.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                // UserEditView will be implemented
                Text("Edit User View")
            }
        }
    }
    
    // MARK: - Sections
    
    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [roleColor.opacity(0.8), roleColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Text(user.initials)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(user.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(user.email)
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Information")
            
            InfoRow(label: "User ID", value: user.id.uuidString)
            InfoRow(label: "Email", value: user.email)
            InfoRow(label: "Name", value: user.name)
            InfoRow(label: "Status", value: "Active", valueColor: .green)
        }
    }
    
    private var roleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Role & Permissions")
            
            HStack {
                Label(roleTitle, systemImage: roleIcon)
                    .font(.headline)
                    .foregroundColor(roleColor)
                
                Spacer()
                
                if isAdminMode {
                    Button("Change Role") {
                        // Show role picker
                    }
                    .font(.caption)
                }
            }
            .padding()
            .background(roleColor.opacity(0.1))
            .cornerRadius(12)
            
            // Permissions list
            VStack(alignment: .leading, spacing: 8) {
                ForEach(permissionsForRole, id: \.self) { permission in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(permission)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Statistics")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if user.role == .student {
                    StatCard(title: "Courses Enrolled", value: "12", icon: "book.fill")
                    StatCard(title: "Completed", value: "8", icon: "checkmark.seal.fill")
                    StatCard(title: "In Progress", value: "4", icon: "timer")
                    StatCard(title: "Certificates", value: "6", icon: "medal.fill")
                } else {
                    StatCard(title: "Courses Created", value: "15", icon: "pencil.circle.fill")
                    StatCard(title: "Students", value: "234", icon: "person.2.fill")
                    StatCard(title: "Avg Rating", value: "4.8", icon: "star.fill")
                    StatCard(title: "Certificates Issued", value: "189", icon: "seal.fill")
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            LMSButton(title: "Edit User", icon: Image(systemName: "pencil"), style: .secondary) {
                showingEditView = true
            }
            
            LMSButton(title: "Reset Password", icon: Image(systemName: "key.fill"), style: .secondary) {
                // Reset password
            }
            
            LMSButton(title: "Suspend User", icon: Image(systemName: "pause.circle.fill"), style: .destructive) {
                // Suspend user
            }
        }
    }
    
    // MARK: - Helpers
    
    private var roleIcon: String {
        switch user.role {
        case .student: return "graduationcap"
        case .instructor: return "person.fill"
        case .admin: return "shield.fill"
        case .superAdmin: return "star.fill"
        }
    }
    
    private var roleTitle: String {
        switch user.role {
        case .student: return "Student"
        case .instructor: return "Instructor"
        case .admin: return "Administrator"
        case .superAdmin: return "Super Administrator"
        }
    }
    
    private var roleColor: Color {
        switch user.role {
        case .student: return .blue
        case .instructor: return .green
        case .admin: return .purple
        case .superAdmin: return .red
        }
    }
    
    private var permissionsForRole: [String] {
        switch user.role {
        case .student:
            return ["View courses", "Enroll in courses", "Submit assignments", "View certificates"]
        case .instructor:
            return ["Create courses", "Manage students", "Grade assignments", "Issue certificates"]
        case .admin:
            return ["Manage users", "Manage courses", "View reports", "System settings"]
        case .superAdmin:
            return ["Full system access", "Manage admins", "System configuration", "Database access"]
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
} 