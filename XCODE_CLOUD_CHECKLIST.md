# ✅ Xcode Cloud Pre-flight Checklist

## 🔍 Быстрая проверка готовности:

### ✅ Технические требования:
- [x] Xcode 13+ (У вас: 16.4)
- [x] macOS 12+ (У вас: macOS 14+) 
- [x] Проект на GitHub ✅
- [x] Bundle ID: `ru.tsum.lms.igor` ✅
- [x] Схема проекта сделана Shared ✅

### ❓ Требуют проверки:

#### 1. Apple Developer Account
- [ ] Активная подписка Apple Developer Program ($99/год)?
- [ ] Или есть доступ через команду?

Проверить: https://developer.apple.com/account

#### 2. App Store Connect
- [ ] Приложение создано в App Store Connect?
- [ ] Bundle ID совпадает?

Проверить: https://appstoreconnect.apple.com

#### 3. Xcode Settings
- [ ] Apple ID добавлен в Xcode?
- [ ] Team выбрана в проекте?

Проверить: Xcode → Settings → Accounts

#### 4. Условия использования
- [ ] Приняты условия Xcode Cloud?

Проверить: https://appstoreconnect.apple.com → Agreements

## 🚀 Если все галочки стоят:

### Попробуйте эти методы по порядку:

1. **⌘+9** → Ищите вкладку **Cloud**
2. **⌘+Shift+O** → Window → Organizer → Cloud
3. **Product → Xcode Cloud** (если появилось)
4. Через **App Store Connect** веб-интерфейс

## ⚠️ Частые проблемы:

### "Не вижу Xcode Cloud"
- Перезапустите Xcode
- Re-login в Apple ID
- Проверьте подписку Developer Program

### "Cloud неактивен/серый"
- Сделайте схему Shared ✅ (уже сделано)
- Убедитесь что проект компилируется
- Проверьте Team ID в настройках

### "Нет доступа"
- Нужна активная подписка Apple Developer
- Или приглашение в команду с правами

## 💡 Альтернативное решение:

Если Xcode Cloud недоступен, у вас есть отличный **GitHub Actions**, который:
- ✅ Уже настроен и работает
- ✅ Бесплатный для вашего проекта
- ✅ Загружает в TestFlight автоматически
- ✅ Запускается при каждом push

---

**Вопрос**: Какие пункты из чеклиста у вас НЕ отмечены? 