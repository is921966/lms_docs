#!/usr/bin/env python3
"""
Анализ пользовательского поведения на основе логов приложения.
Выявляет предпочтения пользователей, популярные функции, паттерны использования.
"""

import json
import sys
from datetime import datetime, timedelta
from collections import defaultdict, Counter
from typing import Dict, List, Tuple, Any
import argparse

class UserBehaviorAnalyzer:
    def __init__(self):
        self.logs = []
        self.sessions = defaultdict(list)
        self.user_actions = defaultdict(list)
        
    def load_logs(self, file_path: str):
        """Загрузка логов из JSON файла"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                if isinstance(data, list):
                    self.logs = data
                elif isinstance(data, dict) and 'logs' in data:
                    self.logs = data['logs']
                else:
                    raise ValueError("Неверный формат логов")
                
            print(f"✅ Загружено {len(self.logs)} записей логов")
            self._organize_by_session()
        except Exception as e:
            print(f"❌ Ошибка загрузки логов: {e}")
            sys.exit(1)
    
    def _organize_by_session(self):
        """Организация логов по сессиям и пользователям"""
        for log in self.logs:
            session_id = log.get('context', {}).get('sessionId', 'unknown')
            user_id = log.get('context', {}).get('userId', 'anonymous')
            
            self.sessions[session_id].append(log)
            self.user_actions[user_id].append(log)
    
    def analyze_feature_usage(self) -> Dict[str, int]:
        """Анализ частоты использования функций"""
        feature_usage = Counter()
        
        for log in self.logs:
            if log.get('category') == 'UI':
                # Извлекаем информацию о функции из деталей
                details = log.get('details', {})
                feature = details.get('feature') or details.get('button') or details.get('view')
                if feature:
                    feature_usage[feature] += 1
        
        return dict(feature_usage.most_common(20))
    
    def analyze_screen_time(self) -> Dict[str, float]:
        """Анализ времени, проведенного на экранах"""
        screen_times = defaultdict(list)
        
        for session_logs in self.sessions.values():
            # Сортируем логи по времени
            sorted_logs = sorted(session_logs, key=lambda x: x.get('timestamp', ''))
            
            current_screen = None
            enter_time = None
            
            for log in sorted_logs:
                if log.get('category') == 'Navigation':
                    screen = log.get('details', {}).get('to')
                    if screen and current_screen and enter_time:
                        # Вычисляем время на предыдущем экране
                        try:
                            exit_time = datetime.fromisoformat(log['timestamp'].replace('Z', '+00:00'))
                            duration = (exit_time - enter_time).total_seconds()
                            if duration > 0 and duration < 3600:  # Игнорируем слишком длинные сессии
                                screen_times[current_screen].append(duration)
                        except:
                            pass
                    
                    current_screen = screen
                    try:
                        enter_time = datetime.fromisoformat(log['timestamp'].replace('Z', '+00:00'))
                    except:
                        enter_time = None
        
        # Вычисляем среднее время для каждого экрана
        avg_screen_times = {}
        for screen, times in screen_times.items():
            if times:
                avg_screen_times[screen] = sum(times) / len(times)
        
        return dict(sorted(avg_screen_times.items(), key=lambda x: x[1], reverse=True)[:10])
    
    def analyze_navigation_flows(self) -> List[Tuple[str, int]]:
        """Анализ популярных навигационных путей"""
        flows = Counter()
        
        for session_logs in self.sessions.values():
            nav_logs = [log for log in session_logs if log.get('category') == 'Navigation']
            nav_logs.sort(key=lambda x: x.get('timestamp', ''))
            
            # Создаем пути из последовательных переходов
            for i in range(len(nav_logs) - 1):
                from_screen = nav_logs[i].get('details', {}).get('from', 'unknown')
                to_screen = nav_logs[i].get('details', {}).get('to', 'unknown')
                flow = f"{from_screen} → {to_screen}"
                flows[flow] += 1
        
        return flows.most_common(15)
    
    def analyze_error_patterns(self) -> Dict[str, List[Dict]]:
        """Анализ паттернов ошибок"""
        errors = defaultdict(list)
        
        for log in self.logs:
            if log.get('category') == 'Error' or log.get('level') == 'ERROR':
                error_type = log.get('details', {}).get('errorType', 'Unknown')
                errors[error_type].append({
                    'event': log.get('event'),
                    'timestamp': log.get('timestamp'),
                    'screen': log.get('context', {}).get('screen'),
                    'details': log.get('details', {})
                })
        
        # Сортируем по частоте
        sorted_errors = dict(sorted(errors.items(), key=lambda x: len(x[1]), reverse=True))
        
        # Оставляем только топ-10 и первые 3 примера каждой ошибки
        result = {}
        for error_type, instances in list(sorted_errors.items())[:10]:
            result[error_type] = instances[:3]
        
        return result
    
    def analyze_user_engagement(self) -> Dict[str, Any]:
        """Анализ вовлеченности пользователей"""
        engagement = {
            'daily_active_users': len(self.user_actions),
            'average_session_duration': 0,
            'average_actions_per_session': 0,
            'most_active_hours': {},
            'feature_adoption': {}
        }
        
        # Средняя длительность сессии
        session_durations = []
        for session_logs in self.sessions.values():
            if len(session_logs) >= 2:
                try:
                    start = datetime.fromisoformat(session_logs[0]['timestamp'].replace('Z', '+00:00'))
                    end = datetime.fromisoformat(session_logs[-1]['timestamp'].replace('Z', '+00:00'))
                    duration = (end - start).total_seconds()
                    if 0 < duration < 7200:  # Макс 2 часа
                        session_durations.append(duration)
                except:
                    pass
        
        if session_durations:
            engagement['average_session_duration'] = sum(session_durations) / len(session_durations)
        
        # Среднее количество действий за сессию
        actions_per_session = [len(logs) for logs in self.sessions.values()]
        if actions_per_session:
            engagement['average_actions_per_session'] = sum(actions_per_session) / len(actions_per_session)
        
        # Самые активные часы
        hours = Counter()
        for log in self.logs:
            try:
                timestamp = datetime.fromisoformat(log['timestamp'].replace('Z', '+00:00'))
                hours[timestamp.hour] += 1
            except:
                pass
        
        engagement['most_active_hours'] = dict(hours.most_common(5))
        
        return engagement
    
    def generate_report(self):
        """Генерация полного отчета"""
        print("\n" + "="*60)
        print("📊 АНАЛИЗ ПОЛЬЗОВАТЕЛЬСКОГО ПОВЕДЕНИЯ")
        print("="*60)
        
        # 1. Популярные функции
        print("\n🎯 ТОП-20 ИСПОЛЬЗУЕМЫХ ФУНКЦИЙ:")
        feature_usage = self.analyze_feature_usage()
        for i, (feature, count) in enumerate(feature_usage.items(), 1):
            print(f"{i:2}. {feature:<30} - {count:>5} использований")
        
        # 2. Время на экранах
        print("\n⏱️  СРЕДНЕЕ ВРЕМЯ НА ЭКРАНАХ (секунды):")
        screen_times = self.analyze_screen_time()
        for screen, avg_time in screen_times.items():
            print(f"   {screen:<30} - {avg_time:>6.1f} сек")
        
        # 3. Навигационные паттерны
        print("\n🔄 ПОПУЛЯРНЫЕ НАВИГАЦИОННЫЕ ПУТИ:")
        nav_flows = self.analyze_navigation_flows()
        for flow, count in nav_flows:
            print(f"   {flow:<40} - {count:>3} раз")
        
        # 4. Паттерны ошибок
        print("\n❌ ЧАСТЫЕ ОШИБКИ:")
        errors = self.analyze_error_patterns()
        for error_type, instances in errors.items():
            print(f"\n   {error_type} ({len(instances)} случаев):")
            for instance in instances[:1]:  # Показываем только первый пример
                print(f"      - {instance['event']} на экране {instance['screen']}")
        
        # 5. Вовлеченность
        print("\n📈 МЕТРИКИ ВОВЛЕЧЕННОСТИ:")
        engagement = self.analyze_user_engagement()
        print(f"   Активных пользователей: {engagement['daily_active_users']}")
        print(f"   Средняя длительность сессии: {engagement['average_session_duration']:.1f} сек")
        print(f"   Среднее кол-во действий за сессию: {engagement['average_actions_per_session']:.1f}")
        print(f"   Самые активные часы: {engagement['most_active_hours']}")
        
        print("\n" + "="*60)
        
        # Сохранение в JSON
        report = {
            'generated_at': datetime.now().isoformat(),
            'total_logs': len(self.logs),
            'feature_usage': feature_usage,
            'screen_times': screen_times,
            'navigation_flows': [{'flow': f, 'count': c} for f, c in nav_flows],
            'error_patterns': errors,
            'engagement': engagement
        }
        
        with open('user_behavior_report.json', 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print("\n✅ Отчет сохранен в user_behavior_report.json")

def main():
    parser = argparse.ArgumentParser(description='Анализ пользовательского поведения из логов')
    parser.add_argument('log_file', help='Путь к файлу с логами (JSON)')
    parser.add_argument('--user', help='Анализировать только конкретного пользователя')
    parser.add_argument('--date', help='Анализировать только логи за дату (YYYY-MM-DD)')
    
    args = parser.parse_args()
    
    analyzer = UserBehaviorAnalyzer()
    analyzer.load_logs(args.log_file)
    analyzer.generate_report()

if __name__ == "__main__":
    main() 