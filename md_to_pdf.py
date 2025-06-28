#!/usr/bin/env python3
"""
Простой конвертер Markdown в PDF для Cursor
Работает без дополнительных установок, используя встроенные библиотеки
"""

import sys
import os
import re
from pathlib import Path
import webbrowser
import tempfile

def markdown_to_html(markdown_text):
    """Простая конвертация Markdown в HTML"""
    html = markdown_text
    
    # Заголовки
    html = re.sub(r'^##### (.*?)$', r'<h5>\1</h5>', html, flags=re.MULTILINE)
    html = re.sub(r'^#### (.*?)$', r'<h4>\1</h4>', html, flags=re.MULTILINE)
    html = re.sub(r'^### (.*?)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
    html = re.sub(r'^## (.*?)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
    html = re.sub(r'^# (.*?)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
    
    # Жирный и курсив
    html = re.sub(r'\*\*\*(.*?)\*\*\*', r'<strong><em>\1</em></strong>', html)
    html = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', html)
    html = re.sub(r'\*(.*?)\*', r'<em>\1</em>', html)
    
    # Код
    html = re.sub(r'```(.*?)```', r'<pre><code>\1</code></pre>', html, flags=re.DOTALL)
    html = re.sub(r'`(.*?)`', r'<code>\1</code>', html)
    
    # Списки
    html = re.sub(r'^\* (.*)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    html = re.sub(r'^\- (.*)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    html = re.sub(r'^\d+\. (.*)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    
    # Ссылки
    html = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', html)
    
    # Изображения
    html = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', r'<img src="\2" alt="\1">', html)
    
    # Цитаты
    html = re.sub(r'^> (.*)$', r'<blockquote>\1</blockquote>', html, flags=re.MULTILINE)
    
    # Параграфы
    paragraphs = html.split('\n\n')
    html = '\n'.join(f'<p>{p}</p>' if not p.strip().startswith('<') else p 
                     for p in paragraphs if p.strip())
    
    return html

def create_pdf_html(markdown_file):
    """Создает красивый HTML из Markdown файла"""
    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    html_content = markdown_to_html(content)
    
    html_template = f"""<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>{Path(markdown_file).stem}</title>
    <style>
        @media print {{
            body {{ margin: 0; }}
            .no-print {{ display: none; }}
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 20px;
            background: white;
        }}
        
        h1, h2, h3, h4, h5, h6 {{
            margin-top: 24px;
            margin-bottom: 16px;
            font-weight: 600;
            line-height: 1.25;
            color: #111;
        }}
        
        h1 {{
            font-size: 2em;
            border-bottom: 2px solid #eee;
            padding-bottom: 0.3em;
        }}
        
        h2 {{
            font-size: 1.5em;
            border-bottom: 1px solid #eee;
            padding-bottom: 0.3em;
        }}
        
        h3 {{ font-size: 1.25em; }}
        h4 {{ font-size: 1em; }}
        h5 {{ font-size: 0.875em; }}
        h6 {{ font-size: 0.85em; color: #666; }}
        
        p {{
            margin-top: 0;
            margin-bottom: 16px;
        }}
        
        code {{
            background-color: rgba(27,31,35,0.05);
            padding: 0.2em 0.4em;
            margin: 0;
            font-size: 85%;
            border-radius: 3px;
            font-family: Monaco, 'Courier New', Courier, monospace;
        }}
        
        pre {{
            background-color: #f6f8fa;
            border-radius: 6px;
            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            border: 1px solid #e1e4e8;
        }}
        
        pre code {{
            background-color: transparent;
            padding: 0;
            font-size: 100%;
        }}
        
        blockquote {{
            margin: 0;
            padding: 0 1em;
            color: #6a737d;
            border-left: 0.25em solid #dfe2e5;
        }}
        
        ul, ol {{
            margin-top: 0;
            margin-bottom: 16px;
            padding-left: 2em;
        }}
        
        li {{
            margin-bottom: 0.25em;
        }}
        
        table {{
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 16px;
        }}
        
        th, td {{
            padding: 6px 13px;
            border: 1px solid #dfe2e5;
        }}
        
        th {{
            background-color: #f6f8fa;
            font-weight: 600;
        }}
        
        tr:nth-child(even) {{
            background-color: #f6f8fa;
        }}
        
        img {{
            max-width: 100%;
            height: auto;
            box-sizing: border-box;
        }}
        
        a {{
            color: #0366d6;
            text-decoration: none;
        }}
        
        a:hover {{
            text-decoration: underline;
        }}
        
        hr {{
            height: 0.25em;
            padding: 0;
            margin: 24px 0;
            background-color: #e1e4e8;
            border: 0;
        }}
        
        .pdf-controls {{
            position: fixed;
            top: 20px;
            right: 20px;
            background: #fff;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }}
        
        .pdf-controls button {{
            background: #0366d6;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 3px;
            cursor: pointer;
            font-size: 14px;
        }}
        
        .pdf-controls button:hover {{
            background: #0256c7;
        }}
    </style>
</head>
<body>
    <div class="pdf-controls no-print">
        <button onclick="window.print()">📄 Сохранить как PDF</button>
        <button onclick="window.close()">❌ Закрыть</button>
    </div>
    {html_content}
</body>
</html>"""
    
    return html_template

def convert_to_pdf(markdown_file):
    """Конвертирует Markdown файл в PDF"""
    if not os.path.exists(markdown_file):
        print(f"❌ Файл не найден: {markdown_file}")
        return
    
    print(f"📄 Конвертирую: {markdown_file}")
    
    # Создаем HTML
    html_content = create_pdf_html(markdown_file)
    
    # Сохраняем во временный файл
    with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
        f.write(html_content)
        temp_html = f.name
    
    # Открываем в браузере
    print(f"🌐 Открываю в браузере...")
    print(f"💡 Используйте Cmd+P и выберите 'Сохранить как PDF'")
    webbrowser.open(f'file://{temp_html}')
    
    # Информация для пользователя
    output_pdf = Path(markdown_file).stem + '.pdf'
    print(f"\n📝 Инструкция:")
    print(f"1. В браузере нажмите Cmd+P (или Файл → Печать)")
    print(f"2. В разделе 'Принтер' выберите 'Сохранить как PDF'")
    print(f"3. Сохраните файл как: {output_pdf}")
    print(f"\n✅ HTML файл создан: {temp_html}")

def main():
    if len(sys.argv) < 2:
        print("🎨 Markdown to PDF Converter")
        print("===========================")
        print(f"Использование: {sys.argv[0]} <file.md> [file2.md ...]")
        print(f"Пример: {sys.argv[0]} README.md")
        print(f"        {sys.argv[0]} reports/*.md")
        sys.exit(1)
    
    for file in sys.argv[1:]:
        convert_to_pdf(file)

if __name__ == "__main__":
    main() 