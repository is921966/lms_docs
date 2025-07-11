#!/bin/bash

echo "📰 Генерация новости о релизе..."
echo "================================"

# Получаем версию и билд
VERSION=$(grep MARKETING_VERSION LMS.xcodeproj/project.pbxproj | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
BUILD=$(agvtool what-version -terse)

# Путь к release notes
RELEASE_NOTES_PATH="/Users/ishirokov/lms_docs/docs/releases/TESTFLIGHT_RELEASE_v${VERSION}_build${BUILD}.md"

# Проверяем существование release notes
if [ ! -f "$RELEASE_NOTES_PATH" ]; then
    echo "❌ Release notes не найдены: $RELEASE_NOTES_PATH"
    echo "Создайте release notes перед генерацией новости"
    exit 1
fi

echo "📋 Версия: $VERSION"
echo "📋 Build: $BUILD"
echo "📋 Release Notes: $RELEASE_NOTES_PATH"
echo ""

# Создаем Swift файл с release notes
SWIFT_FILE="LMS/Features/Feed/Data/ReleaseNotes_${VERSION//./_}_${BUILD}.swift"

echo "📝 Создание Swift файла с release notes..."

cat > "$SWIFT_FILE" << EOF
//
//  ReleaseNotes_${VERSION//./_}_${BUILD}.swift
//  LMS
//
//  Автоматически сгенерированные release notes
//  Версия: $VERSION, Build: $BUILD
//

import Foundation

extension ReleaseNewsService {
    /// Release notes для версии $VERSION (Build $BUILD)
    static let releaseNotes_${VERSION//./_}_${BUILD} = """
$(cat "$RELEASE_NOTES_PATH")
"""
    
    /// Получить release notes для текущей версии
    func getReleaseNotesForCurrentVersion() -> String? {
        if currentAppVersion == "$VERSION" && currentBuildNumber == "$BUILD" {
            return Self.releaseNotes_${VERSION//./_}_${BUILD}
        }
        return nil
    }
}
EOF

echo "✅ Swift файл создан: $SWIFT_FILE"
echo ""

# Обновляем Info.plist с флагом новой версии
echo "📝 Обновление Info.plist..."

/usr/libexec/PlistBuddy -c "Set :LMSHasNewRelease true" LMS/App/Info.plist 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :LMSHasNewRelease bool true" LMS/App/Info.plist

echo "✅ Info.plist обновлен"
echo ""

# Создаем preview для debug режима
DEBUG_PREVIEW="LMS/Features/Feed/Debug/ReleaseNewsPreview.swift"

cat > "$DEBUG_PREVIEW" << 'EOF'
//
//  ReleaseNewsPreview.swift
//  LMS
//
//  Preview для тестирования новостей о релизах
//

#if DEBUG
import SwiftUI

struct ReleaseNewsPreview: View {
    @StateObject private var releaseService = ReleaseNewsService.shared
    @State private var showingNews = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Информация о версии
                VStack(alignment: .leading, spacing: 10) {
                    Label("Версия: \(releaseService.currentAppVersion)", systemImage: "app.badge")
                    Label("Build: \(releaseService.currentBuildNumber)", systemImage: "hammer")
                    Label("Новый релиз: \(releaseService.hasNewRelease ? "Да" : "Нет")", 
                          systemImage: releaseService.hasNewRelease ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(releaseService.hasNewRelease ? .green : .gray)
                }
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Кнопки действий
                VStack(spacing: 15) {
                    Button("Симулировать новый релиз") {
                        simulateNewRelease()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Показать новость о релизе") {
                        showingNews = true
                    }
                    .buttonStyle(.bordered)
                    .disabled(!releaseService.hasNewRelease)
                    
                    Button("Очистить историю") {
                        clearHistory()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Release News Debug")
            .sheet(isPresented: $showingNews) {
                ReleaseNewsDetailView()
            }
        }
    }
    
    private func simulateNewRelease() {
        // Очищаем сохраненную версию
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedAppVersion")
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedBuildNumber")
        
        // Проверяем снова
        releaseService.checkForNewRelease()
        
        // Публикуем
        Task {
            await releaseService.publishReleaseNews()
        }
    }
    
    private func clearHistory() {
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedAppVersion")
        UserDefaults.standard.removeObject(forKey: "lastAnnouncedBuildNumber")
        UserDefaults.standard.removeObject(forKey: "currentReleaseNotes")
        releaseService.checkForNewRelease()
    }
}

struct ReleaseNewsDetailView: View {
    let releaseNotes = ReleaseNewsService.shared.getCurrentReleaseNotes()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(releaseNotes)
                    .padding()
            }
            .navigationTitle("Release Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        // Dismiss
                    }
                }
            }
        }
    }
}

struct ReleaseNewsPreview_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseNewsPreview()
    }
}
#endif
EOF

echo "✅ Debug preview создан"
echo ""

echo "🎉 Генерация новости о релизе завершена!"
echo ""
echo "📋 Что было сделано:"
echo "  1. Создан Swift файл с release notes"
echo "  2. Обновлен Info.plist с флагом новой версии"
echo "  3. Создан debug preview для тестирования"
echo ""
echo "🚀 При следующем запуске приложения:"
echo "  - Новость автоматически появится в ленте"
echo "  - Пользователи увидят уведомление о новой версии"
echo ""
echo "💡 Для тестирования в debug режиме:"
echo "  - Используйте ReleaseNewsPreview"
echo "  - Или Debug Menu → Release News Testing" 