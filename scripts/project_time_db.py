#!/usr/bin/env python3
"""
Project Time Database Management
Manages centralized time tracking in PostgreSQL
"""

import os
import sys
import json
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, date, timedelta
from typing import Dict, List, Optional, Tuple
import argparse
from contextlib import contextmanager
from pathlib import Path

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'database': os.getenv('DB_DATABASE', 'lms'),
    'user': os.getenv('DB_USERNAME', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'secret')
}

PROJECT_START_DATE = date(2025, 6, 21)

from typing import List, Dict, Optional

class ProjectTimeDB:
    """Database manager for project time registry"""
    
    def __init__(self, config: Dict[str, str] = DB_CONFIG):
        self.config = config
        self.project_root = Path(__file__).parent.parent
        self.time_config_file = self.project_root / '.project-time.json'
        self._load_time_config()
        
    def _load_time_config(self):
        """Load time configuration with day mappings"""
        self.time_config = {
            'project_start': '2025-06-21',
            'current_conditional_day': 1,
            'day_mapping': {}
        }
        
        if self.time_config_file.exists():
            with open(self.time_config_file, 'r') as f:
                self.time_config = json.load(f)
    
    def get_calendar_date_for_project_day(self, project_day: int) -> date:
        """Get calendar date for a given project day using mapping or calculation"""
        # Check if we have a mapping for this day
        day_str = str(project_day)
        if day_str in self.time_config.get('day_mapping', {}):
            date_str = self.time_config['day_mapping'][day_str]
            return datetime.strptime(date_str, '%Y-%m-%d').date()
        
        # Otherwise, look for the nearest mapped day and calculate from there
        mapped_days = {int(k): v for k, v in self.time_config.get('day_mapping', {}).items()}
        if mapped_days:
            # Find the closest mapped day
            closest_day = min(mapped_days.keys(), key=lambda x: abs(x - project_day))
            closest_date = datetime.strptime(mapped_days[closest_day], '%Y-%m-%d').date()
            
            # Calculate the difference and apply it
            day_diff = project_day - closest_day
            return closest_date + timedelta(days=day_diff)
        
        # Fallback to simple calculation from project start
        return PROJECT_START_DATE + timedelta(days=project_day - 1)
        
    @contextmanager
    def get_connection(self):
        """Get database connection with context manager"""
        conn = None
        try:
            conn = psycopg2.connect(**self.config)
            yield conn
        finally:
            if conn:
                conn.close()
    
    def execute_migration(self, migration_file: str):
        """Execute SQL migration file"""
        with open(migration_file, 'r') as f:
            sql = f.read()
            
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql)
                conn.commit()
                print(f"✅ Migration executed: {migration_file}")
    
    def get_or_create_day(self, project_day: int) -> Dict:
        """Get existing day record or create new one"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                # Check if day exists
                cursor.execute(
                    "SELECT * FROM project_time_registry WHERE project_day = %s",
                    (project_day,)
                )
                record = cursor.fetchone()
                
                if record:
                    return dict(record)
                
                # Create new record with calendar_date
                sprint_number, sprint_day = self.calculate_sprint_info(project_day)
                calendar_date = self.get_calendar_date_for_project_day(project_day)
                
                cursor.execute("""
                    INSERT INTO project_time_registry 
                    (project_day, sprint_number, sprint_day, calendar_date, status)
                    VALUES (%s, %s, %s, %s, 'planned')
                    RETURNING *
                """, (project_day, sprint_number, sprint_day, calendar_date))
                
                conn.commit()
                return dict(cursor.fetchone())
    
    def calculate_sprint_info(self, project_day: int) -> Tuple[int, int]:
        """Calculate sprint number and day within sprint"""
        sprint_number = ((project_day - 1) // 5) + 1
        sprint_day = ((project_day - 1) % 5) + 1
        return sprint_number, sprint_day
    
    def start_day(self, project_day: int) -> Dict:
        """Start a new work day"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                # Check if day already exists
                cursor.execute("""
                    SELECT project_day, start_time, daily_report_path 
                    FROM project_time_registry 
                    WHERE project_day = %s
                """, (project_day,))
                existing = cursor.fetchone()
                
                sprint_number, sprint_day = self.calculate_sprint_info(project_day)
                current_timestamp = datetime.now()
                
                if existing:
                    # Update existing record
                    cursor.execute("""
                        UPDATE project_time_registry 
                        SET status = 'started', 
                            start_time = CURRENT_TIMESTAMP,
                            calendar_date = CURRENT_DATE,
                            sprint_number = %s,
                            sprint_day = %s
                        WHERE project_day = %s
                        RETURNING *
                    """, (sprint_number, sprint_day, project_day))
                else:
                    # Create new record
                    cursor.execute("""
                        INSERT INTO project_time_registry 
                        (project_day, sprint_number, sprint_day, start_time, calendar_date, status)
                        VALUES (%s, %s, %s, CURRENT_TIMESTAMP, CURRENT_DATE, 'started')
                        RETURNING *
                    """, (project_day, sprint_number, sprint_day))
                
                conn.commit()
                result = dict(cursor.fetchone())
                
                # Print report filename if available
                if result.get('daily_report_path'):
                    print(f"Report path: {result['daily_report_path']}")
                
                return result
    
    def end_day(self, project_day: int, metrics: Optional[Dict] = None) -> Dict:
        """End work day and update metrics"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                # Base update
                update_fields = [
                    "status = 'completed'",
                    "end_time = CURRENT_TIMESTAMP",
                    "duration_minutes = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - start_time))/60"
                ]
                values = []
                
                # Add metrics if provided
                if metrics:
                    for key, value in metrics.items():
                        if key in ['commits_count', 'files_changed', 'lines_added', 
                                  'lines_deleted', 'tests_total', 'tests_passed', 
                                  'tests_failed', 'tests_fixed', 'tasks_completed',
                                  'bugs_fixed', 'features_added']:
                            update_fields.append(f"{key} = %s")
                            values.append(value)
                
                values.append(project_day)
                
                sql = f"""
                    UPDATE project_time_registry 
                    SET {', '.join(update_fields)}
                    WHERE project_day = %s
                    RETURNING *
                """
                
                cursor.execute(sql, values)
                conn.commit()
                result = cursor.fetchone()
                if result:
                    return dict(result)
                else:
                    raise ValueError(f"Day {project_day} not found in database")
    
    def update_day_info(self, project_day: int, **kwargs) -> Dict:
        """Update day information"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                # Build update query dynamically
                update_fields = []
                values = []
                
                allowed_fields = [
                    'sprint_name', 'actual_work_time', 'test_coverage_percent',
                    'tasks_planned', 'daily_report_path', 'completion_report_path',
                    'notes', 'weather', 'mood', 'blockers'
                ]
                
                for key, value in kwargs.items():
                    if key in allowed_fields:
                        update_fields.append(f"{key} = %s")
                        values.append(value)
                
                if not update_fields:
                    return self.get_day(project_day)
                
                values.append(project_day)
                
                sql = f"""
                    UPDATE project_time_registry 
                    SET {', '.join(update_fields)}
                    WHERE project_day = %s
                    RETURNING *
                """
                
                cursor.execute(sql, values)
                conn.commit()
                result = cursor.fetchone()
                if result:
                    return dict(result)
                else:
                    raise ValueError(f"Day {project_day} not found in database")
    
    def get_day(self, project_day: int) -> Optional[Dict]:
        """Get day information"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute(
                    "SELECT * FROM project_time_registry WHERE project_day = %s",
                    (project_day,)
                )
                result = cursor.fetchone()
                return dict(result) if result else None
    
    def get_sprint_days(self, sprint_number: int) -> List[Dict]:
        """Get all days in a sprint"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("""
                    SELECT * FROM project_time_registry 
                    WHERE sprint_number = %s 
                    ORDER BY sprint_day
                """, (sprint_number,))
                return [dict(row) for row in cursor.fetchall()]
    
    def get_sprint_summary(self, sprint_number: int) -> Dict:
        """Get sprint summary statistics"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("""
                    SELECT * FROM sprint_summary 
                    WHERE sprint_number = %s
                """, (sprint_number,))
                result = cursor.fetchone()
                return dict(result) if result else {}
    
    def get_project_stats(self) -> Dict:
        """Get overall project statistics"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("""
                    SELECT 
                        COUNT(*) as total_days,
                        COUNT(DISTINCT sprint_number) as total_sprints,
                        SUM(duration_minutes) as total_minutes,
                        SUM(commits_count) as total_commits,
                        SUM(tests_fixed) as total_tests_fixed,
                        SUM(tasks_completed) as total_tasks_completed,
                        AVG(test_coverage_percent) as avg_test_coverage
                    FROM project_time_registry
                    WHERE status = 'completed'
                """)
                return dict(cursor.fetchone())
    
    def migrate_from_json(self, json_file: str = "scripts/time_tracking.json"):
        """Migrate existing data from time_tracking.json"""
        if not os.path.exists(json_file):
            print(f"❌ File not found: {json_file}")
            return
        
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        migrated = 0
        for day_str, day_data in data.get('days', {}).items():
            try:
                # Extract day number
                if day_str.startswith('day_'):
                    project_day = int(day_str.replace('day_', ''))
                else:
                    continue
                
                # Get or create day record
                record = self.get_or_create_day(project_day)
                
                # Update with data from JSON
                updates = {}
                
                # Time information
                if 'start_time' in day_data:
                    updates['start_time'] = day_data['start_time']
                if 'end_time' in day_data:
                    updates['end_time'] = day_data['end_time']
                    updates['status'] = 'completed'
                
                # Duration
                if 'duration_hours' in day_data:
                    updates['duration_minutes'] = int(float(day_data['duration_hours']) * 60)
                
                # Sprint info (use our calculation, not the JSON one)
                sprint_number, sprint_day = self.calculate_sprint_info(project_day)
                updates['sprint_number'] = sprint_number
                updates['sprint_day'] = sprint_day
                
                # Update calendar date if needed
                calendar_date = self.get_calendar_date_for_project_day(project_day)
                updates['calendar_date'] = calendar_date
                
                # Apply updates
                if updates:
                    # Build update query
                    update_fields = []
                    values = []
                    for key, value in updates.items():
                        if key != 'calendar_date':  # Skip calendar_date for now
                            update_fields.append(f"{key} = %s")
                            values.append(value)
                    
                    if update_fields:
                        values.append(project_day)
                        sql = f"""
                            UPDATE project_time_registry 
                            SET {', '.join(update_fields)}
                            WHERE project_day = %s
                        """
                        
                        with self.get_connection() as conn:
                            with conn.cursor() as cursor:
                                cursor.execute(sql, values)
                                conn.commit()
                    
                    # Update calendar date separately
                    with self.get_connection() as conn:
                        with conn.cursor() as cursor:
                            cursor.execute("""
                                UPDATE project_time_registry 
                                SET calendar_date = %s
                                WHERE project_day = %s
                            """, (calendar_date, project_day))
                            conn.commit()
                    
                    migrated += 1
                    
            except Exception as e:
                print(f"❌ Error migrating {day_str}: {e}")
        
        print(f"✅ Migrated {migrated} days from JSON")
    
    def fix_calendar_dates(self):
        """Fix all calendar dates based on .project-time.json mapping"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                # Get all records
                cursor.execute("SELECT project_day FROM project_time_registry ORDER BY project_day")
                days = cursor.fetchall()
                
                fixed = 0
                for record in days:
                    project_day = record['project_day']
                    correct_date = self.get_calendar_date_for_project_day(project_day)
                    
                    cursor.execute("""
                        UPDATE project_time_registry 
                        SET calendar_date = %s 
                        WHERE project_day = %s AND calendar_date != %s
                    """, (correct_date, project_day, correct_date))
                    
                    if cursor.rowcount > 0:
                        fixed += 1
                
                conn.commit()
                print(f"✅ Fixed calendar dates for {fixed} days")
    
    def export_to_json(self, output_file: str = "project_time_export.json"):
        """Export database to JSON for backup"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("""
                    SELECT * FROM project_time_registry 
                    ORDER BY project_day
                """)
                
                records = cursor.fetchall()
                
                # Convert datetime objects to strings
                export_data = []
                for record in records:
                    record_dict = dict(record)
                    for key, value in record_dict.items():
                        if isinstance(value, (datetime, date)):
                            record_dict[key] = value.isoformat()
                    export_data.append(record_dict)
                
                with open(output_file, 'w') as f:
                    json.dump({
                        'export_date': datetime.now().isoformat(),
                        'total_records': len(export_data),
                        'records': export_data
                    }, f, indent=2)
                
                print(f"✅ Exported {len(export_data)} records to {output_file}")

    def get_filename(self, project_day: Optional[int] = None) -> Optional[str]:
        """Get daily report filename for a day"""
        if project_day is None:
            project_day = self.get_current_day()
            
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT daily_report_filename 
                    FROM project_time_registry 
                    WHERE project_day = %s
                """, (project_day,))
                result = cursor.fetchone()
                
                if result and result[0]:
                    return result[0]
                else:
                    # Generate default filename if not in DB
                    return f"DAY_{project_day}_SUMMARY_{datetime.now().strftime('%Y%m%d')}.md"
                    
    def get_all_days(self) -> List[Dict]:
        """Get all days from registry"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("""
                    SELECT * FROM project_time_registry 
                    ORDER BY project_day ASC
                """)
                return [dict(row) for row in cursor.fetchall()]
                
    def get_stats(self) -> Optional[Dict]:
        """Get project statistics"""
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("""
                    SELECT 
                        COUNT(*) as total_days,
                        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_days,
                        MAX(sprint_number) as current_sprint,
                        MAX(project_day) as latest_day,
                        SUM(commits_count) as total_commits,
                        SUM(tests_fixed) as total_tests_fixed,
                        SUM(tasks_completed) as total_tasks_completed
                    FROM project_time_registry
                """)
                return dict(cursor.fetchone() or {})


def main():
    """CLI interface for database management"""
    parser = argparse.ArgumentParser(description='Project Time Database Management')
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # Initialize database
    init_parser = subparsers.add_parser('init', help='Initialize database with migration')
    
    # Migrate from JSON
    migrate_parser = subparsers.add_parser('migrate', help='Migrate from time_tracking.json')
    migrate_parser.add_argument('--file', default='scripts/time_tracking.json', help='JSON file to migrate from')
    
    # Fix calendar dates
    fix_parser = subparsers.add_parser('fix-dates', help='Fix calendar dates based on .project-time.json')
    
    # Start day
    start_parser = subparsers.add_parser('start', help='Start work day')
    start_parser.add_argument('day', type=int, help='Project day number')
    
    # End day
    end_parser = subparsers.add_parser('end', help='End work day')
    end_parser.add_argument('day', type=int, help='Project day number')
    
    # Get day info
    info_parser = subparsers.add_parser('info', help='Get day information')
    info_parser.add_argument('day', type=int, help='Project day number')
    
    # Export to JSON
    export_parser = subparsers.add_parser('export', help='Export database to JSON')
    export_parser.add_argument('--output', default='project_time_export.json', help='Output file')
    
    # Project stats
    stats_parser = subparsers.add_parser('stats', help='Show project statistics')
    
    # Get filename
    get_filename_parser = subparsers.add_parser('get-filename', help='Get daily report filename')
    get_filename_parser.add_argument('day', type=int, nargs='?', 
                                    help='Project day number (uses current if not specified)')
    
    args = parser.parse_args()
    
    db = ProjectTimeDB()
    
    if args.command == 'init':
        migration_file = 'database/migrations/020_create_project_time_registry.sql'
        if os.path.exists(migration_file):
            db.execute_migration(migration_file)
        else:
            print(f"❌ Migration file not found: {migration_file}")
    
    elif args.command == 'migrate':
        db.migrate_from_json(args.file)
    
    elif args.command == 'fix-dates':
        db.fix_calendar_dates()
    
    elif args.command == 'start':
        result = db.start_day(args.day)
        print(f"✅ Started day {args.day}")
        print(f"📅 Date: {result['calendar_date']}")
        print(f"🏃 Sprint: {result['sprint_number']}, Day {result['sprint_day']}")
    
    elif args.command == 'end':
        result = db.end_day(args.day)
        print(f"✅ Completed day {args.day}")
        if result.get('duration_minutes'):
            hours = result['duration_minutes'] / 60
            print(f"⏱️ Duration: {hours:.1f} hours")
    
    elif args.command == 'info':
        info = db.get_day(args.day)
        if info:
            print(f"\n📊 Day {args.day} Information:")
            print(f"📅 Date: {info['calendar_date']}")
            print(f"🏃 Sprint: {info['sprint_number']}, Day {info['sprint_day']}")
            print(f"📌 Status: {info['status']}")
            if info.get('daily_report_filename'):
                print(f"📄 Report filename: {info['daily_report_filename']}")
            if info.get('start_time'):
                print(f"🚀 Started: {info['start_time']}")
            if info.get('end_time'):
                print(f"✅ Ended: {info['end_time']}")
            if info.get('duration_minutes'):
                print(f"⏱️ Duration: {info['duration_minutes']/60:.1f} hours")
            if info.get('commits_count'):
                print(f"💾 Commits: {info['commits_count']}")
            if info.get('tests_passed') and info.get('tests_total'):
                pass_rate = info['tests_passed'] / info['tests_total'] * 100
                print(f"✅ Tests: {info['tests_passed']}/{info['tests_total']} ({pass_rate:.1f}%)")
            if info.get('notes'):
                print(f"📝 Notes: {info['notes']}")
        else:
            print(f"❌ No information found for day {args.day}")
    
    elif args.command == 'export':
        db.export_to_json(args.output)
    
    elif args.command == 'stats':
        stats = db.get_project_stats()
        print("\n📊 Project Statistics:")
        print(f"📅 Total days: {stats['total_days']}")
        print(f"🏃 Total sprints: {stats['total_sprints']}")
        if stats['total_minutes']:
            print(f"⏱️ Total time: {stats['total_minutes']/60:.1f} hours")
        print(f"💾 Total commits: {stats['total_commits']}")
        print(f"✅ Tests fixed: {stats['total_tests_fixed']}")
        print(f"📋 Tasks completed: {stats['total_tasks_completed']}")
        if stats['avg_test_coverage']:
            print(f"📊 Average test coverage: {stats['avg_test_coverage']:.1f}%")
    
    elif args.command == 'get-filename':
        day = args.day or db.get_current_day()
        filename = db.get_filename(day)
        print(filename)
    
    else:
        parser.print_help()


if __name__ == '__main__':
    main() 