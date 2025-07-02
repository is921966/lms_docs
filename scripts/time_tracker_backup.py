#!/usr/bin/env python3
"""
Time Tracker for LMS Development Project
Tracks start/end times for days and sprints with duration calculations
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path

class TimeTracker:
    def __init__(self, base_path="/Users/ishirokov/lms_docs"):
        self.base_path = Path(base_path)
        self.data_file = self.base_path / "scripts" / "time_tracking.json"
        self.project_start_date = datetime(2025, 6, 1, 9, 0, 0)  # 1 июня 2025, 09:00
        
        # НОВОЕ: Смещение для условных дней проекта
        # Если у нас уже 96 условных дней, а календарный день 31
        # то смещение = 96 - 31 = 65
        self.project_day_offset = 65  # Настраиваемое смещение
        
        self.data = self._load_data()
    
    def _load_data(self):
        """Загрузка данных отслеживания времени"""
        if self.data_file.exists():
            try:
                with open(self.data_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    # НОВОЕ: Загружаем смещение если есть
                    if 'project_day_offset' in data:
                        self.project_day_offset = data['project_day_offset']
                    
                    # НОВОЕ: Загружаем смещение если есть
                    if 'project_day_offset' in data:
                        self.project_day_offset = data['project_day_offset']
                    
                    # Конвертируем строки обратно в datetime
                    for day_key, day_data in data.get('days', {}).items():
                        if 'start_time' in day_data and day_data['start_time']:
                            day_data['start_time'] = datetime.fromisoformat(day_data['start_time'])
                        if 'end_time' in day_data and day_data['end_time']:
                            day_data['end_time'] = datetime.fromisoformat(day_data['end_time'])
                    
                    for sprint_key, sprint_data in data.get('sprints', {}).items():
                        if 'start_time' in sprint_data and sprint_data['start_time']:
                            sprint_data['start_time'] = datetime.fromisoformat(sprint_data['start_time'])
                        if 'end_time' in sprint_data and sprint_data['end_time']:
                            sprint_data['end_time'] = datetime.fromisoformat(sprint_data['end_time'])
                    
                    return data
            except (json.JSONDecodeError, ValueError) as e:
                print(f"Ошибка загрузки данных: {e}")
                
        return {
            'days': {},
            'sprints': {},
            'project_start': self.project_start_date.isoformat()
        }
    
    def _save_data(self):
        """Сохранение данных отслеживания времени"""
        # Конвертируем datetime в строки для JSON
        data_to_save = {
            'days': {},
            'sprints': {},
            ''project_start': self.data['project_start'],
            'project_day_offset': self.project_day_offset  # НОВОЕ: сохраняем смещение
            'project_day_offset': self.project_day_offset  # НОВОЕ: сохраняем смещение
        }
        
        for day_key, day_data in self.data['days'].items():
            data_to_save['days'][day_key] = day_data.copy()
            if 'start_time' in day_data and isinstance(day_data['start_time'], datetime):
                data_to_save['days'][day_key]['start_time'] = day_data['start_time'].isoformat()
            if 'end_time' in day_data and isinstance(day_data['end_time'], datetime):
                data_to_save['days'][day_key]['end_time'] = day_data['end_time'].isoformat()
        
        for sprint_key, sprint_data in self.data['sprints'].items():
            data_to_save['sprints'][sprint_key] = sprint_data.copy()
            if 'start_time' in sprint_data and isinstance(sprint_data['start_time'], datetime):
                data_to_save['sprints'][sprint_key]['start_time'] = sprint_data['start_time'].isoformat()
            if 'end_time' in sprint_data and isinstance(sprint_data['end_time'], datetime):
                data_to_save['sprints'][sprint_key]['end_time'] = sprint_data['end_time'].isoformat()
        
        # Создаем директорию если не существует
        self.data_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(self.data_file, 'w', encoding='utf-8') as f:
            json.dump(data_to_save, f, indent=2, ensure_ascii=False)
    
    def calculate_day_number(self, target_date=None):
        """Вычисление календарного номера дня проекта"""
        if target_date is None:
            target_date = datetime.now().date()
        elif isinstance(target_date, datetime):
            target_date = target_date.date()
        
        project_start = self.project_start_date.date()
        delta = target_date - project_start
        return delta.days + 1
    
    def calculate_project_day_number(self, calendar_day=None):
        """Вычисление условного номера дня проекта"""
        if calendar_day is None:
            calendar_day = self.calculate_day_number()
        
        return calendar_day + self.project_day_offset
    
    def calculate_sprint_info(self, day_number, use_project_days=False):
        """Вычисление информации о спринте"""
        if use_project_days:
            # Для условных дней используем стандартную формулу
            sprint_number = ((day_number - 1) // 5) + 1
        else:
            # Для календарных дней учитываем смещение для спринтов
            sprint_number = ((day_number - 1) // 5) + 11  # +11 чтобы День 31 был Спринт 17
        
        day_in_sprint = ((day_number - 1) % 5) + 1
        return sprint_number, day_in_sprint
    
    def start_day(self, day_number=None, custom_time=None):
        """Начало дня разработки"""
        current_time = custom_time or datetime.now()
        
        if day_number is None:
            day_number = self.calculate_day_number(current_time)
        
        # Вычисляем оба типа дней
        calendar_day = day_number
        project_day = self.calculate_project_day_number(calendar_day)
        
        day_key = f"day_{calendar_day}"
        sprint_number, day_in_sprint = self.calculate_sprint_info(calendar_day)
        
        # Записываем начало дня
        if day_key not in self.data['days']:
            self.data['days'][day_key] = {}
        
        self.data['days'][day_key].update({
            'calendar_day': calendar_day,
            'project_day': project_day,  # НОВОЕ: условный день
            'sprint_number': sprint_number,
            'day_in_sprint': day_in_sprint,
            'start_time': current_time,
            'date': current_time.strftime('%Y-%m-%d')
        })
        
        # Если это первый день спринта, записываем начало спринта
        sprint_key = f"sprint_{sprint_number}"
        if day_in_sprint == 1:
            if sprint_key not in self.data['sprints']:
                self.data['sprints'][sprint_key] = {}
            
            if 'start_time' not in self.data['sprints'][sprint_key]:
                self.data['sprints'][sprint_key].update({
                    'sprint_number': sprint_number,
                    'start_time': current_time,
                    'start_date': current_time.strftime('%Y-%m-%d')
                })
        
        self._save_data()
        
        return {
            'calendar_day': calendar_day,
            'project_day': project_day,  # НОВОЕ
            'sprint_number': sprint_number,
            'day_in_sprint': day_in_sprint,
            'start_time': current_time.strftime('%Y-%m-%d %H:%M:%S'),
            'date': current_time.strftime('%Y-%m-%d')
        }
    
    def end_day(self, day_number=None, custom_time=None):
        """Завершение дня разработки"""
        current_time = custom_time or datetime.now()
        
        if day_number is None:
            day_number = self.calculate_day_number(current_time)
        
        # Вычисляем оба типа дней
        calendar_day = day_number
        project_day = self.calculate_project_day_number(calendar_day)
        
        day_key = f"day_{calendar_day}"
        sprint_number, day_in_sprint = self.calculate_sprint_info(calendar_day)
        
        # Обновляем информацию о завершении дня
        if day_key not in self.data['days']:
            self.data['days'][day_key] = {
                'calendar_day': calendar_day,
                'project_day': project_day,
                'sprint_number': sprint_number,
                'day_in_sprint': day_in_sprint,
                'date': current_time.strftime('%Y-%m-%d')
            }
        
        self.data['days'][day_key]['end_time'] = current_time
        
        # Вычисляем продолжительность дня
        if 'start_time' in self.data['days'][day_key]:
            start_time = self.data['days'][day_key]['start_time']
            if isinstance(start_time, str):
                start_time = datetime.fromisoformat(start_time)
            
            duration = current_time - start_time
            self.data['days'][day_key]['duration_hours'] = round(duration.total_seconds() / 3600, 2)
            self.data['days'][day_key]['duration_formatted'] = self._format_duration(duration)
        
        # Если это последний день спринта, записываем завершение спринта
        sprint_key = f"sprint_{sprint_number}"
        if day_in_sprint == 5:
            if sprint_key not in self.data['sprints']:
                self.data['sprints'][sprint_key] = {
                    'sprint_number': sprint_number
                }
            
            self.data['sprints'][sprint_key]['end_time'] = current_time
            self.data['sprints'][sprint_key]['end_date'] = current_time.strftime('%Y-%m-%d')
            
            # Вычисляем продолжительность спринта
            if 'start_time' in self.data['sprints'][sprint_key]:
                start_time = self.data['sprints'][sprint_key]['start_time']
                if isinstance(start_time, str):
                    start_time = datetime.fromisoformat(start_time)
                
                duration = current_time - start_time
                self.data['sprints'][sprint_key]['duration_hours'] = round(duration.total_seconds() / 3600, 2)
                self.data['sprints'][sprint_key]['duration_formatted'] = self._format_duration(duration)
                self.data['sprints'][sprint_key]['duration_days'] = round(duration.total_seconds() / (24 * 3600), 2)
        
        self._save_data()
        
        result = {
            'calendar_day': calendar_day,
            'project_day': project_day,  # НОВОЕ
            'sprint_number': sprint_number,
            'day_in_sprint': day_in_sprint,
            'end_time': current_time.strftime('%Y-%m-%d %H:%M:%S'),
            'date': current_time.strftime('%Y-%m-%d')
        }
        
        if 'duration_hours' in self.data['days'][day_key]:
            result['duration_hours'] = self.data['days'][day_key]['duration_hours']
            result['duration_formatted'] = self.data['days'][day_key]['duration_formatted']
        
        return result
    
    def get_day_info(self, day_number=None):
        """Получение информации о дне"""
        if day_number is None:
            day_number = self.calculate_day_number()
        
        calendar_day = day_number
        project_day = self.calculate_project_day_number(calendar_day)
        
        day_key = f"day_{calendar_day}"
        sprint_number, day_in_sprint = self.calculate_sprint_info(calendar_day)
        
        day_data = self.data['days'].get(day_key, {})
        
        result = {
            'calendar_day': calendar_day,
            'project_day': project_day,  # НОВОЕ
            'sprint_number': sprint_number,
            'day_in_sprint': day_in_sprint,
            'date': datetime.now().strftime('%Y-%m-%d')
        }
        
        if 'start_time' in day_data:
            start_time = day_data['start_time']
            if isinstance(start_time, str):
                start_time = datetime.fromisoformat(start_time)
            result['start_time'] = start_time.strftime('%Y-%m-%d %H:%M:%S')
        
        if 'end_time' in day_data:
            end_time = day_data['end_time']
            if isinstance(end_time, str):
                end_time = datetime.fromisoformat(end_time)
            result['end_time'] = end_time.strftime('%Y-%m-%d %H:%M:%S')
        
        if 'duration_hours' in day_data:
            result['duration_hours'] = day_data['duration_hours']
            result['duration_formatted'] = day_data['duration_formatted']
        
        return result
    
    def get_sprint_info(self, sprint_number=None):
        """Получение информации о спринте"""
        if sprint_number is None:
            day_number = self.calculate_day_number()
            sprint_number, _ = self.calculate_sprint_info(day_number)
        
        sprint_key = f"sprint_{sprint_number}"
        sprint_data = self.data['sprints'].get(sprint_key, {})
        
        result = {
            'sprint_number': sprint_number
        }
        
        if 'start_time' in sprint_data:
            start_time = sprint_data['start_time']
            if isinstance(start_time, str):
                start_time = datetime.fromisoformat(start_time)
            result['start_time'] = start_time.strftime('%Y-%m-%d %H:%M:%S')
            result['start_date'] = start_time.strftime('%Y-%m-%d')
        
        if 'end_time' in sprint_data:
            end_time = sprint_data['end_time']
            if isinstance(end_time, str):
                end_time = datetime.fromisoformat(end_time)
            result['end_time'] = end_time.strftime('%Y-%m-%d %H:%M:%S')
            result['end_date'] = end_time.strftime('%Y-%m-%d')
        
        if 'duration_hours' in sprint_data:
            result['duration_hours'] = sprint_data['duration_hours']
            result['duration_formatted'] = sprint_data['duration_formatted']
            result['duration_days'] = sprint_data['duration_days']
        
        return result
    
    def get_project_statistics(self):
        """Получение общей статистики проекта"""
        current_time = datetime.now()
        project_duration = current_time - self.project_start_date
        
        total_work_hours = sum(
            day_data.get('duration_hours', 0) 
            for day_data in self.data['days'].values()
        )
        
        completed_days = len([
            day_data for day_data in self.data['days'].values()
            if 'end_time' in day_data
        ])
        
        completed_sprints = len([
            sprint_data for sprint_data in self.data['sprints'].values()
            if 'end_time' in sprint_data
        ])
        
        return {
            ''project_start': self.data['project_start'],
            'current_time': current_time.strftime('%Y-%m-%d %H:%M:%S'),
            'project_duration_days': project_duration.days,
            'project_duration_formatted': self._format_duration(project_duration),
            'total_work_hours': round(total_work_hours, 2),
            'completed_days': completed_days,
            'completed_sprints': completed_sprints,
            'average_hours_per_day': round(total_work_hours / max(completed_days, 1), 2)
        }
    
    def _format_duration(self, duration):
        """Форматирование продолжительности"""
        total_seconds = int(duration.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        
        if hours > 0:
            return f"{hours}ч {minutes}м"
        else:
            return f"{minutes}м"

def main():
    import sys
    
    tracker = TimeTracker()
    
    if len(sys.argv) < 2:
        print("Использование:")
        print("  python time_tracker.py start-day [day_number]")
        print("  python time_tracker.py end-day [day_number]")
        print("  python time_tracker.py day-info [day_number]")
        print("  python time_tracker.py sprint-info [sprint_number]")
        print("  python time_tracker.py project-stats")
        print("  python time_tracker.py set-offset <число>")
        return
    
    command = sys.argv[1]
    
    if command == "start-day":
        day_number = int(sys.argv[2]) if len(sys.argv) > 2 else None
        result = tracker.start_day(day_number)
        print(f"🚀 Начат календарный день {result['calendar_day']} (условный день {result['project_day']})")
        print(f"📊 Спринт {result['sprint_number']}, День {result['day_in_sprint']}/5")
        print(f"📅 Дата: {result['date']}")
        print(f"⏰ Время начала: {result['start_time']}")
    
    elif command == "end-day":
        day_number = int(sys.argv[2]) if len(sys.argv) > 2 else None
        result = tracker.end_day(day_number)
        print(f"✅ Завершен календарный день {result['calendar_day']} (условный день {result['project_day']})")
        print(f"📊 Спринт {result['sprint_number']}, День {result['day_in_sprint']}/5")
        print(f"📅 Дата: {result['date']}")
        print(f"⏰ Время завершения: {result['end_time']}")
        if 'duration_formatted' in result:
            print(f"⏱️ Продолжительность: {result['duration_formatted']} ({result['duration_hours']}ч)")
    
    elif command == "day-info":
        day_number = int(sys.argv[2]) if len(sys.argv) > 2 else None
        result = tracker.get_day_info(day_number)
        print(f"📊 Календарный день {result['calendar_day']} (условный день {result['project_day']})")
        print(f"📊 Спринт {result['sprint_number']}, День {result['day_in_sprint']}/5")
        print(f"📅 Дата: {result['date']}")
        if 'start_time' in result:
            print(f"🚀 Начало: {result['start_time']}")
        if 'end_time' in result:
            print(f"✅ Завершение: {result['end_time']}")
        if 'duration_formatted' in result:
            print(f"⏱️ Продолжительность: {result['duration_formatted']} ({result['duration_hours']}ч)")
    
    elif command == "sprint-info":
        sprint_number = int(sys.argv[2]) if len(sys.argv) > 2 else None
        result = tracker.get_sprint_info(sprint_number)
        print(f"📊 Информация о спринте {result['sprint_number']}")
        if 'start_date' in result:
            print(f"🚀 Начало: {result['start_date']} {result['start_time']}")
        if 'end_date' in result:
            print(f"✅ Завершение: {result['end_date']} {result['end_time']}")
        if 'duration_formatted' in result:
            print(f"⏱️ Продолжительность: {result['duration_days']} дней ({result['duration_formatted']})")
    
    elif command == "project-stats":
        result = tracker.get_project_statistics()
        print("📊 Статистика проекта:")
        print(f"🚀 Начало проекта: {result['project_start']}")
        print(f"📅 Текущее время: {result['current_time']}")
        print(f"📆 Дней с начала проекта: {result['project_duration_days']}")
        print(f"⏱️ Общее время работы: {result['total_work_hours']}ч")
        print(f"✅ Завершенных дней: {result['completed_days']}")
        print(f"🏁 Завершенных спринтов: {result['completed_sprints']}")
        print(f"📈 Среднее время в день: {result['average_hours_per_day']}ч")
    
    elif command == "set-offset":
        if len(sys.argv) < 3:
            print("Использование: python time_tracker.py set-offset <число>")
            print(f"Текущее смещение: {tracker.project_day_offset}")
            return
        
        new_offset = int(sys.argv[2])
        tracker.project_day_offset = new_offset
        
        # Сохраняем смещение в данные
        tracker.data['project_day_offset'] = new_offset
        tracker._save_data()
        
        print(f"✅ Смещение условных дней установлено: {new_offset}")
        
        # Показываем пример
        current_calendar_day = tracker.calculate_day_number()
        current_project_day = tracker.calculate_project_day_number(current_calendar_day)
        print(f"📊 Календарный день {current_calendar_day} → условный день {current_project_day}")
    
    else:
        print(f"Неизвестная команда: {command}")
        print("\nДоступные команды:")
        print("  start-day [day_number]")
        print("  end-day [day_number]") 
        print("  day-info [day_number]")
        print("  sprint-info [sprint_number]")
        print("  project-stats")
        print("  set-offset <число>  # Настройка смещения условных дней")

if __name__ == "__main__":
    main()
