# Дизайн ленты новостей в стиле Telegram

## 📱 Анализ UI/UX Telegram (на основе скриншота)

### Ключевые элементы дизайна

#### 1. Структура канала/чата
```
┌─────────────────────────────────────┐
│ [Avatar] Название канала      13:36 │
│          Превью сообщения...   [518]│
└─────────────────────────────────────┘
```

#### 2. Визуальные характеристики из скриншота
- **Аватары**: Круглые, 48-56pt диаметр
- **Заголовки**: SF Pro Display Semibold, 16pt
- **Время**: SF Pro Text Regular, 14pt, серый цвет (#8E8E93)
- **Текст превью**: SF Pro Text Regular, 15pt, серый цвет (#8E8E93)
- **Счетчики**: В овальном badge, белый текст на цветном фоне
- **Отступы**: 12pt слева/справа, 8pt сверху/снизу
- **Разделители**: Отсутствуют (чистый дизайн)

### 🎨 Цветовая схема (из скриншота)

#### Светлая тема
- **Фон**: #FFFFFF
- **Текст заголовка**: #000000
- **Текст превью**: #8E8E93
- **Время**: #8E8E93
- **Badge непрочитанных**: #007AFF (синий)
- **Badge с большим числом**: #8E8E93 (серый)
- **Иконки**: #007AFF (активные), #8E8E93 (неактивные)

#### Темная тема
- **Фон**: #000000
- **Текст заголовка**: #FFFFFF
- **Текст превью**: #8B8B8D
- **Время**: #8B8B8D
- **Badge непрочитанных**: #007AFF
- **Badge с большим числом**: #48484A

### 📐 Размеры и метрики

```swift
enum FeedMetrics {
    static let avatarSize: CGFloat = 52
    static let horizontalPadding: CGFloat = 12
    static let verticalPadding: CGFloat = 8
    static let titleFontSize: CGFloat = 16
    static let previewFontSize: CGFloat = 15
    static let timeFontSize: CGFloat = 14
    static let badgeHeight: CGFloat = 22
    static let badgeMinWidth: CGFloat = 22
    static let cellHeight: CGFloat = 76
}
```

### 🎨 Компоненты для реализации

#### FeedChannelCell
```swift
struct FeedChannelCell: View {
    let channel: FeedChannel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(channel.avatarColor)
                .frame(width: 52, height: 52)
                .overlay(
                    Text(channel.avatarText)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Header
                HStack {
                    Text(channel.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(channel.lastMessageTime)
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.systemGray))
                }
                
                // Preview
                HStack {
                    Text(channel.lastMessage)
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.systemGray))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if channel.unreadCount > 0 {
                        UnreadBadge(count: channel.unreadCount)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
```

#### UnreadBadge
```swift
struct UnreadBadge: View {
    let count: Int
    
    var backgroundColor: Color {
        count > 99 ? Color(UIColor.systemGray3) : Color.blue
    }
    
    var displayText: String {
        if count > 999 {
            return "\(count / 1000)K"
        } else if count > 99 {
            return "\(count)"
        } else {
            return "\(count)"
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, count > 9 ? 8 : 6)
            .frame(minWidth: 22, minHeight: 22)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }
}
```

### 📱 Особенности навигации

#### Вкладки (Tab Bar)
```swift
struct FeedTabBar: View {
    @Binding var selectedTab: FeedTab
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Контакты",
                icon: "person.2.fill",
                tab: .contacts,
                selectedTab: $selectedTab
            )
            
            TabButton(
                title: "Звонки",
                icon: "phone.fill",
                tab: .calls,
                selectedTab: $selectedTab
            )
            
            TabButton(
                title: "Чаты",
                icon: "message.fill",
                tab: .chats,
                selectedTab: $selectedTab,
                badge: 423
            )
            
            TabButton(
                title: "Настройки",
                icon: "gearshape.fill",
                tab: .settings,
                selectedTab: $selectedTab
            )
        }
        .frame(height: 49)
        .background(Color(UIColor.systemBackground))
    }
}
```

### 🔍 Поисковая строка
```swift
struct FeedSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(UIColor.systemGray))
                
                TextField("Поиск по новостям...", text: $searchText)
                    .font(.system(size: 17))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            
            Button(action: {}) {
                Image(systemName: "gear")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
```

### ⚡ Анимации и жесты

#### Свайп для действий
```swift
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) {
        // Удалить/Скрыть
    } label: {
        Label("Удалить", systemImage: "trash")
    }
    
    Button {
        // Отметить как прочитанное
    } label: {
        Label("Прочитано", systemImage: "envelope.open")
    }
    .tint(.blue)
}
```

#### Pull-to-refresh
```swift
.refreshable {
    await viewModel.refreshFeed()
}
```

### 📊 Производительность

1. **LazyVStack** для списка сообщений
2. **Кеширование аватаров** в памяти
3. **Предзагрузка** следующих 20 элементов
4. **Дебаунс** для поиска (300мс)
5. **Оптимизация изображений** (сжатие, ресайз)

### 🎯 Ключевые отличия для LMS

1. **Категории новостей** вместо типов чатов
2. **Корпоративные аватары** (логотипы департаментов)
3. **Приоритеты** (важные новости сверху)
4. **Статусы прочтения** с аналитикой
5. **Интеграция с обучением** (новости о курсах)

### 📱 Адаптация под LMS контент

```swift
enum NewsCategory {
    case announcement     // Объявления
    case learning        // Обучение
    case achievement     // Достижения
    case event          // События
    case department     // Департамент
    
    var icon: String {
        switch self {
        case .announcement: return "megaphone.fill"
        case .learning: return "book.fill"
        case .achievement: return "star.fill"
        case .event: return "calendar"
        case .department: return "building.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .announcement: return .red
        case .learning: return .blue
        case .achievement: return .yellow
        case .event: return .green
        case .department: return .purple
        }
    }
}
``` 