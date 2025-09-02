//
//  ChannelAvatar.swift
//  LMS
//
//  Sprint 50 - Компонент аватара канала
//

import SwiftUI

struct ChannelAvatar: View {
    let avatar: FeedChannelAvatar
    let size: CGFloat
    
    var body: some View {
        switch avatar.type {
        case .text(let text):
            Circle()
                .fill(avatar.backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    Text(text)
                        .font(.system(size: size * 0.5, weight: .semibold))
                        .foregroundColor(.white)
                )
            
        case .image(let imageName):
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
            
        case .icon(let iconName):
            Circle()
                .fill(avatar.backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: size * 0.5, weight: .regular))
                        .foregroundColor(.white)
                )
        }
    }
}

#if DEBUG
struct ChannelAvatar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ChannelAvatar(
                avatar: FeedChannelAvatar(type: .text("НР"), backgroundColor: .blue),
                size: 50
            )
            
            ChannelAvatar(
                avatar: FeedChannelAvatar(type: .icon("megaphone"), backgroundColor: .red),
                size: 50
            )
        }
        .padding()
    }
}
#endif 