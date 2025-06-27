# Quick Start: Production Development

## 🚀 Неделя 1: Immediate Actions

### День 1-2: Environment Setup
```bash
# 1. Клонировать репозиторий
git clone https://github.com/is921966/lms_docs.git
cd lms_docs

# 2. Создать ветку для production
git checkout -b production/sprint-1

# 3. Настроить backend проект
cd backend
npm init -y
npm install nestjs @nestjs/common @nestjs/platform-express
npm install @nestjs/jwt passport-jwt bcrypt
npm install @nestjs/swagger swagger-ui-express

# 4. Создать базовую структуру
nest new lms-backend --skip-git
```

### День 3-4: API Scaffolding
```typescript
// Создать основные модули
nest g module auth
nest g module users
nest g module courses
nest g module tests
nest g module competencies

// Создать контроллеры и сервисы
nest g controller auth
nest g service auth
// ... повторить для всех модулей
```

### День 5: Database & Auth
```sql
-- Создать базовые таблицы
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    ldap_id VARCHAR(255),
    role VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE courses (
    id UUID PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    created_by UUID REFERENCES users(id)
);
```

## 📱 iOS Integration Points

### 1. Обновить Network Layer
```swift
// NetworkConfig.swift
struct NetworkConfig {
    #if DEBUG
    static let baseURL = "http://localhost:3000/api/v1"
    #else
    static let baseURL = "https://api.lms.company.com/api/v1"
    #endif
}

// APIClient.swift
class APIClient {
    static let shared = APIClient()
    private let session = URLSession.shared
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Implementation
    }
}
```

### 2. Заменить Mock Services
```swift
// Before (Mock)
class MockAuthService: AuthServiceProtocol {
    func login(email: String, password: String) async -> Result<User, Error> {
        // Mock implementation
    }
}

// After (Real)
class AuthService: AuthServiceProtocol {
    private let apiClient = APIClient.shared
    
    func login(email: String, password: String) async -> Result<User, Error> {
        let endpoint = AuthEndpoint.login(email: email, password: password)
        return await apiClient.request(endpoint)
    }
}
```

## 🔧 Backend Quick Wins

### 1. JWT Auth Module
```typescript
// auth.module.ts
@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '7d' },
    }),
  ],
  providers: [AuthService, LdapService],
  controllers: [AuthController],
})
export class AuthModule {}
```

### 2. CRUD для курсов
```typescript
// courses.controller.ts
@Controller('courses')
@UseGuards(JwtAuthGuard)
export class CoursesController {
  @Get()
  findAll(@Query() filters: FilterDto) {
    return this.coursesService.findAll(filters);
  }
  
  @Post()
  @Roles('admin')
  create(@Body() createCourseDto: CreateCourseDto) {
    return this.coursesService.create(createCourseDto);
  }
}
```

## 📊 Метрики для отслеживания

### Неделя 1:
- [ ] Backend проект создан и запускается
- [ ] Базовая аутентификация работает
- [ ] iOS app подключается к local backend
- [ ] CI/CD pipeline настроен

### Неделя 2:
- [ ] Все CRUD endpoints готовы
- [ ] Swagger документация доступна
- [ ] Integration тесты написаны
- [ ] Staging environment развернут

## 🛠 Инструменты и сервисы

### Обязательные:
- **PostgreSQL 14+**: База данных
- **Redis**: Кеширование сессий
- **Docker**: Контейнеризация
- **GitHub Actions**: CI/CD

### Рекомендуемые:
- **Postman**: API тестирование
- **pgAdmin**: Database management
- **Sentry**: Error tracking
- **DataDog**: Monitoring

## 📝 Чеклист первой недели

### Backend Team:
- [ ] Создать проект структуру
- [ ] Настроить database migrations
- [ ] Реализовать JWT auth
- [ ] Создать первые 3 endpoints
- [ ] Написать API документацию
- [ ] Развернуть на staging

### iOS Team:
- [ ] Создать production branch
- [ ] Настроить environment configs
- [ ] Реализовать APIClient
- [ ] Обновить AuthService
- [ ] Подключиться к staging API
- [ ] Обновить UI для loading states

### DevOps:
- [ ] Настроить CI/CD pipeline
- [ ] Создать Docker images
- [ ] Настроить staging environment
- [ ] Установить monitoring
- [ ] Настроить backups

## 🚨 Критические моменты

1. **Не откладывайте интеграцию** - начните с простого endpoint и сразу подключите iOS
2. **Версионируйте API** - используйте /v1/ с самого начала
3. **Документируйте всё** - OpenAPI spec обязателен
4. **Тестируйте рано** - интеграционные тесты с первого дня
5. **Мониторьте всё** - логи, метрики, errors с самого начала

## 📞 Daily Standup Topics

1. **Блокеры**: Что мешает прогрессу?
2. **Интеграция**: Какие endpoints готовы для iOS?
3. **Тесты**: Сколько тестов написано и проходит?
4. **Документация**: Обновлена ли OpenAPI spec?
5. **Риски**: Появились ли новые риски?

---

**Ready to start?** 🚀 Создайте первый endpoint и подключите его к iOS app! 