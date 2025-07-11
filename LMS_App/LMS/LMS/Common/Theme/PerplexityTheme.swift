//
//  PerplexityTheme.swift
//  LMS
//
//  Created for Sprint 46: Perplexity-Style Redesign
//

import SwiftUI

// MARK: - Perplexity Color Palette
struct PerplexityColors {
    // Primary Colors
    static let background = Color(hex: "0A0A0A") // Almost black
    static let surface = Color(hex: "1A1A1A") // Dark gray
    static let surfaceLight = Color(hex: "2A2A2A") // Lighter surface
    static let primary = Color(hex: "10A37F") // Perplexity green
    static let primaryLight = Color(hex: "1DB884") // Lighter green
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8E8EA0") // Muted text
    static let textMuted = Color(hex: "565869") // More muted
    
    // Accent Colors
    static let blue = Color(hex: "3B82F6")
    static let purple = Color(hex: "8B5CF6")
    static let pink = Color(hex: "EC4899")
    static let orange = Color(hex: "F97316")
    
    // Semantic Colors
    static let success = Color(hex: "10B981")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    static let info = Color(hex: "3B82F6")
    
    // Border & Divider
    static let border = Color(hex: "2A2A2A")
    static let divider = Color(hex: "1F1F1F")
}

// MARK: - Typography
struct PerplexityFonts {
    // Headers
    static func title() -> Font {
        .system(size: 32, weight: .bold, design: .default)
    }
    
    static func subtitle() -> Font {
        .system(size: 20, weight: .semibold, design: .default)
    }
    
    static func section() -> Font {
        .system(size: 16, weight: .medium, design: .default)
    }
    
    // Body
    static func body() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }
    
    static func bodyBold() -> Font {
        .system(size: 15, weight: .semibold, design: .default)
    }
    
    static func caption() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }
    
    static func small() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }
}

// MARK: - Spacing & Sizing
struct PerplexitySpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct PerplexityRadius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let full: CGFloat = 9999
}

// MARK: - View Modifiers
struct PerplexityCardModifier: ViewModifier {
    var padding: CGFloat = PerplexitySpacing.md
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(PerplexityColors.surface)
            .cornerRadius(PerplexityRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: PerplexityRadius.lg)
                    .stroke(PerplexityColors.border, lineWidth: 1)
            )
    }
}

struct PerplexityButtonModifier: ViewModifier {
    enum Style {
        case primary
        case secondary
        case ghost
    }
    
    let style: Style
    var isFullWidth: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(PerplexityFonts.bodyBold())
            .padding(.horizontal, PerplexitySpacing.lg)
            .padding(.vertical, PerplexitySpacing.sm)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(backgroundView)
            .foregroundColor(foregroundColor)
            .cornerRadius(PerplexityRadius.md)
            .overlay(overlayView)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [PerplexityColors.primary, PerplexityColors.primaryLight],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .secondary:
            Color.clear
        case .ghost:
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return PerplexityColors.textPrimary
        case .ghost:
            return PerplexityColors.textSecondary
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if style == .secondary {
            RoundedRectangle(cornerRadius: PerplexityRadius.md)
                .stroke(PerplexityColors.border, lineWidth: 1)
        }
    }
}

struct PerplexityGlowModifier: ViewModifier {
    var color: Color = PerplexityColors.primary
    var radius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
}

// MARK: - View Extensions
extension View {
    func perplexityCard(padding: CGFloat = PerplexitySpacing.md) -> some View {
        modifier(PerplexityCardModifier(padding: padding))
    }
    
    func perplexityButton(style: PerplexityButtonModifier.Style = .primary, isFullWidth: Bool = false) -> some View {
        modifier(PerplexityButtonModifier(style: style, isFullWidth: isFullWidth))
    }
    
    func perplexityGlow(color: Color = PerplexityColors.primary, radius: CGFloat = 20) -> some View {
        modifier(PerplexityGlowModifier(color: color, radius: radius))
    }
    
    func perplexityBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PerplexityColors.background)
            .foregroundColor(PerplexityColors.textPrimary)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Animation Constants
struct PerplexityAnimation {
    static let quick = Animation.easeInOut(duration: 0.2)
    static let normal = Animation.easeInOut(duration: 0.3)
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let bounce = Animation.spring(response: 0.5, dampingFraction: 0.6)
} 