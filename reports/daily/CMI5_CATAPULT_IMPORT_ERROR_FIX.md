# Решение проблемы импорта курсов CATAPULT

## Дата: 15 июля 2025
## Статус: ⚠️ ТРЕБУЕТСЯ ДЕЙСТВИЕ ПОЛЬЗОВАТЕЛЯ

## Проблема
При попытке импорта курса "Multi-Module Geology Course" (multi_au_framed.zip) появляется ошибка "Недействительный архив. Убедитесь, что файл является корректным ZIP архивом."

## Причина
Файлы курсов CATAPULT существуют в папке `LMS/Resources/CatapultDemoCourses/`:
- pre_post_test_framed.zip (3.9MB)
- multi_au_framed.zip (3.9MB)
- masteryscore_responsive.zip (3.9MB)
- single_au_basic_responsive.zip (3.9MB)

НО они не добавлены в проект Xcode, поэтому не включаются в bundle приложения при сборке.

## Решение

### Шаг 1: Добавьте файлы в Xcode

1. Откройте `LMS.xcodeproj` в Xcode
2. В навигаторе проекта найдите папку `LMS/Resources`
3. Кликните правой кнопкой на папку `Resources`
4. Выберите "Add Files to 'LMS'..."
5. Перейдите в папку `LMS/Resources/CatapultDemoCourses`
6. Выберите ВСЕ 4 ZIP файла:
   - pre_post_test_framed.zip
   - multi_au_framed.zip
   - masteryscore_responsive.zip
   - single_au_basic_responsive.zip
7. **ВАЖНО**: Убедитесь что:
   - ✅ "Create folder references" выбрано (для сохранения структуры папок)
   - ✅ "Add to targets: LMS" отмечено
   - ❌ "Copy items if needed" НЕ отмечено (файлы уже в проекте)
8. Нажмите "Add"

### Шаг 2: Проверьте Build Phases

1. Выберите проект LMS в навигаторе
2. Выберите таргет LMS
3. Перейдите на вкладку "Build Phases"
4. Раскройте "Copy Bundle Resources"
5. Убедитесь, что там есть:
   - `CatapultDemoCourses` (как папка)
   - ИЛИ все 4 ZIP файла по отдельности

### Шаг 3: Пересоберите приложение

1. Product → Clean Build Folder (⇧⌘K)
2. Product → Build (⌘B)
3. Запустите приложение

## Альтернативное решение (временное)

Пока файлы не добавлены в Xcode, система автоматически создаст временные демо-файлы с минимальной структурой Cmi5. Это позволит протестировать функционал импорта.

## Технические детали

### Улучшенное логирование
Добавлено детальное логирование в:
- `Cmi5ArchiveHandler.validateArchive()` - для отладки валидации ZIP
- `DemoCourseManager.getBundleURL()` - для проверки наличия файлов в bundle

### Структура папок в проекте
```
LMS/
└── Resources/
    ├── ai_fluency_course_v1.0.zip
    └── CatapultDemoCourses/
        ├── pre_post_test_framed.zip
        ├── multi_au_framed.zip
        ├── masteryscore_responsive.zip
        └── single_au_basic_responsive.zip
```

## Проверка решения

После добавления файлов в Xcode:
1. Перейдите в Settings → Learning → Cmi5 Import
2. Нажмите "Демо курсы"
3. Выберите любой курс CATAPULT
4. Нажмите "Импортировать курс"
5. Курс должен успешно импортироваться без ошибок

## Важно

Файлы курсов CATAPULT довольно большие (3.9MB каждый), поэтому после добавления в проект размер приложения увеличится примерно на 16MB. Это нормально для демо-контента. 