//
//  PerplexityCard.swift
//  LMS
//
//  Created for Sprint 46: Perplexity-Style Redesign
//

import SwiftUI

// MARK: - Basic Card
struct PerplexityCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = PerplexitySpacing.md
    var isHoverable: Bool = false
    
    @State private var isHovered = false
    
    init(padding: CGFloat = PerplexitySpacing.md, 
         isHoverable: Bool = false,
         @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.isHoverable = isHoverable
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: PerplexityRadius.lg)
                    .fill(PerplexityColors.surface)
                    .shadow(
                        color: isHovered ? PerplexityColors.primary.opacity(0.1) : .clear,
                        radius: isHovered ? 10 : 0
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: PerplexityRadius.lg)
                    .stroke(
                        isHovered ? PerplexityColors.primary.opacity(0.5) : PerplexityColors.border,
                        lineWidth: 1
                    )
            )
            .scaleEffect(isHovered && isHoverable ? 1.02 : 1.0)
            .animation(PerplexityAnimation.quick, value: isHovered)
            .onHover { hovering in
                if isHoverable {
                    isHovered = hovering
                }
            }
    }
}

// MARK: - Content Card with Header
struct PerplexityContentCard: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var iconColor: Color = PerplexityColors.primary
    var action: (() -> Void)? = nil
    
    var body: some View {
        PerplexityCard(isHoverable: action != nil) {
            VStack(alignment: .leading, spacing: PerplexitySpacing.sm) {
                // Header
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(iconColor)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(iconColor.opacity(0.1))
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(PerplexityFonts.section())
                            .foregroundColor(PerplexityColors.textPrimary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(PerplexityFonts.caption())
                                .foregroundColor(PerplexityColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(PerplexityColors.textMuted)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

// MARK: - AI Response Card
struct PerplexityResponseCard: View {
    let response: String
    var sources: [String] = []
    var isLoading: Bool = false
    
    @State private var displayedText = ""
    @State private var isAnimating = false
    
    var body: some View {
        PerplexityCard {
            VStack(alignment: .leading, spacing: PerplexitySpacing.md) {
                // AI Icon Header
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(PerplexityColors.primary)
                    
                    Text("AI Ответ")
                        .font(PerplexityFonts.caption())
                        .foregroundColor(PerplexityColors.textSecondary)
                    
                    Spacer()
                }
                
                // Response Text
                if isLoading {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(PerplexityColors.primary)
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .onAppear {
                        isAnimating = true
                    }
                } else {
                    Text(displayedText)
                        .font(PerplexityFonts.body())
                        .foregroundColor(PerplexityColors.textPrimary)
                        .lineSpacing(4)
                        .onAppear {
                            animateText()
                        }
                }
                
                // Sources
                if !sources.isEmpty && !isLoading {
                    VStack(alignment: .leading, spacing: PerplexitySpacing.xs) {
                        Text("Источники")
                            .font(PerplexityFonts.caption())
                            .foregroundColor(PerplexityColors.textSecondary)
                        
                        ForEach(Array(sources.enumerated()), id: \.offset) { index, source in
                            HStack(spacing: PerplexitySpacing.xs) {
                                Text("\(index + 1)")
                                    .font(PerplexityFonts.small())
                                    .foregroundColor(PerplexityColors.primary)
                                    .frame(width: 20, height: 20)
                                    .background(
                                        Circle()
                                            .fill(PerplexityColors.primary.opacity(0.1))
                                    )
                                
                                Text(source)
                                    .font(PerplexityFonts.caption())
                                    .foregroundColor(PerplexityColors.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.top, PerplexitySpacing.xs)
                }
            }
        }
    }
    
    private func animateText() {
        displayedText = ""
        for (index, character) in response.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.01) {
                displayedText.append(character)
            }
        }
    }
}

// MARK: - Stats Card
struct PerplexityStatsCard: View {
    let value: String
    let label: String
    var trend: Double? = nil
    var icon: String? = nil
    
    var trendColor: Color {
        guard let trend = trend else { return PerplexityColors.textSecondary }
        return trend > 0 ? PerplexityColors.success : PerplexityColors.error
    }
    
    var body: some View {
        PerplexityCard {
            VStack(alignment: .leading, spacing: PerplexitySpacing.xs) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(PerplexityColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 2) {
                            Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 12, weight: .medium))
                            
                            Text("\(abs(Int(trend)))%")
                                .font(PerplexityFonts.caption())
                        }
                        .foregroundColor(trendColor)
                    }
                }
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(PerplexityColors.textPrimary)
                
                Text(label)
                    .font(PerplexityFonts.caption())
                    .foregroundColor(PerplexityColors.textSecondary)
            }
        }
    }
}

// MARK: - Preview
struct PerplexityCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PerplexityContentCard(
                title: "Курс по Swift",
                subtitle: "Начат 2 дня назад",
                icon: "book.fill",
                iconColor: PerplexityColors.blue,
                action: {}
            )
            
            PerplexityResponseCard(
                response: "SwiftUI - это современный фреймворк для создания пользовательских интерфейсов...",
                sources: ["Apple Developer", "Swift.org", "Ray Wenderlich"]
            )
            
            HStack(spacing: 16) {
                PerplexityStatsCard(
                    value: "87%",
                    label: "Прогресс",
                    trend: 12,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                PerplexityStatsCard(
                    value: "4.5",
                    label: "Средний балл",
                    trend: -2,
                    icon: "star.fill"
                )
            }
        }
        .padding()
        .perplexityBackground()
    }
} 