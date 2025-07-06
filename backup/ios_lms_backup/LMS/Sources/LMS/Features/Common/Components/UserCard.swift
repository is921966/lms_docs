import SwiftUI

struct UserCard: View {
    let user: User
    let isSelected: Bool
    let showRole: Bool
    let onTap: (() -> Void)?
    
    init(
        user: User,
        isSelected: Bool = false,
        showRole: Bool = true,
        onTap: (() -> Void)? = nil
    ) {
        self.user = user
        self.isSelected = isSelected
        self.showRole = showRole
        self.onTap = onTap
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width: 50, height: 50)
                
                Text(user.initials)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if showRole {
                    HStack(spacing: 4) {
                        Image(systemName: roleIcon)
                            .font(.caption2)
                        Text(roleText)
                            .font(.caption2)
                    }
                    .foregroundColor(roleColor)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.title2)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap?()
        }
    }
    
    private var roleIcon: String {
        switch user.role {
        case .student:
            return "graduationcap"
        case .instructor:
            return "person.fill"
        case .admin:
            return "shield.fill"
        case .superAdmin:
            return "star.fill"
        }
    }
    
    private var roleText: String {
        switch user.role {
        case .student:
            return "Student"
        case .instructor:
            return "Instructor"
        case .admin:
            return "Admin"
        case .superAdmin:
            return "Super Admin"
        }
    }
    
    private var roleColor: Color {
        switch user.role {
        case .student:
            return .blue
        case .instructor:
            return .green
        case .admin:
            return .purple
        case .superAdmin:
            return .red
        }
    }
}
