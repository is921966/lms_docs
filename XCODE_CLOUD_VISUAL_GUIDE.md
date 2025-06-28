# 🎯 Визуальная инструкция: Где найти Xcode Cloud

## 📍 Метод 1: Report Navigator (РЕКОМЕНДУЕМЫЙ)

### Шаг 1: Откройте Report Navigator
```
⌘ + 9
```
Или: View → Navigators → Reports

### Шаг 2: Найдите вкладки вверху
Ищите горизонтальные вкладки:
```
[ Build ] [ Tests ] [ Cloud ] ← Кликните сюда!
```

Если вкладки **Cloud** нет, смотрите другие методы.

## 📍 Метод 2: Через Organizer

### Шаг 1: Откройте Organizer
```
⌘ + Shift + O
```
Или: Window → Organizer

### Шаг 2: Найдите вкладку Cloud
В верхней части окна:
```
[ Archives ] [ Crashes ] [ Cloud ] [ TestFlight ]
```

## 📍 Метод 3: Через настройки проекта

### Шаг 1: Выберите проект
1. В левой панели кликните на **LMS** (синяя иконка)
2. Выберите проект **LMS** (не target)

### Шаг 2: Ищите Xcode Cloud
1. В центральной панели прокрутите вниз
2. Может быть секция **"Xcode Cloud"**
3. Или кнопка **"Set up Xcode Cloud"**

## 📍 Метод 4: Через схему

### Шаг 1: Edit Scheme
```
⌘ + Shift + ,
```
Или: Product → Scheme → Edit Scheme

### Шаг 2: Найдите Cloud секцию
В левой панели может быть:
- Build
- Run
- Test
- Profile
- Analyze
- Archive
- **Cloud** ← Если есть

## 🚨 Если ничего не помогает

### Проверьте эти требования:

1. **Apple Developer Program**
   - Статус должен быть активен
   - https://developer.apple.com/account

2. **Xcode авторизация**
   - Xcode → Settings (⌘+,) → Accounts
   - Должен быть Apple ID с правами разработчика

3. **Принятие условий**
   - Войдите в App Store Connect
   - Может потребоваться принять условия Xcode Cloud

4. **Версия Xcode**
   - Требуется Xcode 13+
   - У вас: 16.4 ✅

## 🔄 Альтернатива: Настройка через Web

1. Откройте https://appstoreconnect.apple.com
2. Войдите с Apple ID
3. Перейдите в **"My Apps"**
4. Создайте приложение если нет:
   - Bundle ID: `ru.tsum.lms.igor`
5. В приложении найдите **Xcode Cloud** в боковом меню
6. Нажмите **"Get Started"**
7. Следуйте инструкциям для связи с GitHub

## 💡 Подсказки

- **Не видите Cloud?** Возможно нужно:
  - Перезапустить Xcode
  - Обновить Apple ID credentials
  - Принять новые условия в App Store Connect

- **Серые/неактивные пункты?** Проверьте:
  - Схема должна быть Shared ✅
  - Проект должен компилироваться
  - Должен быть настроен Bundle ID

## ❓ Что вы видите?

Пожалуйста, сообщите:
1. Есть ли вкладка **Cloud** в Report Navigator (⌘+9)?
2. Что видите в Window → Organizer?
3. Есть ли опции Xcode Cloud в настройках проекта? 