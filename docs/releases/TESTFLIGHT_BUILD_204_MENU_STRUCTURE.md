# TestFlight Build 204 - Структура меню "Ещё"

## Версия
- **Version**: 2.1.0
- **Build**: 204
- **Дата**: 10 июля 2025

## Зафиксированная структура меню "Ещё" для администратора

### Порядок отображения:

1. **Настройки**
   - Иконка: gear (синяя)
   - Описание: Управление приложением и аккаунтом

2. **Новости**
   - Иконка: newspaper (розовая)
   - Описание: Лента новостей и объявлений

3. **Новые студенты**
   - Иконка: person.badge.plus (оранжевая)
   - Описание: Одобрение новых пользователей
   - Badge: Количество ожидающих (красный)

4. **Управление курсами**
   - Иконка: book.fill (зеленая)
   - Описание: Создание и редактирование курсов

5. **Cmi5 Контент**
   - Иконка: cube.box (голубая)
   - Описание: Интерактивные учебные материалы
   - Badge: "НОВОЕ" (красный)

6. **Остальные модули** (в порядке их определения в FeatureRegistry)
   - Исключая: Курсы (для администраторов)
   - Исключая: Feed и Cmi5 (уже добавлены выше)

### Особенности реализации:

1. **Единообразный дизайн**
   - Все пункты меню используют одинаковые карточки
   - Каждая карточка содержит: иконку, заголовок, описание, стрелку
   - Опциональные badges для уведомлений

2. **Логика отображения**
   - Модуль "Курсы" скрыт для администраторов (дублирует "Управление курсами")
   - "Новости" всегда идут после "Настройки"
   - "Cmi5 Контент" всегда идет после "Управление курсами"

3. **Визуальные элементы**
   - Убран заголовок "Дополнительные функции"
   - Сохранен раздел "Скоро будут доступны" для будущих модулей
   - Информация для тестировщиков в конце списка

## Изменения в коде

### MoreModulesView.swift
- Фиксированный порядок функций в методе `allFunctions`
- Исключение модуля "Курсы" для администраторов
- Специальная обработка для модулей Feed и Cmi5

### Info.plist
- CFBundleVersion: 204
- CFBundleShortVersionString: 2.1.0

## Архив для TestFlight
- Расположение: `~/Library/Developer/Xcode/Archives/2025-07-10/LMS_Build204_*.xcarchive`
- Требует подписи через Xcode для загрузки в TestFlight

## Примечания
Эта структура меню зафиксирована для build 204 и должна использоваться как эталонная для тестирования в TestFlight. 