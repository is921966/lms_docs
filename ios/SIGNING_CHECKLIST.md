# ✅ Чек-лист настройки подписи в Xcode

После добавления App target, проверьте следующее в Xcode:

## 1. Выбор target и Team

- [ ] В левой панели видите иконку приложения **LMS**
- [ ] Кликнули на неё
- [ ] Справа открылась панель с вкладками
- [ ] Выбрали вкладку **Signing & Capabilities**

## 2. Настройка автоматической подписи

- [ ] Поставили галочку **☑️ Automatically manage signing**
- [ ] В поле **Team** выбрали: **Igor Shirokov (Personal Team)** или **N85286S93X**
- [ ] Bundle Identifier показывает: **ru.tsum.lms**

## 3. Проверка статуса

После включения автоматической подписи вы должны увидеть:

### ✅ Если всё хорошо:
- Статус: **Waiting for first build to create provisioning profile**
- Или: **Provisioning Profile: Xcode Managed Profile**
- Signing Certificate: **Apple Development: ваш email**

### ❌ Если есть ошибки:
- **No account**: Добавьте Apple ID в Xcode → Settings → Accounts
- **No devices registered**: Это нормально для первого раза
- **Failed to create provisioning profile**: Проверьте Bundle ID

## 4. Первый запуск

- [ ] Выберите симулятор (например, iPhone 15)
- [ ] Нажмите **Run** (▶️)
- [ ] Дождитесь сборки

## 5. Что должно произойти автоматически

При первом запуске Xcode автоматически:
1. ✅ Создаст Development Certificate
2. ✅ Создаст Provisioning Profile
3. ✅ Зарегистрирует ваш Mac для разработки
4. ✅ Настроит все необходимые entitlements

## 🚨 Если ничего не происходит

1. **Убедитесь, что вошли в Xcode**:
   - Xcode → Settings → Accounts
   - Должен быть добавлен ваш Apple ID
   - Рядом должно быть написано "Apple Developer Program"

2. **Попробуйте собрать проект**:
   - Product → Build (Cmd+B)
   - Xcode создаст сертификаты при первой сборке

3. **Проверьте ошибки**:
   - Посмотрите на красные иконки в Signing & Capabilities
   - Прочитайте текст ошибки - обычно там есть кнопка "Fix Issue"

## 📸 Что вы должны видеть

В секции **Signing** должно быть:
```
☑️ Automatically manage signing

Team: Igor Shirokov (Personal Team)
Bundle Identifier: ru.tsum.lms
Provisioning Profile: Xcode Managed Profile
Signing Certificate: Apple Development: igor.shirokov@mac.com (XXXXXXXXXX)
```

---

**Если всё настроено правильно**, попробуйте запустить проект (▶️) - это заставит Xcode создать все необходимые сертификаты. 