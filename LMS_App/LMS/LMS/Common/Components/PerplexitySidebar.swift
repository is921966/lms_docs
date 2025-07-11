//
//  PerplexitySidebar.swift
//  LMS
//
//  Created for Sprint 46: Perplexity-Style Redesign
//

import SwiftUI

// MARK: - Sidebar Item Model
struct PerplexitySidebarItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let badge: Int?
    let action: () -> Void
    
    init(title: String, icon: String, badge: Int? = nil, action: @escaping () -> Void = {}) {
        self.title = title
        self.icon = icon
        self.badge = badge
        self.action = action
    }
}

// MARK: - Sidebar View
struct PerplexitySidebar: View {
    @Binding var isOpen: Bool
    @Binding var selectedItem: String
    let items: [PerplexitySidebarItem]
    
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Sidebar Content
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    sidebarHeader
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: PerplexitySpacing.xs) {
                            // Menu Items
                            ForEach(items) { item in
                                sidebarItem(item)
                            }
                        }
                        .padding(.vertical, PerplexitySpacing.md)
                    }
                    
                    Spacer()
                    
                    // Footer
                    sidebarFooter
                }
                .frame(width: 280)
                .background(PerplexityColors.surface)
                .offset(x: isOpen ? 0 : -280 + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width > 0 && !isOpen {
                                dragOffset = min(value.translation.width, 280)
                            } else if value.translation.width < 0 && isOpen {
                                dragOffset = max(value.translation.width, -280)
                            }
                        }
                        .onEnded { value in
                            withAnimation(PerplexityAnimation.smooth) {
                                if value.translation.width > 100 && !isOpen {
                                    isOpen = true
                                } else if value.translation.width < -100 && isOpen {
                                    isOpen = false
                                }
                                dragOffset = 0
                            }
                        }
                )
                
                // Overlay to close sidebar
                if isOpen {
                    Color.black.opacity(0.3)
                        .frame(width: geometry.size.width - 280)
                        .onTapGesture {
                            withAnimation(PerplexityAnimation.smooth) {
                                isOpen = false
                            }
                        }
                }
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var sidebarHeader: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(PerplexityColors.primary)
            
            Text("LMS AI")
                .font(PerplexityFonts.subtitle())
                .foregroundColor(PerplexityColors.textPrimary)
            
            Spacer()
            
            Button(action: {
                withAnimation(PerplexityAnimation.smooth) {
                    isOpen = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(PerplexityColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(PerplexityColors.background)
                    )
            }
        }
        .padding(PerplexitySpacing.md)
        .background(PerplexityColors.surface)
        .overlay(
            Rectangle()
                .fill(PerplexityColors.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Menu Item
    private func sidebarItem(_ item: PerplexitySidebarItem) -> some View {
        Button(action: {
            withAnimation(PerplexityAnimation.quick) {
                selectedItem = item.title
                item.action()
            }
        }) {
            HStack(spacing: PerplexitySpacing.sm) {
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(
                        selectedItem == item.title ? PerplexityColors.primary : PerplexityColors.textSecondary
                    )
                    .frame(width: 24, height: 24)
                
                Text(item.title)
                    .font(PerplexityFonts.body())
                    .foregroundColor(
                        selectedItem == item.title ? PerplexityColors.textPrimary : PerplexityColors.textSecondary
                    )
                
                Spacer()
                
                if let badge = item.badge, badge > 0 {
                    Text("\(badge)")
                        .font(PerplexityFonts.caption())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(PerplexityColors.primary)
                        )
                }
            }
            .padding(.horizontal, PerplexitySpacing.md)
            .padding(.vertical, PerplexitySpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: PerplexityRadius.md)
                    .fill(selectedItem == item.title ? PerplexityColors.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, PerplexitySpacing.sm)
    }
    
    // MARK: - Footer
    private var sidebarFooter: some View {
        VStack(spacing: PerplexitySpacing.sm) {
            Divider()
                .background(PerplexityColors.divider)
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(PerplexityColors.textSecondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Игорь Широков")
                        .font(PerplexityFonts.bodyBold())
                        .foregroundColor(PerplexityColors.textPrimary)
                    
                    Text("Студент")
                        .font(PerplexityFonts.caption())
                        .foregroundColor(PerplexityColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(PerplexityColors.textSecondary)
                }
            }
            .padding(PerplexitySpacing.md)
        }
        .background(PerplexityColors.surface)
    }
}

// MARK: - Sidebar Toggle Button
struct PerplexitySidebarToggle: View {
    @Binding var isOpen: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(PerplexityAnimation.smooth) {
                isOpen.toggle()
            }
        }) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(PerplexityColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(PerplexityColors.surface)
                        .overlay(
                            Circle()
                                .stroke(PerplexityColors.border, lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Preview
struct PerplexitySidebar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Main Content
            VStack {
                HStack {
                    PerplexitySidebarToggle(isOpen: .constant(false))
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            .perplexityBackground()
            
            // Sidebar
            PerplexitySidebar(
                isOpen: .constant(true),
                selectedItem: .constant("Главная"),
                items: [
                    PerplexitySidebarItem(title: "Главная", icon: "house.fill"),
                    PerplexitySidebarItem(title: "Курсы", icon: "book.fill", badge: 3),
                    PerplexitySidebarItem(title: "Прогресс", icon: "chart.line.uptrend.xyaxis"),
                    PerplexitySidebarItem(title: "Профиль", icon: "person.fill"),
                    PerplexitySidebarItem(title: "Настройки", icon: "gearshape")
                ]
            )
        }
    }
} 