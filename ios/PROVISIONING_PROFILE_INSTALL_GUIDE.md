# 📱 Руководство по установке Provisioning Profile

## Что такое Provisioning Profile?

Provisioning Profile - это файл, который связывает:
- Ваше приложение (Bundle ID)
- Ваши сертификаты разработчика
- Устройства для тестирования (для Development профиля)
- Разрешения приложения (capabilities)

## 📥 Где скачать Provisioning Profile

1. Войдите в [Apple Developer Portal](https://developer.apple.com)
2. Перейдите в **Certificates, Identifiers & Profiles**
3. Выберите **Profiles** в левом меню
4. Найдите ваш профиль (например, "LMS Development")
5. Нажмите на него и затем **Download**

## 🔧 Способы установки

### Способ 1: Двойной клик (Рекомендуется)
1. Найдите скачанный файл `LMS_Development.mobileprovision`
   - Обычно в папке `~/Downloads` (Загрузки)
2. **Дважды кликните** на файл
3. Файл автоматически откроется в Xcode и установится
4. Никаких сообщений может не появиться - это нормально

### Способ 2: Через Xcode автоматически
1. Откройте **Xcode**
2. Откройте ваш проект: `ios/LMS/LMS.xcodeproj`
3. Выберите проект в навигаторе (верхний элемент)
4. Перейдите на вкладку **Signing & Capabilities**
5. Поставьте галочку **Automatically manage signing**
6. Выберите ваш Team
7. Xcode автоматически создаст и скачает нужные профили

### Способ 3: Перетаскивание в Xcode
1. Откройте **Xcode**
2. Откройте любой проект или создайте новый
3. Перетащите файл `.mobileprovision` в окно Xcode
4. Профиль установится автоматически

### Способ 4: Ручная установка (для опытных)
```bash
# Скопируйте файл в нужную директорию
cp ~/Downloads/LMS_Development.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
```

## ✅ Как проверить, что профиль установлен

### В Finder:
1. Нажмите `Cmd + Shift + G`
2. Введите: `~/Library/MobileDevice/Provisioning Profiles`
3. Вы увидите файлы с именами вида `UUID.mobileprovision`

### В Xcode:
1. Откройте ваш проект
2. Выберите проект в навигаторе
3. Перейдите на вкладку **Signing & Capabilities**
4. В разделе **Signing** вы увидите:
   - ✅ Provisioning Profile: LMS Development
   - ✅ Signing Certificate: Apple Development: Your Name

### Через терминал:
```bash
# Запустите скрипт проверки
./ios/check-provisioning.sh
```

## ❌ Частые проблемы

### "Provisioning profile doesn't include signing certificate"
**Решение**: Профиль создан без вашего сертификата
1. Зайдите в Apple Developer Portal
2. Отредактируйте профиль
3. Добавьте ваш сертификат
4. Скачайте и установите заново

### "No provisioning profiles matching"
**Решение**: Bundle ID не совпадает
1. Проверьте Bundle ID в Xcode
2. Убедитесь, что он совпадает с ID в профиле
3. Или включите Automatically manage signing

### "Provisioning profile has expired"
**Решение**: Профиль истёк
1. Зайдите в Apple Developer Portal
2. Обновите профиль
3. Скачайте и установите новую версию

## 📍 Где хранятся установленные профили

```
~/Library/MobileDevice/Provisioning Profiles/
```

Каждый профиль сохраняется с именем вида:
```
a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6.mobileprovision
```

## 🔄 Автоматическое управление vs Ручное

### Автоматическое (рекомендуется для начала):
- ✅ Xcode сам создаёт и обновляет профили
- ✅ Не нужно скачивать вручную
- ✅ Автоматически добавляет новые устройства
- ❌ Меньше контроля над настройками

### Ручное:
- ✅ Полный контроль над настройками
- ✅ Можно использовать в CI/CD
- ✅ Точное управление capabilities
- ❌ Нужно обновлять вручную

## 💡 Советы

1. **Для разработки** используйте Automatic signing
2. **Для CI/CD** используйте Manual signing
3. **Храните профили** в системе контроля версий (для CI/CD)
4. **Обновляйте регулярно** - профили истекают через год

## 🆘 Если ничего не работает

1. Удалите все старые профили:
   ```bash
   rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
   ```

2. В Xcode:
   - Xcode → Preferences → Accounts
   - Выберите ваш аккаунт
   - Нажмите "Download Manual Profiles"

3. Перезапустите Xcode

4. Включите Automatically manage signing 