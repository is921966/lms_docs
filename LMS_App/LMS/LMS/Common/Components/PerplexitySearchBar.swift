//
//  PerplexitySearchBar.swift
//  LMS
//
//  Created for Sprint 46: Perplexity-Style Redesign
//

import SwiftUI

struct PerplexitySearchBar: View {
    @Binding var text: String
    var placeholder: String = "Спросите что-нибудь..."
    var onSubmit: () -> Void = {}
    var onMicTap: () -> Void = {}
    
    @State private var isFocused = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: PerplexitySpacing.sm) {
            // AI Icon
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(PerplexityColors.primary)
                .frame(width: 24, height: 24)
            
            // Search Field
            TextField(placeholder, text: $text)
                .font(PerplexityFonts.body())
                .foregroundColor(PerplexityColors.textPrimary)
                .focused($isTextFieldFocused)
                .onSubmit(onSubmit)
                .textFieldStyle(.plain)
            
            // Clear Button
            if !text.isEmpty {
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(PerplexityColors.textMuted)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Microphone Button
            Button(action: onMicTap) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(PerplexityColors.textSecondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, PerplexitySpacing.md)
        .padding(.vertical, PerplexitySpacing.sm + 2)
        .background(
            RoundedRectangle(cornerRadius: PerplexityRadius.lg)
                .fill(PerplexityColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: PerplexityRadius.lg)
                        .stroke(
                            isTextFieldFocused ? PerplexityColors.primary : PerplexityColors.border,
                            lineWidth: isTextFieldFocused ? 2 : 1
                        )
                )
        )
        .animation(PerplexityAnimation.quick, value: isTextFieldFocused)
        .perplexityGlow(
            color: isTextFieldFocused ? PerplexityColors.primary : .clear,
            radius: isTextFieldFocused ? 30 : 0
        )
        .onChange(of: isTextFieldFocused) { focused in
            isFocused = focused
        }
    }
}

// MARK: - Animated Search Bar
struct PerplexityAnimatedSearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void = {}
    
    @State private var placeholderIndex = 0
    @State private var placeholderText = ""
    
    let placeholders = [
        "Как работает система обучения?",
        "Покажи мои курсы",
        "Что нового в компании?",
        "Найди курс по Swift",
        "Мой прогресс за месяц"
    ]
    
    var body: some View {
        PerplexitySearchBar(
            text: $text,
            placeholder: placeholderText.isEmpty ? placeholders[0] : placeholderText,
            onSubmit: onSubmit
        )
        .onAppear {
            animatePlaceholder()
        }
    }
    
    private func animatePlaceholder() {
        withAnimation(.easeInOut(duration: 0.5)) {
            placeholderText = placeholders[placeholderIndex]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            placeholderIndex = (placeholderIndex + 1) % placeholders.count
            placeholderText = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animatePlaceholder()
            }
        }
    }
}

// MARK: - Search Suggestions
struct PerplexitySearchSuggestions: View {
    let suggestions: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button(action: { onSelect(suggestion) }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(PerplexityColors.textMuted)
                        
                        Text(suggestion)
                            .font(PerplexityFonts.body())
                            .foregroundColor(PerplexityColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 12))
                            .foregroundColor(PerplexityColors.textMuted)
                    }
                    .padding(.horizontal, PerplexitySpacing.md)
                    .padding(.vertical, PerplexitySpacing.sm)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .background(
                    Color.white.opacity(0.001)
                        .onHover { isHovered in
                            // Handle hover state if needed
                        }
                )
                
                if suggestion != suggestions.last {
                    Divider()
                        .background(PerplexityColors.divider)
                }
            }
        }
        .perplexityCard(padding: 0)
        .padding(.top, PerplexitySpacing.xs)
    }
}

// MARK: - Preview
struct PerplexitySearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PerplexitySearchBar(text: .constant(""))
            
            PerplexityAnimatedSearchBar(text: .constant(""))
            
            PerplexitySearchSuggestions(
                suggestions: [
                    "Мои текущие курсы",
                    "Расписание на неделю",
                    "Прогресс обучения"
                ],
                onSelect: { _ in }
            )
        }
        .padding()
        .perplexityBackground()
    }
} 