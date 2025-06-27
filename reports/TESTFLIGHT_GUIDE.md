# Руководство по развертыванию в TestFlight

## 📱 О TestFlight

TestFlight - официальная платформа Apple для бета-тестирования iOS приложений. Позволяет распространять тестовые версии приложения среди внутренних и внешних тестировщиков.

## 🚀 Быстрый старт

### 1. Запуск тестов и сборки
```bash
# Запуск только тестов
fastlane test

# Сборка и загрузка в TestFlight
fastlane beta
```

### 2. Мониторинг процесса
```bash
# Используйте скрипт мониторинга
./monitor-testflight-build.sh
```

## 📋 Предварительные требования

### Обязательные:
- ✅ Apple Developer аккаунт ($99/год)
- ✅ Xcode с валидными сертификатами
- ✅ Fastlane установлен (`brew install fastlane`)
- ✅ Чистое git дерево (все изменения закоммичены)

### Рекомендуемые:
- 📱 Устройство для тестирования
- 📧 Email для получения уведомлений
- 🔑 App Store Connect API ключ (для CI/CD)

## 🔧 Процесс сборки

### Автоматические шаги Fastlane:
1. **Проверка git статуса** - убеждается, что все закоммичено
2. **Получение номера сборки** - запрашивает последний номер из TestFlight
3. **Инкремент сборки** - увеличивает номер на 1
4. **Компиляция** - собирает приложение в Release конфигурации
5. **Создание .ipa** - упаковывает приложение
6. **Загрузка** - отправляет в App Store Connect
7. **Обновление git** - коммитит новый номер сборки

### Время выполнения:
- 🏗️ Локальная сборка: 5-10 минут
- 📤 Загрузка: 2-5 минут
- 🍎 Обработка Apple: 10-15 минут
- **Итого**: ~20-30 минут до доступности в TestFlight

## 📝 Changelog для тестировщиков

### Где указывать:
1. **Переменная окружения**:
   ```bash
   export TESTFLIGHT_CHANGELOG="Описание изменений"
   fastlane beta
   ```

2. **Файл TESTFLIGHT_CHANGELOG.md**:
   ```bash
   # Создайте файл с описанием
   echo "• Новая функция X" > TESTFLIGHT_CHANGELOG.md
   
   # Fastlane автоматически его подхватит
   export TESTFLIGHT_CHANGELOG="$(cat TESTFLIGHT_CHANGELOG.md)"
   fastlane beta
   ```

3. **Автоматически из git**:
   - Если не указан changelog, берутся последние 5 коммитов

## 👥 Управление тестировщиками

### Внутренние тестировщики (до 100 человек):
- Сотрудники с доступом к App Store Connect
- Мгновенный доступ после обработки билда
- Не требуют review от Apple

### Внешние тестировщики (до 10,000 человек):
- Любые пользователи с email
- Требуют Beta App Review (1-2 дня)
- Могут быть организованы в группы

### Добавление тестировщиков:
1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Выберите приложение → TestFlight
3. Добавьте email тестировщиков
4. Они получат приглашение установить TestFlight

## 🐛 Решение проблем

### Ошибка: "Code signing is required"
```bash
# Проверьте сертификаты
security find-identity -v -p codesigning

# Обновите профили
fastlane match appstore --readonly
```

### Ошибка: "No profiles found"
```bash
# Создайте/обновите provisioning profiles
fastlane match appstore
```

### Ошибка: "Git repository is dirty"
```bash
# Закоммитьте или отмените изменения
git status
git add .
git commit -m "Prepare for TestFlight"
# или
git stash
```

## 🔐 CI/CD интеграция

### GitHub Actions пример:
```yaml
- name: Build and Deploy to TestFlight
  env:
    APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_API_KEY_ID }}
    APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APP_STORE_API_ISSUER_ID }}
    APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.APP_STORE_API_KEY }}
    TESTFLIGHT_CHANGELOG: ${{ github.event.head_commit.message }}
  run: |
    fastlane beta
```

## 📊 Метрики и аналитика

### Что отслеживать:
- 📈 Количество установок
- 💥 Краши и их частота
- 📱 Версии iOS и устройства
- ⏱️ Время использования
- 💬 Обратная связь от тестировщиков

### Где смотреть:
- App Store Connect → TestFlight → Статистика
- Xcode → Organizer → Crashes
- TestFlight app → Обратная связь

## ✅ Чеклист перед релизом

- [ ] Все тесты проходят (`fastlane test`)
- [ ] Версия и build number обновлены
- [ ] Changelog подготовлен
- [ ] Git дерево чистое
- [ ] Сертификаты валидны
- [ ] Достаточно места на диске (>10GB)

## 🎯 Best Practices

1. **Регулярные релизы** - минимум раз в неделю
2. **Информативный changelog** - что нового для тестировщиков
3. **Группы тестировщиков** - разделяйте по функциям
4. **Быстрая реакция** - отвечайте на обратную связь
5. **Версионирование** - используйте semantic versioning

## 📞 Полезные ссылки

- [App Store Connect](https://appstoreconnect.apple.com)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Fastlane Docs](https://docs.fastlane.tools)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**Последнее обновление**: 27 июня 2025  
**Версия документа**: 1.0.0 