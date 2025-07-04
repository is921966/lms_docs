#!/usr/bin/env python3
"""
Database Query Helper
Простой способ делать запросы к БД без зависаний psql
"""

import sys
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import argparse

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'port': '5432',
    'database': 'lms',
    'user': 'postgres',
    'password': 'secret'
}

def execute_query(query, limit=None):
    """Execute query and print results"""
    if limit and 'LIMIT' not in query.upper():
        query += f' LIMIT {limit}'
    
    try:
        with psycopg2.connect(**DB_CONFIG) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute(query)
                
                # For SELECT queries
                if cursor.description:
                    rows = cursor.fetchall()
                    
                    if not rows:
                        print("No results found.")
                        return
                    
                    # Print results
                    for i, row in enumerate(rows):
                        print(f"=== Record {i+1} ===")
                        for key, value in row.items():
                            if isinstance(value, datetime):
                                value = value.strftime('%Y-%m-%d %H:%M:%S')
                            print(f"{key}: {value}")
                        print()
                else:
                    # For UPDATE/INSERT/DELETE
                    print(f"Query executed. Rows affected: {cursor.rowcount}")
                    
    except Exception as e:
        print(f"Error: {e}")

def main():
    parser = argparse.ArgumentParser(description='Database Query Helper')
    parser.add_argument('query', nargs='?', help='SQL query to execute')
    parser.add_argument('--limit', type=int, help='Limit number of results')
    parser.add_argument('--last-days', action='store_true', help='Show last N days from registry')
    parser.add_argument('--stats', action='store_true', help='Show project statistics')
    
    args = parser.parse_args()
    
    if args.last_days:
        query = """
            SELECT project_day, calendar_date, sprint_number, sprint_day, 
                   status, start_time, end_time, duration_minutes
            FROM project_time_registry 
            ORDER BY project_day DESC
        """
        execute_query(query, limit=args.limit or 10)
    
    elif args.stats:
        query = """
            SELECT 
                COUNT(*) as total_days,
                COUNT(DISTINCT sprint_number) as total_sprints,
                SUM(duration_minutes) as total_minutes,
                COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_days,
                COUNT(CASE WHEN status = 'started' THEN 1 END) as active_days,
                COUNT(CASE WHEN status = 'planned' THEN 1 END) as planned_days
            FROM project_time_registry
        """
        execute_query(query)
    
    elif args.query:
        execute_query(args.query, limit=args.limit)
    
    else:
        parser.print_help()

if __name__ == '__main__':
    main() 