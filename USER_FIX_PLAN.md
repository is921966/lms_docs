# План исправления User Domain Model

## 🎯 Проблемы

### 1. Конструктор
- Тесты используют `new User()`, но класс использует фабричный метод `create()`
- Нужно либо изменить тесты, либо добавить публичный конструктор

### 2. Отсутствующие методы
- `deactivate()` / `isActive()`
- `verifyPassword()`
- `isEmailVerified()`
- `addRole()` / `syncRoles()` (есть assignRole)
- `hasTwoFactorEnabled()` / `enableTwoFactor()` / `disableTwoFactor()`
- `changeEmail()`
- `syncWithLdap()`
- `isDeleted()` / `getDeletedAt()`
- `getSuspensionReason()` / `getSuspendedUntil()` / `isSuspended()`
- `getDepartment()` / `getMiddleName()` / `getPhone()`
- `isLdapUser()` / `getLdapSyncedAt()`
- `getLastLoginIp()` / `getLastUserAgent()` / `getLoginCount()`
- `getTwoFactorSecret()`

### 3. Проблемы с LDAP
- `createFromLdap()` ожидает другие поля в массиве
- Нужно адаптировать под реальные LDAP поля

### 4. Проблемы с событиями
- События записываются, но не все методы их генерируют

## 📋 План действий

### Вариант 1: Минимальные изменения (рекомендую)
1. Изменить тесты под существующий API
2. Добавить только критически важные методы
3. Использовать фабричные методы вместо конструктора

### Вариант 2: Полное соответствие тестам
1. Добавить публичный конструктор
2. Реализовать все 20+ отсутствующих методов
3. Риск: большие изменения в production коде

## 🚀 Рекомендация

Начать с Варианта 1 - адаптировать тесты под существующий код, добавляя только необходимые методы. 