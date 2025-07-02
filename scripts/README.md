# Скрипты автоматизации LMS проекта

## 🚀 Быстрый старт

### Ежедневные отчеты
```bash
# Узнать информацию о текущем дне
./scripts/report.sh info

# Создать ежедневный отчет
./scripts/report.sh daily-create
```

### Sprint отчеты
```bash
# План спринта
./scripts/report.sh sprint 16 PLAN

# Прогресс спринта
./scripts/report.sh sprint 16 PROGRESS

# Завершение спринта
./scripts/report.sh sprint 16 COMPLETION_REPORT
```

## 📊 Текущая информация

На 30 июня 2025:
- **День проекта**: 30
- **Спринт**: 6 (день 5/5)
- **Следующий спринт**: 7 (начнется 1 июля)

## 📁 Файлы

- `generate_report_name.py` - Основной Python скрипт
- `report.sh` - Удобная shell обертка
- `README.md` - Эта документация

## 📖 Полная документация

См. `docs/AUTOMATED_REPORT_NAMING.md` для детальной информации. 