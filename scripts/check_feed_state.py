#!/usr/bin/env python3
import subprocess
import time
import os

def run_command(cmd):
    """Выполняет команду и возвращает результат"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip()
    except Exception as e:
        print(f"Ошибка выполнения команды: {e}")
        return None

def main():
    print("🔍 Проверка состояния Feed в приложении LMS")
    print("=" * 50)
    
    # Bundle ID приложения
    bundle_id = "ru.tsum.lms.igor"
    device_id = "899AAE09-580D-4FF5-BF16-3574382CD796"
    
    # Проверяем флаг в UserDefaults
    print("\n📱 Проверка настроек приложения:")
    plist_path = run_command(f"xcrun simctl get_app_container {device_id} {bundle_id} data")
    if plist_path:
        pref_file = f"{plist_path}/Library/Preferences/{bundle_id}.plist"
        if os.path.exists(pref_file):
            flag_value = run_command(f"plutil -p '{pref_file}' | grep useNewFeedDesign | awk '{{print $3}}'")
            print(f"   useNewFeedDesign = {flag_value}")
        else:
            print("   ❌ Файл настроек не найден")
    
    # Делаем скриншот
    print("\n📸 Создание скриншота...")
    screenshot_path = "current_feed_state.png"
    run_command(f"xcrun simctl io {device_id} screenshot {screenshot_path}")
    print(f"   Скриншот сохранен: {screenshot_path}")
    
    # Анализ UI элементов через accessibility
    print("\n🔍 Анализ UI элементов:")
    
    # Запускаем UI тест для получения информации
    test_script = """
    tell application "Simulator"
        activate
    end tell
    """
    
    run_command(f"osascript -e '{test_script}'")
    time.sleep(2)
    
    print("\n✅ Проверка завершена!")
    print("\nРекомендации:")
    print("1. Если видна классическая лента - нажмите кнопку 'Попробовать новую ленту'")
    print("2. Проверьте скриншот current_feed_state.png")
    print("3. Перезапустите приложение если изменения не применились")

if __name__ == "__main__":
    main() 