#!/usr/bin/env python3
"""
Скрипт для обновления условного дня проекта
"""

import json
import datetime
import sys
from pathlib import Path

def update_conditional_day(increment=True):
    """Обновляет условный день проекта"""
    tracker_file = Path(__file__).parent / "project_day_tracker.json"
    
    # Читаем текущие данные
    if tracker_file.exists():
        with open(tracker_file, 'r') as f:
            data = json.load(f)
    else:
        # Создаем новый файл с начальными данными
        data = {
            "project_start_date": "2025-06-21",
            "current_conditional_day": 118,
            "last_updated": datetime.date.today().isoformat(),
            "note": "Условная нумерация дней используется для согласованности отчетов"
        }
    
    # Обновляем день
    if increment:
        data['current_conditional_day'] += 1
    
    data['last_updated'] = datetime.date.today().isoformat()
    
    # Сохраняем обратно
    with open(tracker_file, 'w') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    
    return data['current_conditional_day']

def main():
    """Основная функция"""
    if len(sys.argv) > 1:
        if sys.argv[1] == 'next':
            new_day = update_conditional_day(increment=True)
            print(f"Обновлено до Дня {new_day}")
        elif sys.argv[1] == 'current':
            tracker_file = Path(__file__).parent / "project_day_tracker.json"
            if tracker_file.exists():
                with open(tracker_file, 'r') as f:
                    data = json.load(f)
                    print(f"Текущий условный день: {data['current_conditional_day']}")
            else:
                print("Tracker файл не найден")
        else:
            print("Использование:")
            print("  python update_conditional_day.py current  - показать текущий день")
            print("  python update_conditional_day.py next     - перейти к следующему дню")
    else:
        print("Использование:")
        print("  python update_conditional_day.py current  - показать текущий день")
        print("  python update_conditional_day.py next     - перейти к следующему дню")

if __name__ == "__main__":
    main() 