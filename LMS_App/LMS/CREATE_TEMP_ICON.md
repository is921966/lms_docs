# Добавление временной иконки для TestFlight

## Варианты решения:

### 1. Используйте онлайн генератор (самый быстрый)
1. Перейдите на [makeappicon.com](https://makeappicon.com)
2. Загрузите любое изображение
3. Скачайте набор иконок
4. Используйте файл 1024x1024

### 2. Создайте простую иконку в Preview (Mac)
1. Откройте Preview
2. File → New from Clipboard (или создайте новый файл)
3. Tools → Adjust Size → 1024x1024 pixels
4. Нарисуйте что-нибудь простое (например, буквы "LMS")
5. Сохраните как PNG

### 3. Используйте временную иконку из SF Symbols
В Xcode:
1. Откройте SF Symbols app
2. Выберите любой символ
3. Экспортируйте как изображение
4. Измените размер до 1024x1024

### 4. Команда для создания простой иконки
```bash
# Создаем простую иконку с текстом LMS
convert -size 1024x1024 xc:blue -gravity center -pointsize 400 -fill white -annotate +0+0 'LMS' LMS/Assets.xcassets/AppIcon.appiconset/AppIcon1024x1024.png
```

Если `convert` не установлен:
```bash
brew install imagemagick
```

## После добавления иконки:
1. Откройте Xcode
2. Перейдите в Assets.xcassets → AppIcon
3. Перетащите иконку 1024x1024 в соответствующий слот
4. Сохраните (Cmd+S) 