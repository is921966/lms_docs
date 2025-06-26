//
//  AdminEditButton.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct AdminEditButton: View {
    let action: () -> Void
    var size: ButtonSize = .medium
    
    enum ButtonSize {
        case small, medium, large
        
        var iconSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .body
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "pencil.circle.fill")
                .font(size.iconSize)
                .foregroundColor(.blue)
                .padding(size.padding)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

// Admin controls wrapper
struct AdminControlsOverlay<Content: View>: View {
    let isAdmin: Bool
    let editAction: () -> Void
    let deleteAction: (() -> Void)?
    let content: () -> Content
    
    init(
        isAdmin: Bool,
        editAction: @escaping () -> Void,
        deleteAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isAdmin = isAdmin
        self.editAction = editAction
        self.deleteAction = deleteAction
        self.content = content
    }
    
    var body: some View {
        if isAdmin {
            content()
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 8) {
                        AdminEditButton(action: editAction)
                        
                        if let deleteAction = deleteAction {
                            Button(action: deleteAction) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding(6)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(8)
                }
        } else {
            content()
        }
    }
}

// Admin section header
struct AdminSectionHeader: View {
    let title: String
    let addAction: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Button(action: addAction) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
    }
}

// Check if user is admin
struct AdminCheck {
    static var isAdmin: Bool {
        if let user = MockAuthService.shared.currentUser {
            return user.roles.contains("admin") || user.permissions.contains("manage_content")
        }
        return false
    }
}

#Preview {
    VStack(spacing: 20) {
        AdminEditButton(action: {}, size: .small)
        AdminEditButton(action: {}, size: .medium)
        AdminEditButton(action: {}, size: .large)
        
        AdminControlsOverlay(isAdmin: true, editAction: {}) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
        }
    }
    .padding()
} 