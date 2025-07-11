# TestFlight Preparation Checklist

**Date**: July 7, 2025  
**Sprint**: 31 (Day 5/5)  
**Status**: 🚀 Ready for TestFlight Preparation

## ✅ Prerequisites Completed

- [x] 100% Unit Tests Pass (223/223)
- [x] CI/CD Pipeline Configured
- [x] GitHub Actions Working
- [x] Release Configuration Exists
- [x] Code Signing Configured
- [x] Bundle ID Set: `ru.tsum.lms.igor`

## 📋 TestFlight Submission Checklist

### 1. App Configuration ✅
- [x] Bundle Identifier: `ru.tsum.lms.igor`
- [x] Version: 1.0
- [x] Build Number: Auto-incremented by CI/CD
- [x] Minimum iOS Version: 17.0
- [x] Device Support: iPhone only

### 2. Code Signing 🔐
- [x] Development Certificate
- [x] Distribution Certificate
- [ ] Provisioning Profile for App Store
- [ ] Push Notification Certificate (if needed)

### 3. App Store Connect Setup 📱
- [ ] Create App in App Store Connect
- [ ] Configure App Information:
  - [ ] App Name: "ЦУМ LMS"
  - [ ] Primary Language: Russian
  - [ ] Bundle ID: Link to `ru.tsum.lms.igor`
  - [ ] SKU: Generate unique SKU

### 4. TestFlight Information 📝
- [ ] What to Test:
  ```
  Основные функции для тестирования:
  1. Вход в систему (mock авторизация)
  2. Просмотр курсов и программ обучения
  3. Отслеживание прогресса
  4. Система обратной связи (shake для отзыва)
  5. Навигация по всем модулям
  ```

- [ ] Test Information:
  ```
  Тестовые учетные данные:
  - Студент: Нажмите "Войти как студент"
  - Администратор: Нажмите "Войти как администратор"
  
  Для отправки отзыва потрясите устройство.
  ```

### 5. App Metadata 📄
- [ ] App Description:
  ```
  ЦУМ LMS - корпоративная система обучения для сотрудников ЦУМ.
  
  Функции:
  • Персонализированные программы обучения
  • Отслеживание прогресса
  • Управление компетенциями
  • Онбординг новых сотрудников
  • Аналитика обучения
  ```

- [ ] Keywords:
  ```
  обучение, корпоративный университет, LMS, ЦУМ, 
  развитие, компетенции, онбординг, курсы
  ```

- [ ] Screenshots:
  - [ ] 6.5" iPhone (1284 x 2778)
  - [ ] 5.5" iPhone (1242 x 2208)

### 6. Build & Upload Process 🔨

#### Manual Process:
```bash
# 1. Archive the app
xcodebuild archive \
  -scheme LMS \
  -configuration Release \
  -archivePath ./build/LMS.xcarchive

# 2. Export for App Store
xcodebuild -exportArchive \
  -archivePath ./build/LMS.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist

# 3. Upload to App Store Connect
xcrun altool --upload-app \
  -f ./build/LMS.ipa \
  -u YOUR_APPLE_ID \
  -p YOUR_APP_SPECIFIC_PASSWORD
```

#### Automated Process (Already Configured):
```bash
# Use fastlane
fastlane beta
```

### 7. Internal Testing Setup 🧪
- [ ] Add Internal Testers (up to 100)
- [ ] Create Test Groups:
  - [ ] Development Team
  - [ ] QA Team
  - [ ] Stakeholders

### 8. External Testing Setup 👥
- [ ] Prepare Beta Test Information
- [ ] Create External Test Groups
- [ ] Set Maximum Testers (up to 10,000)
- [ ] Configure Test Duration

## 🚀 Quick Start Commands

### Build for TestFlight:
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Build and archive
fastlane beta

# Or manually
xcodebuild -scheme LMS -configuration Release archive
```

### Check Build Status:
```bash
# View recent uploads
xcrun altool --list-apps \
  -u YOUR_APPLE_ID \
  -p YOUR_APP_SPECIFIC_PASSWORD
```

## 📊 Current Readiness Status

| Component | Status | Notes |
|-----------|--------|-------|
| Code Quality | ✅ | 100% tests pass |
| UI Polish | ✅ | All modules integrated |
| Performance | ✅ | Optimized |
| Stability | ✅ | No known crashes |
| Documentation | ✅ | README updated |
| Certificates | ⚠️ | Need App Store profile |
| App Store Connect | ❌ | Need to create app |
| Metadata | ⚠️ | Need screenshots |

## 🎯 Next Steps

1. **Immediate** (Today):
   - [ ] Create app in App Store Connect
   - [ ] Generate App Store provisioning profile
   - [ ] Prepare screenshots

2. **Before Upload**:
   - [ ] Update version number if needed
   - [ ] Final testing on real device
   - [ ] Review crash logs

3. **After Upload**:
   - [ ] Submit for Beta App Review
   - [ ] Add internal testers
   - [ ] Monitor feedback

## 📝 Release Notes Template

```
Версия 1.0 - Первый релиз для TestFlight

Что нового:
• Базовая функциональность LMS
• Просмотр курсов и программ
• Отслеживание прогресса обучения
• Система обратной связи
• Поддержка mock авторизации

Известные ограничения:
• Реальная авторизация будет добавлена позже
• Некоторые функции находятся в разработке

Пожалуйста, отправляйте отзывы через встроенную систему (потрясите устройство).
```

## 🔗 Useful Links

- [App Store Connect](https://appstoreconnect.apple.com)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---
**Status**: Ready for TestFlight submission pending App Store Connect setup 