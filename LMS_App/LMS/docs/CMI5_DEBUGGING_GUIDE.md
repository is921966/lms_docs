# Руководство по отладке обновления списка курсов после импорта Cmi5

## Что проверять в консоли Xcode

При импорте Cmi5 курса следите за следующими сообщениями в консоли Xcode:

### 1. При импорте курса:
```
🎯 Cmi5ImportView: Import button pressed
🔍 CMI5 SERVICE: Starting import from ...
🔍 CMI5 SERVICE: Creating managed course from Cmi5 package...
🔍 CMI5 SERVICE: Converted course: <название> (ID: <uuid>)
🔍 CMI5 SERVICE: Calling courseService.createCourse()...
📚 CourseService.createCourse: Before adding - X courses
📚 CourseService.createCourse: After adding - Y courses
🔍 CMI5 SERVICE: Created managed course: <название> (ID: <uuid>)
🔍 CMI5 SERVICE: Total courses after creation: Y
🔍 CMI5 SERVICE: ✅ Course found in storage!
🔍 CMI5 SERVICE: Posting Cmi5CourseImported notification...
🔍 CMI5 SERVICE: Posted Cmi5CourseImported notification from MainActor
🎯 Cmi5ImportView: Import completed, importedPackage: <название>
🎯 Cmi5ImportView: Showing success alert
```

### 2. При обновлении списка курсов:
```
📚 CourseManagementView: Received Cmi5CourseImported notification, reloading courses...
📚 CourseManagementViewModel: loadCourses() called
📚 CourseManagementViewModel: Fetching courses...
📚 CourseService.fetchCourses: Returning Y courses
📚 CourseManagementViewModel: Loaded Y courses
   Course X: <название> (ID: <uuid>, Cmi5: true)
```

## Возможные проблемы и решения

### Проблема 1: Курс не появляется в списке
**Проверьте:**
- Видите ли вы "✅ Course found in storage!" после создания?
- Увеличилось ли количество курсов в "After adding - Y courses"?
- Получено ли уведомление "Received Cmi5CourseImported notification"?

**Решение:**
- Попробуйте pull-to-refresh (потяните список вниз)
- Проверьте, что alert "Импорт завершен" появляется и вы нажимаете "ОК"

### Проблема 2: Уведомление не приходит
**Проверьте:**
- Видите ли вы "Posted Cmi5CourseImported notification from MainActor"?
- Есть ли ошибки между "Posting" и "Posted"?

**Решение:**
- Убедитесь, что CourseManagementView находится в памяти (не выгружен)
- Попробуйте вернуться на главный экран и снова открыть управление курсами

### Проблема 3: Курс создается, но не сохраняется
**Проверьте:**
- Количество курсов в "Before adding" и "After adding"
- Сообщение "Course found in storage" или "Course NOT found in storage"

**Решение:**
- Это может указывать на проблему с хранилищем в памяти
- Перезапустите приложение

## Ручное обновление

Если автоматическое обновление не работает:
1. Используйте **pull-to-refresh** - потяните список курсов вниз
2. Выйдите из управления курсами и зайдите снова
3. Перезапустите приложение

## Дополнительная отладка

Для более детальной отладки можно временно добавить больше логирования:
- В NotificationCenter подписке добавить логирование всех уведомлений
- В CourseService добавить логирование всех операций с массивом
- В Cmi5Service добавить таймеры для измерения времени операций 