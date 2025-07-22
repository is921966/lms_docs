#!/usr/bin/env python3
"""Quick script to check last days in project_time_registry"""

import psycopg2
from psycopg2.extras import RealDictCursor
import os
from datetime import datetime

# Database connection parameters
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'lms_db',
    'user': 'lms_user',
    'password': 'lms_pass'
}

try:
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    # Get last 10 records
    cursor.execute("""
        SELECT project_day, calendar_date, start_time, end_time, status, sprint_name
        FROM project_time_registry
        ORDER BY project_day DESC
        LIMIT 10
    """)
    
    records = cursor.fetchall()
    
    if not records:
        print("❌ No records found in project_time_registry")
    else:
        print(f"\n📊 Last {len(records)} days in project_time_registry:\n")
        print(f"{'Day':<6} {'Date':<12} {'Status':<12} {'Sprint':<15} {'Start Time':<20}")
        print("-" * 75)
        
        for rec in records:
            day = rec['project_day']
            date = rec['calendar_date'].strftime('%Y-%m-%d') if rec['calendar_date'] else 'N/A'
            status = rec['status'] or 'N/A'
            sprint = rec['sprint_name'] or 'N/A'
            start = rec['start_time'].strftime('%Y-%m-%d %H:%M') if rec['start_time'] else 'N/A'
            
            print(f"{day:<6} {date:<12} {status:<12} {sprint:<15} {start:<20}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {str(e)}") 