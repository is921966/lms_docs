# Анализ размеров файлов проекта

## 🚨 Проблемные файлы (> 500 строк)

### Domain слой:
1. **User.php** - 677 строк ❌ КРИТИЧНО
   - Рекомендация: Разбить на трейты или выделить поведение в отдельные классы
   - Возможные выделения: UserAuthentication, UserRoles, UserProfile, UserMetadata

### Infrastructure слой:
2. **LdapService.php** - 654 строки ❌ КРИТИЧНО
   - Рекомендация: Разделить на LdapAuthenticator, LdapUserImporter, LdapSynchronizer

### Application слой:
3. **AuthService.php** - 584 строки ❌ КРИТИЧНО
   - Рекомендация: Выделить TokenService, TwoFactorService, PasswordResetService

## ⚠️ Файлы требующие внимания (300-500 строк)

1. **UserService.php** - 496 строк
2. **UserController.php** - 454 строки
3. **WorkingAuthService.php** - 358 строк (дубликат?)
4. **UserRepository.php** - 319 строк
5. **AuthController.php** - 318 строк
6. **Password.php** - 303 строки

## ✅ Оптимальные файлы (< 300 строк)

Большинство файлов имеют приемлемый размер для LLM.

## 📊 Рекомендации по рефакторингу

### 1. User.php (677 строк) → разбить на:
- `User.php` - основная модель (< 200 строк)
- `UserAuthenticationTrait.php` - методы аутентификации
- `UserRolesTrait.php` - управление ролями
- `UserProfileTrait.php` - профиль пользователя
- `UserMetadataTrait.php` - метаданные и статистика

### 2. LdapService.php (654 строки) → разбить на:
- `LdapAuthenticator.php` - только аутентификация
- `LdapUserImporter.php` - импорт пользователей
- `LdapSynchronizer.php` - синхронизация данных
- `LdapConfiguration.php` - конфигурация

### 3. AuthService.php (584 строки) → разбить на:
- `AuthService.php` - основная аутентификация (< 200 строк)
- `TokenService.php` - работа с JWT токенами
- `TwoFactorService.php` - двухфакторная аутентификация
- `PasswordResetService.php` - сброс паролей

## 🎯 Целевые метрики

- **Оптимально**: 50-150 строк на файл
- **Приемлемо**: 150-300 строк на файл
- **Требует рефакторинга**: > 300 строк
- **Критично для LLM**: > 500 строк

## 🔧 План действий

1. **Sprint 4**: Рефакторинг больших файлов
2. **Приоритет**: User.php, LdapService.php, AuthService.php
3. **Метод**: Extract Class, Extract Trait, Single Responsibility
4. **Тестирование**: Сохранить 100% покрытие 