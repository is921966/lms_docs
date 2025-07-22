//
//  UnreadBadge.swift
//  LMS
//
//  Sprint 50 - Компонент счетчика непрочитанных в стиле Telegram
//

import SwiftUI

/// Компонент для отображения количества непрочитанных сообщений
struct UnreadBadge: View {
    let count: Int
    
    var displayText: String {
        switch count {
        case 0:
            return ""
        case 1..<1000:
            return "\(count)"
        default:
            return "\(count / 1000)K"
        }
    }
    
    var backgroundColor: Color {
        count > 99 ? Color(UIColor.systemGray3) : .blue
    }
    
    var body: some View {
        if count > 0 {
            Text(displayText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, count > 9 ? 8 : 6)
                .frame(minWidth: 22)
                .frame(height: 22)
                .background(
                    Capsule()
                        .fill(backgroundColor)
                )
                .accessibilityLabel("\(count) непрочитанных")
        }
    }
}

// MARK: - Previews

struct UnreadBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                UnreadBadge(count: 1)
                UnreadBadge(count: 5)
                UnreadBadge(count: 42)
                UnreadBadge(count: 99)
            }
            
            HStack(spacing: 20) {
                UnreadBadge(count: 100)
                UnreadBadge(count: 518)
                UnreadBadge(count: 999)
            }
            
            HStack(spacing: 20) {
                UnreadBadge(count: 1000)
                UnreadBadge(count: 2500)
                UnreadBadge(count: 10000)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
} 