import SwiftUI

// MARK: - OfflineIndicator

/// Индикатор отсутствия интернет-соединения
struct OfflineIndicator: View {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var showDetails = false
    
    var body: some View {
        if !networkMonitor.isConnected {
            VStack(spacing: 0) {
                // Main indicator
                HStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Нет подключения к интернету")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showDetails.toggle() }) {
                        Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.red)
                
                // Details (expandable)
                if showDetails {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Некоторые функции могут быть недоступны:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Загрузка новых данных", systemImage: "arrow.down.circle")
                            Label("Отправка изменений", systemImage: "arrow.up.circle")
                            Label("Обновление профиля", systemImage: "person.circle")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Text("Данные будут синхронизированы при восстановлении соединения")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showDetails)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - OfflineIndicatorModifier

/// Модификатор для добавления индикатора offline режима к любому View
struct OfflineIndicatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            OfflineIndicator()
            content
        }
    }
}

// MARK: - View Extension

extension View {
    /// Добавить индикатор offline режима
    func withOfflineIndicator() -> some View {
        modifier(OfflineIndicatorModifier())
    }
} 