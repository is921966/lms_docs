# Archive Checklist - Build 213 (v2.2.0)

## 📋 Pre-Archive Checklist

### ✅ Подготовка
- [x] Версия обновлена: 2.2.0
- [x] Build number обновлен: 213
- [x] Release notes подготовлены
- [ ] Все тесты пройдены
- [ ] Нет критических warnings в Xcode
- [ ] Проверен на симуляторе

### ✅ Конфигурация
- [ ] Схема: LMS (Release)
- [ ] Destination: Generic iOS Device
- [ ] Certificates и Provisioning Profiles актуальны
- [ ] App Groups настроены корректно

## 🛠 Команды для сборки

### 1. Очистка проекта
```bash
xcodebuild clean -scheme LMS
```

### 2. Создание архива
```bash
xcodebuild archive \
  -scheme LMS \
  -destination "generic/platform=iOS" \
  -archivePath ./build/LMS_v2.2.0_b213.xcarchive \
  CODE_SIGNING_REQUIRED=YES
```

### 3. Экспорт IPA
```bash
xcodebuild -exportArchive \
  -archivePath ./build/LMS_v2.2.0_b213.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

## 📱 TestFlight Submission

### ✅ Pre-submission
- [ ] Archive создан успешно
- [ ] IPA файл сгенерирован
- [ ] Проверена подпись кода
- [ ] App Store Connect доступен

### ✅ Submission Info
- **What's New**: См. TESTFLIGHT_RELEASE_v2.2.0_build213.md
- **Test Information**: 
  - Тестовый аккаунт: admin@tsum.ru / Admin123
  - Основной фокус: Модуль оргструктуры и Cmi5 улучшения
- **Beta App Review**: Не требуется

### ✅ Post-submission
- [ ] Build появился в App Store Connect
- [ ] Build processing завершен
- [ ] Тестеры добавлены
- [ ] Уведомления отправлены

## 🚀 Команды быстрого запуска

### Полный процесс одной командой:
```bash
# Из директории LMS_App/LMS
./scripts/create-testflight-build.sh 2.2.0 213
```

### Проверка статуса:
```bash
xcrun altool --list-apps \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

## ⚠️ Troubleshooting

### Если архив не создается:
1. Проверьте сертификаты: `security find-identity -p codesigning`
2. Обновите профили: Xcode → Preferences → Accounts → Download Manual Profiles
3. Очистите DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Если upload не работает:
1. Проверьте API ключи App Store Connect
2. Убедитесь в правильности Bundle ID
3. Проверьте лимиты TestFlight (10,000 тестеров)

## 📊 Финальная проверка
- [ ] Build загружен в TestFlight
- [ ] Статус: Ready to Test
- [ ] Release notes отображаются корректно
- [ ] Можно установить на устройство

---
**Время начала**: ___________  
**Время завершения**: ___________  
**Выполнил**: ___________ 