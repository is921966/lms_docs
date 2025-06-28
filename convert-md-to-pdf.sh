#!/bin/bash

# Скрипт для конвертации Markdown в PDF с красивым форматированием
# Использует wkhtmltopdf или pandoc

echo "🎨 Markdown to PDF Converter"
echo "==========================="

# Проверяем наличие необходимых инструментов
check_dependencies() {
    if command -v pandoc &> /dev/null; then
        echo "✅ Pandoc найден"
        CONVERTER="pandoc"
    elif command -v wkhtmltopdf &> /dev/null; then
        echo "✅ wkhtmltopdf найден"
        CONVERTER="wkhtmltopdf"
    else
        echo "❌ Не найдены конвертеры. Установите один из:"
        echo "   brew install pandoc"
        echo "   brew install --cask wkhtmltopdf"
        exit 1
    fi
}

# Конвертация с Pandoc
convert_with_pandoc() {
    local input_file="$1"
    local output_file="${input_file%.md}.pdf"
    
    echo "📄 Конвертирую: $input_file -> $output_file"
    
    # Красивые настройки для PDF
    pandoc "$input_file" \
        -o "$output_file" \
        --pdf-engine=xelatex \
        -V geometry:margin=1in \
        -V mainfont="Helvetica Neue" \
        -V monofont="Monaco" \
        -V fontsize=11pt \
        -V linestretch=1.5 \
        --highlight-style=tango \
        --toc \
        --toc-depth=3 \
        2>/dev/null || {
            # Fallback без LaTeX
            pandoc "$input_file" \
                -o "$output_file" \
                --pdf-engine=html \
                --css=github-markdown.css
        }
}

# Конвертация через HTML
convert_with_html() {
    local input_file="$1"
    local html_file="${input_file%.md}.html"
    local output_file="${input_file%.md}.pdf"
    
    echo "📄 Конвертирую: $input_file -> $output_file"
    
    # Сначала конвертируем в HTML с красивыми стилями
    cat > "$html_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 900px;
            margin: 0 auto;
            padding: 2em;
        }
        h1, h2, h3, h4, h5, h6 {
            margin-top: 1.5em;
            margin-bottom: 0.5em;
            color: #000;
        }
        h1 { border-bottom: 2px solid #eee; padding-bottom: 0.3em; }
        h2 { border-bottom: 1px solid #eee; padding-bottom: 0.2em; }
        code {
            background-color: #f4f4f4;
            padding: 0.2em 0.4em;
            border-radius: 3px;
            font-family: Monaco, 'Courier New', monospace;
        }
        pre {
            background-color: #f8f8f8;
            padding: 1em;
            border-radius: 5px;
            overflow-x: auto;
            border: 1px solid #ddd;
        }
        blockquote {
            border-left: 4px solid #ddd;
            margin: 0;
            padding-left: 1em;
            color: #666;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 1em 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 0.5em;
            text-align: left;
        }
        th {
            background-color: #f5f5f5;
            font-weight: bold;
        }
        img {
            max-width: 100%;
            height: auto;
        }
        a {
            color: #0366d6;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
EOF
    
    # Конвертируем Markdown в HTML
    if command -v pandoc &> /dev/null; then
        pandoc "$input_file" -t html >> "$html_file"
    else
        # Простая конвертация если нет pandoc
        python3 -m markdown "$input_file" >> "$html_file" 2>/dev/null || {
            echo "❌ Не могу конвертировать Markdown в HTML"
            rm "$html_file"
            return 1
        }
    fi
    
    echo "</body></html>" >> "$html_file"
    
    # Конвертируем HTML в PDF
    if command -v wkhtmltopdf &> /dev/null; then
        wkhtmltopdf --enable-local-file-access "$html_file" "$output_file"
    else
        echo "💡 Откройте $html_file в браузере и сохраните как PDF"
    fi
    
    # Удаляем временный HTML
    rm "$html_file"
}

# Основная функция
main() {
    check_dependencies
    
    if [ $# -eq 0 ]; then
        echo "Использование: $0 <markdown-file.md> [markdown-file2.md ...]"
        echo "Или: $0 *.md для конвертации всех MD файлов"
        exit 1
    fi
    
    for file in "$@"; do
        if [ -f "$file" ]; then
            if [ "$CONVERTER" = "pandoc" ]; then
                convert_with_pandoc "$file"
            else
                convert_with_html "$file"
            fi
            
            if [ -f "${file%.md}.pdf" ]; then
                echo "✅ Успешно создан: ${file%.md}.pdf"
            fi
        else
            echo "⚠️  Файл не найден: $file"
        fi
    done
    
    echo ""
    echo "🎉 Конвертация завершена!"
}

main "$@" 