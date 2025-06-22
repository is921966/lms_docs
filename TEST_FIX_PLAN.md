# План исправления тестов User Service

## 🎯 Цель
Исправить все 143 теста User Service и довести их до рабочего состояния.

## 📊 Текущий статус
- ✅ SimpleTest: 3/3 тестов работают
- ✅ EmailSimpleTest: 5/5 тестов работают
- ✅ EmailTest: 20/20 тестов работают ✅
- ✅ PasswordTest: 17/17 тестов работают ✅
- ✅ UserIdTest: 17/17 тестов работают ✅
- ❓ Domain модели: не проверены
- ❓ Services: не проверены
- ❓ Infrastructure: не проверены

## 🔧 План действий

### ✅ Этап 1: Value Objects - ЗАВЕРШЕН!
- ✅ SimpleTest (3 теста)
- ✅ EmailSimpleTest (5 тестов)
- ✅ EmailTest (20 тестов)
- ✅ PasswordTest (17 тестов)
- ✅ UserIdTest (17 тестов)

**Итого Value Objects: 62/62 тестов работают!** 🎉

### Этап 2: Domain модели (ТЕКУЩИЙ)
- [ ] UserTest
- [ ] RoleTest
- [ ] PermissionTest

### Этап 3: Application Services
- [ ] UserServiceTest
- [ ] AuthServiceTest

### Этап 4: Infrastructure
- [ ] UserRepositoryTest (Integration)
- [ ] AuthenticationTest (Feature)
- [ ] UserManagementTest (Feature)

## 📝 Уроки, извлеченные

### Value Objects:
1. **Email**:
   - Нормализация (trim, lowercase) должна быть до валидации
   - Необходимо реализовать JsonSerializable для json_encode()
   - Добавлены методы hasDnsRecord() и isDisposable()

2. **Password**:
   - Многие методы невозможны с хешами (getStrength, validateAgainstPolicies)
   - Проверка последовательных символов должна быть умной (не блокировать "123")
   - wasUsedBefore() работает только с точными совпадениями хешей

3. **UserId**:
   - Ramsey UUID принимает форматы без дефисов - нужна дополнительная валидация
   - getLegacyId() не может точно восстановить оригинальный ID из UUID
   - Версия UUID не должна валидироваться строго

## 🚀 Команды для запуска

```bash
# Все Value Objects (проверено - работает!)
docker run --rm -v $(pwd):/app -w /app --network lms_docs_lms_network php:8.2-cli php vendor/bin/phpunit tests/Unit/User/Domain/ValueObjects/

# Domain модели
docker run --rm -v $(pwd):/app -w /app --network lms_docs_lms_network php:8.2-cli php vendor/bin/phpunit tests/Unit/User/Domain/

# Конкретный тест
docker run --rm -v $(pwd):/app -w /app --network lms_docs_lms_network php:8.2-cli php vendor/bin/phpunit tests/Unit/User/Domain/UserTest.php
```

## 📊 Общий прогресс
- [x] SimpleTest (3/3) ✅
- [x] EmailSimpleTest (5/5) ✅
- [x] Value Objects (54/54) ✅
  - EmailTest (20/20)
  - PasswordTest (17/17)
  - UserIdTest (17/17)
- [ ] Domain Models (0/?)
- [ ] Services (0/?)
- [ ] Infrastructure (0/?)

**Всего исправлено: 62/143 тестов (43%)** 📈

## 🎯 Следующий шаг
Переходим к Domain моделям - начнем с UserTest! 