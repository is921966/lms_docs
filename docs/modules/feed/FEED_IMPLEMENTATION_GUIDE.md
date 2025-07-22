# Руководство по реализации ленты новостей в стиле Telegram

## 🎯 Основные компоненты

### 1. FeedChannelCell - Ячейка канала
```swift
struct FeedChannelCell: View {
    let channel: FeedChannel
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondaryColor: Color {
        Color(UIColor.systemGray)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ChannelAvatar(channel: channel)
                .frame(width: 52, height: 52)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Header
                HStack(alignment: .top) {
                    Text(channel.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                    
                    Spacer(minLength: 8)
                    
                    Text(channel.lastMessageTime.formatted())
                        .font(.system(size: 14))
                        .foregroundColor(secondaryColor)
                }
                
                // Message preview
                HStack(alignment: .top) {
                    Text(channel.lastMessage)
                        .font(.system(size: 15))
                        .foregroundColor(secondaryColor)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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

### 2. UnreadBadge - Счетчик непрочитанных
```swift
struct UnreadBadge: View {
    let count: Int
    
    private var displayText: String {
        switch count {
        case 1000...: return "\(count / 1000)K"
        case 100...: return "\(count)"
        default: return "\(count)"
        }
    }
    
    private var backgroundColor: Color {
        count > 99 ? Color(UIColor.systemGray3) : .blue
    }
    
    var body: some View {
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
    }
}
```

### 3. FeedListView - Основной список
```swift
struct FeedListView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                FeedSearchBar(searchText: $searchText)
                    .padding(.vertical, 8)
                
                // Channel list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredChannels(searchText)) { channel in
                            NavigationLink(destination: ChannelDetailView(channel: channel)) {
                                FeedChannelCell(channel: channel)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
```

### 4. Модель данных
```swift
struct FeedChannel: Identifiable {
    let id = UUID()
    let name: String
    let avatarType: AvatarType
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
    let category: NewsCategory
    let priority: Priority
    
    enum AvatarType {
        case text(String, Color)
        case image(String)
        case systemIcon(String, Color)
    }
    
    enum Priority {
        case critical
        case important
        case normal
        case archived
    }
}

enum NewsCategory {
    case announcement
    case learning
    case achievement
    case event
    case department
    
    var color: Color {
        switch self {
        case .announcement: return .red
        case .learning: return .blue
        case .achievement: return .yellow
        case .event: return .green
        case .department: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .announcement: return "megaphone.fill"
        case .learning: return "book.fill"
        case .achievement: return "star.fill"
        case .event: return "calendar"
        case .department: return "building.2.fill"
        }
    }
}
```

## 🎨 Стилизация и темы

### ColorTheme
```swift
struct FeedColorTheme {
    @Environment(\.colorScheme) var colorScheme
    
    var background: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    var primaryText: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var secondaryText: Color {
        Color(UIColor.systemGray)
    }
    
    var badgeBlue: Color {
        Color(hex: "007AFF")
    }
    
    var badgeGray: Color {
        colorScheme == .dark ? Color(hex: "48484A") : Color(hex: "8E8E93")
    }
}
```

## ⚡ Анимации и жесты

### Swipe Actions
```swift
extension View {
    func feedSwipeActions() -> some View {
        self.swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                // Delete action
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            
            Button {
                // Mark as read
            } label: {
                Label("Прочитано", systemImage: "envelope.open")
            }
            .tint(.blue)
        }
    }
}
```

### Custom Transitions
```swift
extension AnyTransition {
    static var feedCellTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}
```

## 📊 Оптимизация производительности

### 1. Lazy Loading
```swift
LazyVStack(spacing: 0) {
    ForEach(channels) { channel in
        FeedChannelCell(channel: channel)
            .onAppear {
                viewModel.loadMoreIfNeeded(channel)
            }
    }
}
```

### 2. Image Caching
```swift
class ImageCacheService {
    static let shared = ImageCacheService()
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        // Load and cache
        if let image = await downloadImage(from: url) {
            cache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
}
```

### 3. Debounced Search
```swift
extension View {
    func onSearchTextChange(_ text: Binding<String>, action: @escaping (String) -> Void) -> some View {
        self.onChange(of: text.wrappedValue) { newValue in
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                if text.wrappedValue == newValue {
                    action(newValue)
                }
            }
        }
    }
}
```

## 🧪 Тестирование

### Unit Tests
```swift
class FeedViewModelTests: XCTestCase {
    func testFilterChannels() {
        let viewModel = FeedViewModel()
        let channels = [
            FeedChannel(name: "Администрация", ...),
            FeedChannel(name: "HR отдел", ...)
        ]
        
        viewModel.channels = channels
        
        XCTAssertEqual(viewModel.filteredChannels("HR").count, 1)
        XCTAssertEqual(viewModel.filteredChannels("").count, 2)
    }
}
```

### UI Tests
```swift
class FeedUITests: XCTestCase {
    func testSwipeToDelete() {
        let app = XCUIApplication()
        app.launch()
        
        let firstCell = app.cells.firstMatch
        firstCell.swipeLeft()
        
        app.buttons["Удалить"].tap()
        
        XCTAssertFalse(firstCell.exists)
    }
}
```

## 📦 Интеграция с существующим кодом

### FeatureRegistry
```swift
// В FeatureRegistry.swift добавить:
static let feedRedesign = Feature(
    id: "feed_redesign",
    name: "Редизайн ленты новостей",
    description: "Новый дизайн ленты в стиле Telegram",
    isEnabled: true,
    requiredRole: .student
)
```

### Навигация
```swift
// В MainTabView обновить:
case .feed:
    if FeatureRegistry.feedRedesign.isEnabled {
        FeedListView() // Новый дизайн
    } else {
        FeedView() // Старый дизайн
    }
} 