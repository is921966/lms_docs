#!/usr/bin/env python3
"""Show all project days from the database"""

import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
# No external dependencies

# Database connection parameters
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'lms_db',
    'user': 'lms_user',
    'password': 'lms_pass'
}

def main():
    try:
        # Try default config first
        conn = psycopg2.connect(**DB_CONFIG)
    except:
        # If default fails, try env-based config
        try:
            DB_CONFIG.update({
                'database': 'app',
                'user': 'app',
                'password': '!ChangeMe!'
            })
            conn = psycopg2.connect(**DB_CONFIG)
        except Exception as e:
            print(f"❌ Cannot connect to database: {e}")
            return
            
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    # Get all records
    cursor.execute("""
        SELECT project_day, calendar_date, start_time, end_time, status, 
               sprint_name, test_coverage_percent, tests_total, tests_passed,
               tasks_completed, commits_count, files_changed
        FROM project_time_registry
        ORDER BY project_day ASC
    """)
    
    records = cursor.fetchall()
    
    if not records:
        print("❌ No records found in project_time_registry")
    else:
        print(f"\n📊 All {len(records)} days in project_time_registry:\n")
        
        # Prepare data for tabulate
        table_data = []
        
        for rec in records:
            day = rec['project_day']
            date = rec['calendar_date'].strftime('%Y-%m-%d') if rec['calendar_date'] else 'N/A'
            start = rec['start_time'].strftime('%m-%d %H:%M') if rec['start_time'] else 'N/A'
            end = rec['end_time'].strftime('%m-%d %H:%M') if rec['end_time'] else 'N/A'
            status = rec['status'] or 'N/A'
            sprint = rec['sprint_name'] or 'N/A'
            coverage = f"{rec['test_coverage_percent']:.1f}%" if rec['test_coverage_percent'] else 'N/A'
            tests = f"{rec['tests_passed'] or 0}/{rec['tests_total'] or 0}" if rec['tests_total'] else 'N/A'
            tasks = rec['tasks_completed'] or 0
            commits = rec['commits_count'] or 0
            
            table_data.append([
                day, date, status, sprint, start, end, 
                coverage, tests, tasks, commits
            ])
        
        # Print header
        print(f"{'Day':<5} {'Date':<12} {'Status':<10} {'Sprint':<15} {'Start':<13} {'End':<13} {'Coverage':<9} {'Tests':<10} {'Tasks':<6} {'Commits':<8}")
        print("-" * 110)
        
        # Print data
        for row in table_data:
            print(f"{row[0]:<5} {row[1]:<12} {row[2]:<10} {row[3]:<15} {row[4]:<13} {row[5]:<13} {row[6]:<9} {row[7]:<10} {row[8]:<6} {row[9]:<8}")
        
        # Summary statistics
        print(f"\n📈 Summary:")
        print(f"- Total days: {len(records)}")
        
        completed_days = [r for r in records if r['status'] == 'completed']
        print(f"- Completed days: {len(completed_days)}")
        
        total_tasks = sum(r['tasks_completed'] or 0 for r in records)
        print(f"- Total tasks completed: {total_tasks}")
        
        total_tests = sum(r['tests_passed'] or 0 for r in records)
        print(f"- Total tests passed: {total_tests}")
        
        total_commits = sum(r['commits_count'] or 0 for r in records)
        print(f"- Total commits: {total_commits}")
        
        # Sprints
        sprints = set(r['sprint_name'] for r in records if r['sprint_name'])
        print(f"- Total sprints: {len(sprints)}")
        print(f"- Sprints: {', '.join(sorted(sprints))}")
        
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main() 