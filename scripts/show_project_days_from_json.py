#!/usr/bin/env python3
"""Show all project days from exported JSON"""

import json
from datetime import datetime

def main():
    try:
        with open('project_time_export.json', 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print("❌ File project_time_export.json not found. Run 'python3 scripts/project_time_db.py export' first.")
        return
    except json.JSONDecodeError:
        print("❌ Invalid JSON in project_time_export.json")
        return
        
    if not data:
        print("❌ No records found in export file")
        return
        
    # Check if data is a list or dict with records key
    if isinstance(data, dict) and 'records' in data:
        records = data['records']
    elif isinstance(data, dict):
        records = list(data.values())
    else:
        records = data
        
    print(f"\n📊 All {len(records)} days in project time registry:\n")
    
    # Print header
    print(f"{'Day':<5} {'Date':<12} {'Status':<10} {'Sprint':<25} {'Tasks':<6} {'Tests':<10} {'Commits':<8}")
    print("-" * 85)
    
    # Print data
    for rec in sorted(records, key=lambda x: int(x.get('project_day', 0)) if isinstance(x, dict) else 0):
        if isinstance(rec, dict):
            day = rec.get('project_day', 'N/A')
            date = rec.get('calendar_date', 'N/A')
            if date != 'N/A' and len(date) > 10:
                date = date[:10]  # Get only date part
            status = rec.get('status', 'N/A')
            sprint = rec.get('sprint_name', 'N/A')
            if sprint and sprint != 'N/A' and len(sprint) > 23:
                sprint = sprint[:20] + '...'
            elif sprint is None:
                sprint = 'N/A'
            tasks = rec.get('tasks_completed', 0) or 0
            tests_passed = rec.get('tests_passed', 0) or 0
            tests_total = rec.get('tests_total', 0) or 0
            tests = f"{tests_passed}/{tests_total}" if tests_total else 'N/A'
            commits = rec.get('commits_count', 0) or 0
            
            print(f"{day:<5} {date:<12} {status:<10} {sprint:<25} {tasks:<6} {tests:<10} {commits:<8}")
    
    # Summary statistics
    print(f"\n📈 Summary:")
    print(f"- Total days: {len(records)}")
    
    # Count completed days
    completed_days = [r for r in records if isinstance(r, dict) and r.get('status') == 'completed']
    print(f"- Completed days: {len(completed_days)}")
    
    # Total tasks
    total_tasks = sum(r.get('tasks_completed', 0) or 0 for r in records if isinstance(r, dict))
    print(f"- Total tasks completed: {total_tasks}")
    
    # Total tests
    total_tests = sum(r.get('tests_passed', 0) or 0 for r in records if isinstance(r, dict))
    print(f"- Total tests passed: {total_tests}")
    
    # Total commits
    total_commits = sum(r.get('commits_count', 0) or 0 for r in records if isinstance(r, dict))
    print(f"- Total commits: {total_commits}")
    
    # Unique sprints
    sprints = set()
    for r in records:
        if isinstance(r, dict) and r.get('sprint_name'):
            sprints.add(r.get('sprint_name'))
    print(f"- Total unique sprints: {len(sprints)}")
    
    # Show last 5 days in detail
    print(f"\n📋 Last 5 days detail:")
    print("-" * 85)
    
    last_days = sorted(
        [r for r in records if isinstance(r, dict)], 
        key=lambda x: int(x.get('project_day', 0)),
        reverse=True
    )[:5]
    
    for rec in reversed(last_days):
        day = rec.get('project_day', 'N/A')
        date = rec.get('calendar_date', 'N/A')
        if date != 'N/A' and len(date) > 10:
            date = date[:10]
        sprint = rec.get('sprint_name', 'N/A')
        status = rec.get('status', 'N/A')
        
        print(f"\nDay {day} ({date}) - Sprint: {sprint}")
        print(f"  Status: {status}")
        
        if rec.get('daily_report_filename'):
            print(f"  Report: {rec.get('daily_report_filename')}")
        
        if rec.get('tasks_completed'):
            print(f"  Tasks completed: {rec.get('tasks_completed')}")
        
        if rec.get('tests_total'):
            print(f"  Tests: {rec.get('tests_passed', 0)}/{rec.get('tests_total')} passed")
        
        if rec.get('commits_count'):
            print(f"  Commits: {rec.get('commits_count')}")

if __name__ == "__main__":
    main() 