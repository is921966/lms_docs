#!/usr/bin/env python3
"""Show last 10 records from project time database"""

from project_time_db import ProjectTimeDB

def main():
    db = ProjectTimeDB()
    all_days = db.get_all_days()
    
    if not all_days:
        print("❌ Нет записей в БД")
        return
        
    # Get last 10 records
    last_10 = all_days[-10:]
    
    print("📊 Последние 10 записей из БД учета времени:")
    print("=" * 80)
    
    for record in last_10:
        sprint_name = record.get('sprint_name') or f"Sprint {record.get('sprint_number', '?')}"
        status_emoji = "✅" if record.get('status') == 'completed' else "🔄" if record.get('status') == 'started' else "📅"
        
        print(f"{status_emoji} День {record['project_day']} ({record['calendar_date']}) - {sprint_name} день {record.get('sprint_day', '?')} - Статус: {record.get('status', 'unknown')}")
    
    print("=" * 80)
    print(f"Всего записей в БД: {len(all_days)}")
    print(f"Текущий спринт: Sprint {all_days[-1].get('sprint_number', '?')}")
    print(f"Текущий день: {all_days[-1].get('project_day', '?')}")

if __name__ == "__main__":
    main() 