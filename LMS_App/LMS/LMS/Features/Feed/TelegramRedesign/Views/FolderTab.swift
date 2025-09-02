//
//  FolderTab.swift
//  LMS
//
//  Folder tab for QueryWizard News style feed
//

import SwiftUI

struct FolderTab: View {
    let folder: FeedFolder
    let isSelected: Bool
    let unreadCount: Int
    let action: () -> Void
    let onLongPress: (() -> Void)?
    
    init(
        folder: FeedFolder,
        isSelected: Bool,
        unreadCount: Int,
        action: @escaping () -> Void,
        onLongPress: (() -> Void)? = nil
    ) {
        self.folder = folder
        self.isSelected = isSelected
        self.unreadCount = unreadCount
        self.action = action
        self.onLongPress = onLongPress
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon
                Image(systemName: folder.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                
                // Name
                Text(folder.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                // Count
                if unreadCount > 0 {
                    Text("(\(unreadCount))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(UIColor.systemGray5))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if case .custom = folder {
                Button(role: .destructive) {
                    onLongPress?()
                } label: {
                    Label("Удалить папку", systemImage: "trash")
                }
            }
        }
    }
} 