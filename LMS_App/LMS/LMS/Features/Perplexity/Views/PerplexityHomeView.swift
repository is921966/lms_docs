//
//  PerplexityHomeView.swift
//  LMS
//
//  Created for Sprint 46: Perplexity-Style Redesign
//

import SwiftUI

struct PerplexityHomeView: View {
    @State private var searchText = ""
    @State private var showingSidebar = false
    @State private var selectedMenuItem = "Главная"
    @State private var conversations: [AIConversation] = []
    @State private var isSearching = false
    @State private var showingSuggestions = false
    
    @EnvironmentObject var authService: MockAuthService
    
    let searchSuggestions = [
        "Какие курсы мне доступны?",
        "Покажи мой прогресс за месяц",
        "Найди курсы по программированию",
        "Какие задания нужно выполнить?",
        "Расскажи о системе обучения"
    ]
    
    var filteredSuggestions: [String] {
        if searchText.isEmpty {
            return searchSuggestions
        }
        return searchSuggestions.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ZStack {
            // Main Content
            mainContent
                .perplexityBackground()
            
            // Sidebar
            PerplexitySidebar(
                isOpen: $showingSidebar,
                selectedItem: $selectedMenuItem,
                items: sidebarItems
            )
        }
        .onAppear {
            setupInitialConversations()
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            // Content
            ScrollView {
                VStack(spacing: PerplexitySpacing.xl) {
                    // Search Section
                    searchSection
                    
                    // Conversations or Welcome
                    if conversations.isEmpty {
                        welcomeSection
                    } else {
                        conversationsSection
                    }
                }
                .padding(.horizontal, PerplexitySpacing.lg)
                .padding(.bottom, PerplexitySpacing.xl)
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            PerplexitySidebarToggle(isOpen: $showingSidebar)
            
            Spacer()
            
            Text("LMS AI Assistant")
                .font(PerplexityFonts.subtitle())
                .foregroundColor(PerplexityColors.textPrimary)
            
            Spacer()
            
            // New Chat Button
            Button(action: { startNewConversation() }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(PerplexityColors.primary)
            }
        }
        .padding(.horizontal, PerplexitySpacing.md)
        .padding(.vertical, PerplexitySpacing.sm)
        .background(PerplexityColors.background)
        .overlay(
            Rectangle()
                .fill(PerplexityColors.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 0) {
            PerplexityAnimatedSearchBar(
                text: $searchText,
                onSubmit: performSearch
            )
            .overlay(
                // Clear suggestions when tapping outside
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingSuggestions = false
                    }
                    .allowsHitTesting(showingSuggestions),
                alignment: .bottom
            )
            .onTapGesture {
                withAnimation(PerplexityAnimation.quick) {
                    showingSuggestions = true
                }
            }
            
            if showingSuggestions && !filteredSuggestions.isEmpty {
                PerplexitySearchSuggestions(
                    suggestions: Array(filteredSuggestions.prefix(5)),
                    onSelect: { suggestion in
                        searchText = suggestion
                        performSearch()
                        showingSuggestions = false
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .onChange(of: searchText) { _ in
            if searchText.isEmpty {
                showingSuggestions = false
            } else {
                showingSuggestions = true
            }
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(spacing: PerplexitySpacing.xl) {
            // Welcome Message
            VStack(spacing: PerplexitySpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(PerplexityColors.primary)
                    .perplexityGlow()
                
                Text("Привет, \(authService.currentUser?.firstName ?? "Студент")!")
                    .font(PerplexityFonts.title())
                    .foregroundColor(PerplexityColors.textPrimary)
                
                Text("Я ваш AI-ассистент по обучению. Задайте любой вопрос!")
                    .font(PerplexityFonts.body())
                    .foregroundColor(PerplexityColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, PerplexitySpacing.xl)
            
            // Quick Actions
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PerplexitySpacing.md) {
                quickActionCard(
                    title: "Мои курсы",
                    icon: "book.fill",
                    color: PerplexityColors.blue,
                    action: { searchText = "Покажи мои текущие курсы" }
                )
                
                quickActionCard(
                    title: "Прогресс",
                    icon: "chart.line.uptrend.xyaxis",
                    color: PerplexityColors.purple,
                    action: { searchText = "Мой прогресс обучения" }
                )
                
                quickActionCard(
                    title: "Задания",
                    icon: "checklist",
                    color: PerplexityColors.orange,
                    action: { searchText = "Какие задания нужно выполнить?" }
                )
                
                quickActionCard(
                    title: "Расписание",
                    icon: "calendar",
                    color: PerplexityColors.pink,
                    action: { searchText = "Покажи расписание на неделю" }
                )
            }
        }
    }
    
    // MARK: - Quick Action Card
    private func quickActionCard(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            performSearch()
        }) {
            PerplexityCard(isHoverable: true) {
                VStack(spacing: PerplexitySpacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(PerplexityFonts.bodyBold())
                        .foregroundColor(PerplexityColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, PerplexitySpacing.sm)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Conversations Section
    private var conversationsSection: some View {
        VStack(spacing: PerplexitySpacing.md) {
            ForEach(conversations) { conversation in
                conversationView(conversation)
            }
        }
    }
    
    private func conversationView(_ conversation: AIConversation) -> some View {
        VStack(spacing: PerplexitySpacing.md) {
            // User Query
            HStack(alignment: .top) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(PerplexityColors.textSecondary)
                
                Text(conversation.query)
                    .font(PerplexityFonts.body())
                    .foregroundColor(PerplexityColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // AI Response
            PerplexityResponseCard(
                response: conversation.response,
                sources: conversation.sources,
                isLoading: conversation.isLoading
            )
        }
    }
    
    // MARK: - Actions
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        withAnimation(PerplexityAnimation.smooth) {
            showingSuggestions = false
            
            let newConversation = AIConversation(
                query: searchText,
                response: "",
                isLoading: true
            )
            conversations.insert(newConversation, at: 0)
            
            // Simulate AI response
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let index = conversations.firstIndex(where: { $0.id == newConversation.id }) {
                    conversations[index].isLoading = false
                    conversations[index].response = generateMockResponse(for: searchText)
                    conversations[index].sources = ["База знаний LMS", "Учебные материалы", "История обучения"]
                }
            }
            
            searchText = ""
        }
    }
    
    private func startNewConversation() {
        withAnimation(PerplexityAnimation.smooth) {
            conversations.removeAll()
            searchText = ""
        }
    }
    
    private func setupInitialConversations() {
        // Add welcome conversation if first time
        if conversations.isEmpty && authService.isAuthenticated {
            let welcomeConversation = AIConversation(
                query: "Расскажи о возможностях системы обучения",
                response: "Добро пожаловать в LMS! Я помогу вам эффективно учиться. Вот основные возможности:\n\n• 📚 Доступ к курсам - изучайте материалы в удобном темпе\n• 📊 Отслеживание прогресса - следите за своими достижениями\n• 📝 Выполнение заданий - практикуйтесь и получайте обратную связь\n• 🎯 Персональные рекомендации - я подберу курсы под ваши цели\n\nЗадавайте любые вопросы об обучении!",
                sources: ["Справочник LMS", "Руководство пользователя"],
                isLoading: false
            )
            conversations.append(welcomeConversation)
        }
    }
    
    private func generateMockResponse(for query: String) -> String {
        // Mock AI responses based on query
        if query.localizedCaseInsensitiveContains("курс") {
            return "У вас есть доступ к 5 активным курсам:\n\n1. Swift и iOS разработка (прогресс: 67%)\n2. Основы UX/UI дизайна (прогресс: 45%)\n3. Управление проектами (прогресс: 89%)\n4. Английский для IT (прогресс: 34%)\n5. Soft Skills для разработчиков (прогресс: 56%)\n\nРекомендую продолжить с курса по Swift - у вас отличный прогресс!"
        } else if query.localizedCaseInsensitiveContains("прогресс") {
            return "Ваш прогресс за последний месяц:\n\n📈 Общий прогресс: +23%\n⏱ Время обучения: 47 часов\n✅ Выполнено заданий: 34\n🏆 Получено сертификатов: 2\n\nОтличная динамика! Вы в топ-10% самых активных студентов."
        } else if query.localizedCaseInsensitiveContains("задани") {
            return "У вас есть 3 активных задания:\n\n1. Практическая работа по SwiftUI (срок: завтра)\n2. Тест по основам UX (срок: через 3 дня)\n3. Проектная работа по управлению (срок: через неделю)\n\nРекомендую начать с практической работы по SwiftUI."
        } else {
            return "Я проанализировал ваш запрос. Вот что могу предложить:\n\nДля более точного ответа, пожалуйста, уточните ваш вопрос. Я могу помочь с:\n• Информацией о курсах\n• Отслеживанием прогресса\n• Планированием обучения\n• Ответами на вопросы по материалам"
        }
    }
    
    // MARK: - Sidebar Items
    private var sidebarItems: [PerplexitySidebarItem] {
        [
            PerplexitySidebarItem(
                title: "Главная",
                icon: "house.fill",
                action: { selectedMenuItem = "Главная" }
            ),
            PerplexitySidebarItem(
                title: "Курсы",
                icon: "book.fill",
                badge: 3,
                action: { selectedMenuItem = "Курсы" }
            ),
            PerplexitySidebarItem(
                title: "Прогресс",
                icon: "chart.line.uptrend.xyaxis",
                action: { selectedMenuItem = "Прогресс" }
            ),
            PerplexitySidebarItem(
                title: "Профиль",
                icon: "person.fill",
                action: { selectedMenuItem = "Профиль" }
            ),
            PerplexitySidebarItem(
                title: "Настройки",
                icon: "gearshape",
                action: { selectedMenuItem = "Настройки" }
            )
        ]
    }
}

// MARK: - AI Conversation Model
struct AIConversation: Identifiable {
    let id = UUID()
    let query: String
    var response: String
    var sources: [String] = []
    var isLoading: Bool = false
}

// MARK: - Preview
struct PerplexityHomeView_Previews: PreviewProvider {
    static var previews: some View {
        PerplexityHomeView()
            .environmentObject(MockAuthService.shared)
    }
} 