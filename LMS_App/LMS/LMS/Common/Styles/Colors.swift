import SwiftUI

struct LMSColors {
    // MARK: - Primary Colors
    static let primary = Color("Primary", bundle: .main)
        .opacity(1.0)
    static let primaryLight = Color("PrimaryLight", bundle: .main)
        .opacity(1.0)
    static let primaryDark = Color("PrimaryDark", bundle: .main)
        .opacity(1.0)
    
    // MARK: - Semantic Colors
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    
    static let label = Color(uiColor: .label)
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
    static let tertiaryLabel = Color(uiColor: .tertiaryLabel)
    
    // MARK: - Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // MARK: - Admin Mode Colors
    static let adminAccent = Color.purple
    static let adminBackground = Color.purple.opacity(0.1)
    static let adminBorder = Color.purple.opacity(0.3)
    
    // MARK: - Component Colors
    static let cardBackground = secondaryBackground
    static let divider = Color(uiColor: .separator)
    static let shadow = Color.black.opacity(0.1)
    
    // MARK: - Role Colors
    static func roleColor(for role: User.Role) -> Color {
        switch role {
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

// MARK: - Color Extensions
extension Color {
    static let lmsPrimary = LMSColors.primary
    static let lmsBackground = LMSColors.background
    static let lmsSecondaryBackground = LMSColors.secondaryBackground
    static let lmsLabel = LMSColors.label
    static let lmsSuccess = LMSColors.success
    static let lmsError = LMSColors.error
    static let lmsAdminAccent = LMSColors.adminAccent
}

// MARK: - View Modifiers
struct LMSCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LMSColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: LMSColors.shadow, radius: 2, x: 0, y: 1)
    }
}

extension View {
    func lmsCardStyle() -> some View {
        modifier(LMSCardBackground())
    }
} 