# 📄 Конвертация Markdown в PDF в Cursor

## 🚀 Быстрый старт

### Метод 1: Extension (Самый простой)
1. Установите расширение **Markdown PDF** от yzane в Cursor
2. Откройте любой `.md` файл
3. `Cmd+Shift+P` → `Markdown PDF: Export (pdf)`
4. Готово! PDF создан рядом с исходным файлом

### Метод 2: Python скрипт (Без установок)
```bash
# Для одного файла
python3 md_to_pdf.py README.md

# Для всех отчетов
python3 md_to_pdf.py reports/*.md
```
Откроется браузер → `Cmd+P` → Сохранить как PDF

### Метод 3: Shell скрипт (Универсальный)
```bash
# Для одного файла
./convert-md-to-pdf.sh PROJECT_STATUS.md

# Для нескольких файлов
./convert-md-to-pdf.sh reports/daily/*.md
```

## 📊 Сравнение методов

| Метод | Установка | Качество | Скорость | Кастомизация |
|-------|-----------|----------|----------|--------------|
| Extension | ⭐ Простая | ⭐⭐⭐ Хорошее | ⭐⭐⭐ Быстро | ⭐⭐ Средняя |
| Python | ⭐⭐⭐ Не нужна | ⭐⭐ Нормальное | ⭐⭐ Средне | ⭐⭐⭐ Полная |
| Pandoc | ⭐ Сложная | ⭐⭐⭐⭐ Отличное | ⭐⭐⭐ Быстро | ⭐⭐⭐ Полная |

## 🎨 Настройка стилей

### Для Extension:
1. `Cmd+Shift+P` → `Preferences: Open Settings (JSON)`
2. Добавьте:
```json
{
  "markdown-pdf.styles": [
    "https://raw.githubusercontent.com/sindresorhus/github-markdown-css/main/github-markdown.css"
  ],
  "markdown-pdf.displayHeaderFooter": true,
  "markdown-pdf.format": "A4",
  "markdown-pdf.margin.top": "1cm",
  "markdown-pdf.margin.bottom": "1cm",
  "markdown-pdf.margin.left": "1cm",
  "markdown-pdf.margin.right": "1cm"
}
```

### Для Python скрипта:
Редактируйте CSS стили прямо в файле `md_to_pdf.py`

## 🎯 Примеры использования

### Экспорт документации проекта:
```bash
# Все отчеты за день
./convert-md-to-pdf.sh reports/daily/DAY_*_SUMMARY.md

# Техническая документация
python3 md_to_pdf.py technical_requirements/*.md

# Sprint отчеты
./convert-md-to-pdf.sh reports/sprints/SPRINT_*.md
```

### Создание красивого портфолио:
```bash
# Объединить несколько MD файлов в один PDF
cat README.md PROJECT_STATUS.md TESTING_GUIDE.md > portfolio.md
python3 md_to_pdf.py portfolio.md
```

## 💡 Советы

1. **Для презентаций**: Используйте Extension с настройкой landscape ориентации
2. **Для документации**: Python скрипт дает больше контроля над стилями
3. **Для массовой конвертации**: Shell скрипт с pandoc самый быстрый
4. **Для отчетов**: Добавьте дату в header через настройки Extension

## 🔧 Решение проблем

### "Pandoc не найден"
```bash
brew install pandoc
# или используйте Python скрипт - он работает без установок
```

### "PDF выглядит некрасиво"
- Проверьте кодировку файла (должна быть UTF-8)
- Используйте правильные заголовки (# ## ###)
- Добавьте пустые строки между параграфами

### "Изображения не отображаются"
- Используйте относительные пути
- Проверьте, что изображения доступны
- Для Extension включите `markdown-pdf.convertOnSave`

## 📚 Дополнительные возможности

### Автоматическая конвертация при сохранении:
```json
{
  "markdown-pdf.convertOnSave": true,
  "markdown-pdf.convertOnSaveExclude": [
    "README.md",
    "CHANGELOG.md"
  ]
}
```

### Добавление водяных знаков:
```bash
# С помощью pandoc
pandoc input.md -o output.pdf \
  --pdf-engine=xelatex \
  -V header-includes:"\usepackage{draftwatermark}"
```

### Пакетная обработка с прогрессом:
```bash
# Создайте batch-convert.sh
for file in "$@"; do
  echo "Converting: $file"
  python3 md_to_pdf.py "$file"
  echo "✅ Done: ${file%.md}.pdf"
done
```

---

🎉 Теперь вы можете легко конвертировать любые Markdown файлы в красивые PDF прямо из Cursor! 