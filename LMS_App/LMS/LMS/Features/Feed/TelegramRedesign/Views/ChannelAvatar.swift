//
//  ChannelAvatar.swift
//  LMS
//
//  Sprint 50 - Компонент аватара канала в стиле Telegram
//

import SwiftUI

/// Компонент для отображения аватара канала
struct ChannelAvatar: View {
    let avatarType: ChannelAvatarType
    let size: CGFloat
    
    init(avatarType: ChannelAvatarType, size: CGFloat = 54) {
        self.avatarType = avatarType
        self.size = size
    }
    
    var body: some View {
        switch avatarType {
        case .icon(let systemName, let color):
            iconAvatar(systemName: systemName, color: color)
        case .image(let imageName):
            imageAvatar(imageName: imageName)
        case .text(let text, let color):
            textAvatar(text: text, color: color)
        }
    }
    
    @ViewBuilder
    private func iconAvatar(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3)
                .fill(color.opacity(0.2))
                .frame(width: size, height: size)
            
            Image(systemName: systemName)
                .font(.system(size: size * 0.45))
                .foregroundColor(color)
        }
    }
    
    @ViewBuilder
    private func imageAvatar(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.3))
    }
    
    @ViewBuilder
    private func textAvatar(text: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3)
                .fill(color)
                .frame(width: size, height: size)
            
            Text(text)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Previews

struct ChannelAvatar_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            VStack(spacing: 20) {
                ChannelAvatar(avatarType: .icon("megaphone.fill", .red))
                Text("Icon").font(.caption)
            }
            
            VStack(spacing: 20) {
                ChannelAvatar(avatarType: .text("ЦУМ", .blue))
                Text("Text").font(.caption)
            }
            
            VStack(spacing: 20) {
                ChannelAvatar(avatarType: .icon("book.fill", .green))
                Text("Book").font(.caption)
            }
            
            VStack(spacing: 20) {
                ChannelAvatar(avatarType: .text("А", .purple), size: 40)
                Text("Small").font(.caption)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 