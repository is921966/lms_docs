#!/usr/bin/env python3
"""
Универсальный менеджер времени для LMS проекта.
Решает проблему путаницы между условными и календарными днями.
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path

class ProjectTimeManager:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.config_file = self.project_root / '.project-time.json'
        self.project_start = datetime(2025, 6, 21)
        self.load_config()
    
    def load_config(self):
        """Загружает конфигурацию из файла или создает новую."""
        if self.config_file.exists():
            with open(self.config_file, 'r') as f:
                self.config = json.load(f)
        else:
            self.config = {
                'project_start': '2025-06-21',
                'current_conditional_day': 1,
                'day_mapping': {}  # Маппинг условных дней на календарные даты
            }
            self.save_config()
    
    def save_config(self):
        """Сохраняет конфигурацию."""
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def get_calendar_day(self, date=None):
        """Возвращает календарный день от начала проекта."""
        if date is None:
            date = datetime.now()
        return (date - self.project_start).days + 1
    
    def get_conditional_day(self):
        """Возвращает текущий условный день."""
        return self.config['current_conditional_day']
    
    def set_conditional_day(self, day):
        """Устанавливает условный день и сохраняет маппинг."""
        self.config['current_conditional_day'] = day
        today_str = datetime.now().strftime('%Y-%m-%d')
        self.config['day_mapping'][str(day)] = today_str
        self.save_config()
        
    def get_current_sprint(self):
        """Вычисляет текущий спринт на основе условного дня."""
        conditional_day = self.get_conditional_day()
        
        # Спринты по условным дням (из отчетов)
        sprint_ranges = {
            1: (1, 5),      # Sprint 1
            2: (6, 10),     # Sprint 2
            3: (11, 15),    # Sprint 3
            # ... добавляем остальные спринты
            28: (130, 134), # Sprint 28
            29: (135, 139), # Sprint 29
            30: (140, 144), # Sprint 30
            31: (145, 149), # Sprint 31
        }
        
        for sprint, (start, end) in sprint_ranges.items():
            if start <= conditional_day <= end:
                day_in_sprint = conditional_day - start + 1
                return sprint, day_in_sprint, end - start + 1
        
        # Если не нашли, вычисляем приблизительно
        sprint = (conditional_day - 1) // 5 + 1
        day_in_sprint = (conditional_day - 1) % 5 + 1
        return sprint, day_in_sprint, 5
    
    def get_file_name(self, file_type='daily'):
        """Генерирует правильное имя файла."""
        today = datetime.now()
        date_str = today.strftime('%Y%m%d')
        conditional_day = self.get_conditional_day()
        
        if file_type == 'daily':
            return f'DAY_{conditional_day:03d}_SUMMARY_{date_str}.md'
        elif file_type == 'completion':
            return f'DAY_{conditional_day:03d}_COMPLETION_REPORT_{date_str}.md'
        elif file_type == 'sprint_plan':
            sprint, _, _ = self.get_current_sprint()
            return f'SPRINT_{sprint:02d}_PLAN_{date_str}.md'
        elif file_type == 'sprint_completion':
            sprint, _, _ = self.get_current_sprint()
            return f'SPRINT_{sprint:02d}_COMPLETION_REPORT_{date_str}.md'
    
    def get_report_header(self):
        """Генерирует правильный заголовок для отчета."""
        conditional_day = self.get_conditional_day()
        calendar_day = self.get_calendar_day()
        sprint, day_in_sprint, sprint_days = self.get_current_sprint()
        date_human = datetime.now().strftime('%d %B %Y').replace(
            'January', 'января'
        ).replace(
            'February', 'февраля'
        ).replace(
            'March', 'марта'
        ).replace(
            'April', 'апреля'
        ).replace(
            'May', 'мая'
        ).replace(
            'June', 'июня'
        ).replace(
            'July', 'июля'
        ).replace(
            'August', 'августа'
        ).replace(
            'September', 'сентября'
        ).replace(
            'October', 'октября'
        ).replace(
            'November', 'ноября'
        ).replace(
            'December', 'декабря'
        )
        
        return f"""# День {conditional_day} (Календарный день {calendar_day}) - Sprint {sprint}, День {day_in_sprint}/{sprint_days}

**Дата**: {date_human}"""
    
    def sync_with_report_sh(self):
        """Синхронизирует данные с report.sh."""
        # Читаем текущий день из report.sh info
        import subprocess
        result = subprocess.run(
            ['./scripts/report.sh', 'info'], 
            capture_output=True, 
            text=True,
            cwd=self.project_root
        )
        
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            for line in lines:
                if 'День проекта:' in line:
                    day = int(line.split(':')[1].split('(')[0].strip())
                    self.set_conditional_day(day)
                    break
    
    def print_info(self):
        """Выводит текущую информацию."""
        conditional_day = self.get_conditional_day()
        calendar_day = self.get_calendar_day()
        sprint, day_in_sprint, sprint_days = self.get_current_sprint()
        
        print("=== Информация о времени проекта ===")
        print(f"Сегодня: {datetime.now().strftime('%d.%m.%Y')}")
        print(f"Условный день: {conditional_day}")
        print(f"Календарный день: {calendar_day}")
        print(f"Спринт: {sprint} (день {day_in_sprint}/{sprint_days})")
        print()
        print("=== Правильные имена файлов ===")
        print(f"Ежедневный отчет: {self.get_file_name('daily')}")
        print(f"Отчет завершения: {self.get_file_name('completion')}")
        print()
        print("=== Заголовок отчета ===")
        print(self.get_report_header())


def main():
    import sys
    
    manager = ProjectTimeManager()
    
    if len(sys.argv) < 2:
        manager.print_info()
        return
    
    command = sys.argv[1]
    
    if command == 'sync':
        manager.sync_with_report_sh()
        print("✅ Синхронизировано с report.sh")
    
    elif command == 'set-day':
        if len(sys.argv) < 3:
            print("Использование: project-time.py set-day <условный_день>")
            return
        day = int(sys.argv[2])
        manager.set_conditional_day(day)
        print(f"✅ Установлен условный день: {day}")
    
    elif command == 'filename':
        if len(sys.argv) < 3:
            file_type = 'daily'
        else:
            file_type = sys.argv[2]
        print(manager.get_file_name(file_type))
    
    elif command == 'header':
        print(manager.get_report_header())
    
    elif command == 'calendar-day':
        print(manager.get_calendar_day())
    
    elif command == 'conditional-day':
        print(manager.get_conditional_day())
    
    elif command == 'sprint':
        sprint, day, total = manager.get_current_sprint()
        print(f"{sprint},{day},{total}")
    
    else:
        print(f"Неизвестная команда: {command}")
        print("Доступные команды: sync, set-day, filename, header, calendar-day, conditional-day, sprint")


if __name__ == '__main__':
    main() 