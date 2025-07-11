# Build Numbering System

## 🔢 Новая система нумерации билдов

Начиная с билда 101, мы переходим на простую инкрементальную нумерацию вместо использования даты и времени.

### Преимущества новой системы:
- ✅ Короткие и понятные номера (101, 102, 103...)
- ✅ Легко отслеживать последовательность
- ✅ Нет путаницы с длинными числами
- ✅ Соответствует стандартам App Store

### Старая система (deprecated):
- ❌ Использовала формат YYYYMMDDHHMM (например, 202507021602)
- ❌ Создавала очень длинные номера
- ❌ Трудно отслеживать версии

## 🚀 Как создать новый билд

### Автоматический билд с загрузкой:
```bash
./auto-testflight.sh morning    # Утренний билд
./auto-testflight.sh afternoon  # Послеобеденный билд
```

### Ручной билд:
```bash
./build-testflight-manual.sh
```

### Проверить текущий статус:
```bash
./scripts/check-build-status.sh
```

## 🔧 Управление номерами билдов

### Посмотреть текущий номер:
```bash
./scripts/get-next-build-number.sh get
```

### Установить конкретный номер:
```bash
./scripts/get-next-build-number.sh set 150
```

### Сбросить на начальное значение:
```bash
./scripts/get-next-build-number.sh reset  # Вернет к 100
```

## 📊 История билдов

- Билды 1-95: Старая нумерация (различные форматы)
- Билды 96-99: Последние билды со старой системой
- **Билд 101+**: Новая инкрементальная система

## ⚠️ Важные замечания

1. **Не меняйте номер вручную** без необходимости - это может привести к конфликтам
2. **Всегда используйте скрипты** для создания билдов - они автоматически управляют номерами
3. **TestFlight лимиты**: максимум 2-4 билда в день

## 🆘 Решение проблем

### Если номер билда уже существует в TestFlight:
```bash
# Увеличить номер на 10
CURRENT=$(./scripts/get-next-build-number.sh get)
NEW=$((CURRENT + 10))
./scripts/get-next-build-number.sh set $NEW
```

### Если нужно синхронизироваться с TestFlight:
1. Проверьте последний номер билда в App Store Connect
2. Установите следующий номер: `./scripts/get-next-build-number.sh set <номер+1>`

---

*Последнее обновление: Июль 2025* 