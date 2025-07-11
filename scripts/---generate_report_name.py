#!/usr/bin/env python3
"""
Автоматическая генерация названий отчетов для проекта LMS
Использует реальную дату и время для исключения ошибок нумерации
"""

import datetime
import os
import sys
import json
from pathlib import Path

def get_project_start_date():
    """Возвращает дату начала проекта (1 июня 2025)"""
    return datetime.date(2025, 6, 1)

def calculate_day_number(current_date=None):
    """Вычисляет номер дня проекта от даты начала"""
    if current_date is None:
        current_date = datetime.date.today()
    
    start_date = get_project_start_date()
    delta = current_date - start_date
    return delta.days + 1  # День 1 = первый день проекта

def generate_daily_report_name(date=None, include_timestamp=False):
    """Генерирует название ежедневного отчета"""
    if date is None:
        date = datetime.date.today()
    
    day_number = calculate_day_number(date)
    
    if include_timestamp:
        timestamp = datetime.datetime.now().strftime("%H%M")
        return f"DAY_{day_number:02d}_SUMMARY_{date.strftime('%Y%m%d')}_{timestamp}.md"
    else:
        return f"DAY_{day_number:02d}_SUMMARY_{date.strftime('%Y%m%d')}.md"

def generate_sprint_report_name(sprint_number, report_type, date=None):
    """Генерирует название sprint отчета"""
    if date is None:
        date = datetime.date.today()
    
    valid_types = ['PLAN', 'PROGRESS', 'COMPLETION_REPORT']
    if report_type not in valid_types:
        raise ValueError(f"Report type must be one of: {valid_types}")
    
    return f"SPRINT_{sprint_number:02d}_{report_type}_{date.strftime('%Y%m%d')}.md"

def get_current_sprint_info():
    """Определяет текущий спринт на основе даты"""
    current_date = datetime.date.today()
    day_number = calculate_day_number(current_date)
    
    # Спринты по 5 дней (рабочая неделя)
    sprint_number = ((day_number - 1) // 5) + 1
    day_in_sprint = ((day_number - 1) % 5) + 1
    
    return {
        'sprint_number': sprint_number,
        'day_in_sprint': day_in_sprint,
        'day_number': day_number,
        'date': current_date
    }

def ensure_report_directories():
    """Создает необходимые директории для отчетов"""
    base_path = Path(__file__).parent.parent / "reports"
    
    directories = [
        base_path / "daily",
        base_path / "sprints", 
        base_path / "methodology"
    ]
    
    for directory in directories:
        directory.mkdir(parents=True, exist_ok=True)
    
    return base_path

def create_daily_report_template(file_path, sprint_info):
    """Создает шаблон ежедневного отчета"""
    template = f"""# День {sprint_info['day_number']} - Sprint {sprint_info['sprint_number']}, День {sprint_info['day_in_sprint']}

**Дата:** {sprint_info['date'].strftime('%d %B %Y')}  
**Sprint:** {sprint_info['sprint_number']} - [Название спринта]  
**День в спринте:** {sprint_info['day_in_sprint']}/5

## 🎯 Выполненные задачи

### [Название задачи]
- [ ] Подзадача 1
- [ ] Подзадача 2

## ⏱️ Затраченное компьютерное время:

### Основные задачи:
- **[Задача 1]**: ~XX минут
- **[Задача 2]**: ~XX минут
- **Общее время разработки**: ~XX минут

### 📈 Эффективность разработки:
- **Скорость написания кода**: ~X строк/минуту
- **Время на исправление ошибок**: X% от общего времени
- **Эффективность TDD**: [Оценка]

## 🚀 Следующие шаги

### Планируемые задачи на завтра:
1. [Задача 1]
2. [Задача 2]

### Прогноз:
- **Ожидаемое время**: ~X часов
- **Планируемые результаты**: [Описание]

## 📊 Sprint {sprint_info['sprint_number']} Progress

### Текущий статус:
- **Завершено**: X/Y SP
- **В процессе**: [Текущие задачи]
- **Общий прогресс**: X% спринта

Автоматически сгенерировано: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(template)

def main():
    """Основная функция для командной строки"""
    if len(sys.argv) < 2:
        print("Использование:")
        print("  python generate_report_name.py daily [--create] [--date YYYY-MM-DD]")
        print("  python generate_report_name.py sprint SPRINT_NUMBER REPORT_TYPE [--date YYYY-MM-DD]")
        print("  python generate_report_name.py info")
        print()
        print("Примеры:")
        print("  python generate_report_name.py daily")
        print("  python generate_report_name.py daily --create")
        print("  python generate_report_name.py sprint 16 PLAN")
        print("  python generate_report_name.py info")
        return
    
    command = sys.argv[1]
    
    # Парсинг даты если указана
    date = None
    if '--date' in sys.argv:
        date_idx = sys.argv.index('--date') + 1
        if date_idx < len(sys.argv):
            date_str = sys.argv[date_idx]
            date = datetime.datetime.strptime(date_str, '%Y-%m-%d').date()
    
    if command == 'daily':
        # Проверяем условный день из tracker файла
        tracker_file = Path(__file__).parent / "project_day_tracker.json"
        if tracker_file.exists():
            import json
            with open(tracker_file, 'r') as f:
                tracker_data = json.load(f)
                conditional_day = tracker_data.get('current_conditional_day', calculate_day_number(date))
                if date is None:
                    date = datetime.date.today()
                filename = f"DAY_{conditional_day}_SUMMARY_{date.strftime('%Y%m%d')}.md"
        else:
            filename = generate_daily_report_name(date)
        print(filename)
        
        if '--create' in sys.argv:
            base_path = ensure_report_directories()
            file_path = base_path / "daily" / filename
            
            if file_path.exists():
                print(f"Файл уже существует: {file_path}")
            else:
                sprint_info = get_current_sprint_info()
                if date:
                    sprint_info['date'] = date
                    sprint_info['day_number'] = calculate_day_number(date)
                
                create_daily_report_template(file_path, sprint_info)
                print(f"Создан файл: {file_path}")
    
    elif command == 'sprint':
        if len(sys.argv) < 4:
            print("Для sprint нужно указать номер спринта и тип отчета")
            return
        
        sprint_number = int(sys.argv[2])
        report_type = sys.argv[3]
        
        try:
            filename = generate_sprint_report_name(sprint_number, report_type, date)
            print(filename)
        except ValueError as e:
            print(f"Ошибка: {e}")
    
    elif command == 'info':
        sprint_info = get_current_sprint_info()
        print(f"Текущая дата: {sprint_info['date']}")
        
        # Читаем условный день из tracker файла
        tracker_file = Path(__file__).parent / "project_day_tracker.json"
        if tracker_file.exists():
            import json
            with open(tracker_file, 'r') as f:
                tracker_data = json.load(f)
                conditional_day = tracker_data.get('current_conditional_day', sprint_info['day_number'])
                print(f"День проекта: {conditional_day} (условный)")
        else:
            print(f"День проекта: {sprint_info['day_number']}")
            
        print(f"Спринт: {sprint_info['sprint_number']}")
        print(f"День в спринте: {sprint_info['day_in_sprint']}/5")
        print()
        
        # Используем условный день для имени файла
        if tracker_file.exists():
            report_name = f"DAY_{conditional_day}_SUMMARY_{sprint_info['date'].strftime('%Y%m%d')}.md"
            print(f"Название ежедневного отчета: {report_name}")
        else:
            print(f"Название ежедневного отчета: {generate_daily_report_name()}")
    
    else:
        print(f"Неизвестная команда: {command}")

if __name__ == "__main__":
    main() 