# Лучшие практики рефакторинга для LLM-разработки

## Когда нужен рефакторинг

### Метрики размера файлов
```
✅ Оптимально: 50-150 строк
⚠️  Приемлемо: 150-300 строк  
🚨 Требует рефакторинга: > 300 строк
❌ Критично: > 500 строк
```

### Признаки необходимости рефакторинга
- Файл больше 300 строк
- Класс имеет более 3-4 ответственностей
- LLM начинает "забывать" контекст
- Увеличивается время генерации ответов
- Появляются ошибки из-за неполного анализа

## Техники рефакторинга

### 1. Извлечение трейтов (для Domain моделей)

**Когда использовать:**
- Модель содержит группы связанных методов
- Методы можно логически сгруппировать
- Группы методов используют общие свойства

**Пример из проекта:**
```php
// Было: User.php (677 строк)
class User {
    // Все методы в одном классе
    private function validatePassword() {...}
    private function hashPassword() {...}
    private function checkPasswordStrength() {...}
    // ... еще 600 строк
}

// Стало: User.php (182 строки)
class User {
    use UserAuthenticationTrait;  // Методы аутентификации
    use UserProfileTrait;         // Методы профиля
    use UserRoleManagementTrait;  // Управление ролями
    use UserStatusManagementTrait; // Управление статусом
    
    // Только core логика
}
```

### 2. Создание специализированных сервисов (для Application слоя)

**Когда использовать:**
- Сервис выполняет несколько разных задач
- Можно выделить независимые области функциональности
- Части функциональности могут использоваться отдельно

**Пример из проекта:**
```php
// Было: AuthService.php (584 строки)
class AuthService {
    public function generateToken() {...}
    public function refreshToken() {...}
    public function blacklistToken() {...}
    public function enableTwoFactor() {...}
    public function verifyTwoFactorCode() {...}
    public function requestPasswordReset() {...}
    // ... все в одном классе
}

// Стало: несколько focused сервисов
AuthService.php (289 строк) - координатор
├── TokenService.php (111 строк) - JWT операции
├── TwoFactorAuthService.php (151 строка) - 2FA
└── PasswordResetService.php (88 строк) - сброс пароля
```

### 3. Композиция сервисов (для Infrastructure слоя)

**Когда использовать:**
- Инфраструктурный сервис работает с внешней системой
- Есть разные аспекты работы (соединение, маппинг, бизнес-логика)
- Части могут переиспользоваться

**Пример из проекта:**
```php
// Было: LdapService.php (654 строки)
class LdapService {
    private function connect() {...}
    private function bind() {...}
    private function search() {...}
    private function mapAttributes() {...}
    private function getUserGroups() {...}
    // ... все вместе
}

// Стало: композиция сервисов
LdapService.php (290 строк) - фасад
├── LdapConnectionService.php (149 строк) - соединения
├── LdapDataMapper.php (162 строки) - маппинг данных
└── LdapGroupService.php (122 строки) - работа с группами
```

## Пошаговый процесс рефакторинга

### 1. Анализ
```bash
# Найти большие файлы
make check-file-sizes

# Или
find src -name "*.php" -exec wc -l {} \; | awk '$1 > 300 {print}' | sort -nr
```

### 2. Планирование
- Определить логические группы функциональности
- Выбрать подходящую технику рефакторинга
- Спланировать новую структуру файлов

### 3. Проверка тестов ДО рефакторинга
```bash
# ОБЯЗАТЕЛЬНО! Убедиться что все работает
make test-unit
```

### 4. Создание новых файлов
```bash
# Создать директории если нужно
mkdir -p src/User/Domain/Traits
mkdir -p src/User/Application/Service/Auth

# Создать новые файлы
touch src/User/Domain/Traits/UserAuthenticationTrait.php
```

### 5. Перенос кода
- Переносить логическими блоками
- Сохранять публичные интерфейсы
- Обновлять use statements

### 6. Обновление оригинального файла
```bash
# Временный файл для безопасности
cp OriginalService.php OriginalService.php.bak

# Работа с рефакторенной версией
mv RefactoredService.php OriginalService.php
```

### 7. Проверка тестов ПОСЛЕ рефакторинга
```bash
# КРИТИЧНО! Все тесты должны проходить
make test-unit

# Если тесты падают - исправить немедленно
```

### 8. Очистка
```bash
# Удалить временные файлы
rm *.bak
rm Refactored*.php
```

## Чек-лист рефакторинга

- [ ] Файл больше 300 строк?
- [ ] Определены логические группы функциональности?
- [ ] Выбрана подходящая техника рефакторинга?
- [ ] Все тесты проходят ДО рефакторинга?
- [ ] Созданы новые файлы/директории?
- [ ] Код перенесен с сохранением интерфейсов?
- [ ] Обновлены все импорты и зависимости?
- [ ] Все тесты проходят ПОСЛЕ рефакторинга?
- [ ] Удалены временные файлы?
- [ ] Обновлена документация?

## Частые ошибки

### ❌ Рефакторинг без тестов
```bash
# НЕПРАВИЛЬНО
# Просто разбить файл и надеяться на лучшее

# ПРАВИЛЬНО
make test-unit  # До
# ... рефакторинг ...
make test-unit  # После
```

### ❌ Создание Refactored версий
```bash
# НЕПРАВИЛЬНО
AuthService.php
RefactoredAuthService.php  # Оставить обе версии

# ПРАВИЛЬНО
mv AuthService.php AuthService.php.bak
mv RefactoredAuthService.php AuthService.php
# После проверки
rm AuthService.php.bak
```

### ❌ Изменение публичных интерфейсов
```php
// НЕПРАВИЛЬНО
// Было
public function authenticate($email, $password)

// Стало (сломали интерфейс!)
public function authenticate(Credentials $credentials)

// ПРАВИЛЬНО
// Сохранить существующий метод
public function authenticate($email, $password)
{
    // Делегировать новому сервису
    return $this->authService->authenticateWithCredentials(
        new Credentials($email, $password)
    );
}
```

## Инструменты и команды

### Makefile команды
```bash
# Проверка размеров
make check-file-sizes

# Запуск тестов
make test-unit
make test-specific TEST=path/to/test.php
```

### Git workflow
```bash
# Перед рефакторингом
git add .
git commit -m "Before refactoring: all tests passing"

# После рефакторинга
git add .
git commit -m "Refactor: split UserService (584→289 lines), all tests passing"
```

## Метрики успеха

### Хороший рефакторинг:
- ✅ Файлы меньше 300 строк
- ✅ Все тесты проходят
- ✅ Код стал понятнее
- ✅ LLM работает эффективнее
- ✅ Нет дублирования кода

### Плохой рефакторинг:
- ❌ Тесты не проходят
- ❌ Публичные интерфейсы изменены
- ❌ Появилось дублирование
- ❌ Усложнилась структура без причины
- ❌ Остались Refactored файлы

## Заключение

Рефакторинг для LLM-разработки - это не роскошь, а необходимость. Маленькие, focused файлы значительно повышают продуктивность и качество генерируемого кода. Следуйте этим практикам, и ваша кодовая база будет оставаться maintainable и LLM-friendly. 