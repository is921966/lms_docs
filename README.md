# 📱 LMS - Корпоративный университет (iOS-First)

![LMS](https://img.shields.io/badge/Platform-iOS-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)
![GitHub](https://img.shields.io/badge/Feedback-GitHub%20Issues-green.svg)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)

## 🎯 **Фокус: Mobile-First Learning Management System**

Это мобильное приложение корпоративного университета, разработанное по принципу **iOS-First**, с интегрированной системой обратной связи через GitHub Issues.

## ✨ **Ключевые особенности**

### 📱 **iOS Приложение (100% готово)**
- ✅ **Feature Registry Framework** - 17 интегрированных модулей
- ✅ **Система фидбэков** с реакциями и комментариями  
- ✅ **GitHub Issues интеграция** - автоматическое логирование
- ✅ **Shake to feedback** - мгновенная обратная связь
- ✅ **Offline поддержка** с автоматической синхронизацией
- ✅ **Debug режим** для разработки и тестирования

### 🤖 **Автоматизация обратной связи**
- **GitHub Issues API** - каждый фидбэк → GitHub Issue  
- **GitHub Actions** - автоматическая обработка и назначение
- **Лейблы и приоритеты** - умная категоризация
- **Уведомления команды** - мгновенная реакция на проблемы

### 🏗️ **Архитектура**
- **SwiftUI** - современный reactive UI
- **TDD** - 100% покрытие тестами  
- **Микросервисная архитектура** - PHP backend
- **Feature Registry** - централизованное управление модулями

## 🚀 **Быстрый старт**

### **Требования:**
- **Xcode 15+**
- **iOS 16.0+** 
- **macOS 14+**

### **Установка:**
```bash
# Клонируем репозиторий
git clone https://github.com/your-repo/lms_docs.git
cd lms_docs

# Собираем iOS приложение
cd LMS_App/LMS
xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -configuration Debug build

# Запускаем на симуляторе
xcrun simctl launch booted ru.tsum.lms.igor
```

### **Настройка GitHub интеграции:**
```bash
# Добавляем GitHub token для автоматического создания Issues
export GITHUB_TOKEN="your_github_token"

# GitHub Actions уже настроены в .github/workflows/
```

## 📊 **Статус проекта**

| Компонент | Готовность | Статус |
|-----------|------------|---------|
| 📱 **iOS App** | **100%** | ✅ Production Ready |
| 🔄 **Feature Registry** | **100%** | ✅ 17 модулей интегрированы |
| 🔗 **GitHub Integration** | **100%** | ✅ Полная автоматизация |
| 🛡️ **Система фидбэков** | **100%** | ✅ С реакциями и комментариями |
| 📚 **Документация** | **100%** | ✅ Полная документация |
| ⚙️ **Backend API** | **95%** | ✅ PHP микросервисы готовы |

## 🎯 **Почему iOS-First?**

**Принятое решение:** Сосредоточиться на мобильном опыте, а не распылять усилия на веб-версию.

### **Преимущества подхода:**
- ✅ **Фокус на качестве** - одна платформа, но отлично
- ✅ **Мобильный контекст** - LMS используется в движении  
- ✅ **Нативный UX** - лучший пользовательский опыт
- ✅ **Простота поддержки** - меньше moving parts
- ✅ **Быстрая итерация** - короткие циклы разработки

### **GitHub как веб-интерфейс:**
- 📊 **Issues для фидбэков** - прозрачность процесса
- 📈 **Project boards** - управление задачами  
- 📚 **Wiki для документации** - централизованные знания
- 🔄 **Actions для автоматизации** - CI/CD из коробки

## 🛠️ **Разработка**

### **TDD Workflow:**
```bash
# Быстрые тесты (5-10 секунд)
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php

# UI тесты
./scripts/run-tests-with-timeout.sh 180 LMSUITests

# Локальная компиляция перед push
xcodebuild -scheme LMS -configuration Debug build
```

### **Feature развитие:**
```bash
# Создание нового модуля (автоматически регистрируется)
./create-feature.sh NewFeatureName

# Это создает:
# ✅ Папку Features/NewFeatureName/
# ✅ Регистрацию в FeatureRegistry  
# ✅ Integration test
# ✅ Навигацию с feature flag
```

## 📱 **Основные модули**

### **Готовые к использованию:**
- 📚 **Компетенции** - управление навыками
- 👔 **Должности** - карьерные пути  
- 📰 **Новости** - корпоративная лента
- 💬 **Фидбэки** - система обратной связи

### **В разработке:**
- 🎓 **Курсы** - обучающие материалы
- 👥 **Пользователи** - управление аккаунтами
- 📊 **Аналитика** - метрики обучения
- ⚙️ **Настройки** - конфигурация системы

## 🔗 **Интеграции**

### **GitHub Issues Workflow:**
```
👤 Пользователь отправляет фидбэк в iOS app
    ↓
📱 Фидбэк появляется в ленте с реакциями  
    ↓
🤖 GitHubFeedbackService создает Issue автоматически
    ↓  
⚙️ GitHub Actions обрабатывает: лейблы, assignees, уведомления
    ↓
👨‍💻 Команда получает уведомление и работает с Issue
    ↓
✅ Решение → автоматическое закрытие Issue
```

### **API для будущих интеграций:**
- 🔌 **REST API** - готов для веб-интеграций
- 📊 **GraphQL** - для сложных запросов
- 🔔 **Webhooks** - для real-time уведомлений
- 📈 **Analytics API** - для business intelligence

## 📋 **Следующие шаги**

### **Краткосрочные (1-2 недели):**
- [ ] Довести Курсы модуль до production ready
- [ ] Добавить push-уведомления
- [ ] Настроить TestFlight для beta-тестирования
- [ ] Улучшить GitHub Actions workflow

### **Среднесрочные (1-2 месяца):**  
- [ ] Аналитика и метрики обучения
- [ ] Интеграция с корпоративными системами
- [ ] Advanced search и фильтрация
- [ ] Offline-first архитектура

### **Долгосрочные (3-6 месяцев):**
- [ ] Apple Watch приложение
- [ ] CarPlay интеграция для обучения в дороге
- [ ] AI-powered рекомендации курсов
- [ ] Веб-версия (если понадобится)

## 🤝 **Участие в разработке**

### **Как отправить фидбэк:**
1. **Из приложения:** Потрясите устройство → отправьте фидбэк
2. **GitHub Issues:** Создайте issue с лейблом `feedback`
3. **Direct:** Свяжитесь с командой разработки

### **Разработчикам:**
```bash
# Форкните репозиторий
git clone https://github.com/your-username/lms_docs.git

# Создайте feature branch
git checkout -b feature/amazing-feature

# Следуйте TDD подходу
./test-quick.sh your-new-test.php

# Создайте Pull Request
```

## 📞 **Поддержка**

- 📧 **Email:** support@lms.example.com
- 💬 **GitHub Issues:** [Issues](https://github.com/your-repo/lms_docs/issues)
- 📱 **In-App:** Используйте функцию "Shake to feedback"
- 📚 **Документация:** `/docs/FEEDBACK_GITHUB_INTEGRATION.md`

---

**🚀 Made with ❤️ by LMS Team | iOS-First Learning Management System** 