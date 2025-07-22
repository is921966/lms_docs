#!/bin/bash

# iOS App Test Runner via Comprehensive Logging
# Запускает тесты приложения через анализ логов

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
APP_DIR="LMS_App/LMS"
LOGS_DIR="$APP_DIR/Logs"
ANALYZER_SCRIPT="scripts/analyze_app_logs.py"

# Functions
print_header() {
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}iOS App Test Runner${NC}"
    echo -e "${GREEN}================================${NC}"
}

print_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  test-login <email>     Test login flow for specific email"
    echo "  test-navigation        Analyze navigation path"
    echo "  test-performance       Check performance metrics"
    echo "  test-view <view_name>  Analyze specific view interactions"
    echo "  full-report           Generate full test report"
    echo "  live-monitor          Monitor logs in real-time"
    echo ""
    echo "Options:"
    echo "  --output <file>       Save report to file"
    echo "  --date <YYYY-MM-DD>   Analyze logs from specific date"
}

get_latest_log() {
    local date_filter=$1
    if [ -n "$date_filter" ]; then
        find "$LOGS_DIR" -name "log_${date_filter}.json" -type f | head -1
    else
        find "$LOGS_DIR" -name "log_*.json" -type f | sort -r | head -1
    fi
}

test_login() {
    local email=$1
    local log_file=$(get_latest_log "$DATE_FILTER")
    
    if [ -z "$log_file" ]; then
        echo -e "${RED}No log files found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Testing login flow for: $email${NC}"
    echo -e "${YELLOW}Using log file: $log_file${NC}"
    echo ""
    
    python3 "$ANALYZER_SCRIPT" "$log_file" --test login --email "$email" $OUTPUT_ARG
}

test_navigation() {
    local log_file=$(get_latest_log "$DATE_FILTER")
    
    if [ -z "$log_file" ]; then
        echo -e "${RED}No log files found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Analyzing navigation path${NC}"
    echo -e "${YELLOW}Using log file: $log_file${NC}"
    echo ""
    
    python3 "$ANALYZER_SCRIPT" "$log_file" --test navigation $OUTPUT_ARG
}

test_performance() {
    local log_file=$(get_latest_log "$DATE_FILTER")
    
    if [ -z "$log_file" ]; then
        echo -e "${RED}No log files found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Checking performance metrics${NC}"
    echo -e "${YELLOW}Using log file: $log_file${NC}"
    echo ""
    
    python3 "$ANALYZER_SCRIPT" "$log_file" --test performance $OUTPUT_ARG
}

test_view() {
    local view_name=$1
    local log_file=$(get_latest_log "$DATE_FILTER")
    
    if [ -z "$log_file" ]; then
        echo -e "${RED}No log files found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Analyzing view: $view_name${NC}"
    echo -e "${YELLOW}Using log file: $log_file${NC}"
    echo ""
    
    python3 "$ANALYZER_SCRIPT" "$log_file" --view "$view_name" $OUTPUT_ARG
}

full_report() {
    local log_file=$(get_latest_log "$DATE_FILTER")
    
    if [ -z "$log_file" ]; then
        echo -e "${RED}No log files found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Generating full test report${NC}"
    echo -e "${YELLOW}Using log file: $log_file${NC}"
    echo ""
    
    python3 "$ANALYZER_SCRIPT" "$log_file" --test full $OUTPUT_ARG
}

live_monitor() {
    echo -e "${YELLOW}Starting live log monitor...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    
    # Create a simple monitor script
    cat > /tmp/ios_log_monitor.py << 'EOF'
import time
import json
import sys
from datetime import datetime

last_position = 0
current_file = None

def get_latest_log_file():
    from pathlib import Path
    logs_dir = Path("LMS_App/LMS/Logs")
    if not logs_dir.exists():
        return None
    
    today = datetime.now().strftime("%Y-%m-%d")
    log_file = logs_dir / f"log_{today}.json"
    
    if log_file.exists():
        return str(log_file)
    return None

def parse_log_entry(entry):
    timestamp = entry.get('timestamp', '')
    category = entry.get('category', '')
    level = entry.get('level', '')
    event = entry.get('event', '')
    
    # Color codes
    colors = {
        'ERROR': '\033[0;31m',
        'WARNING': '\033[1;33m',
        'INFO': '\033[0;36m',
        'DEBUG': '\033[0;37m'
    }
    
    color = colors.get(level, '\033[0m')
    reset = '\033[0m'
    
    print(f"{color}[{timestamp}] [{category}] {event}{reset}")
    
    # Print important details
    details = entry.get('details', {})
    if category == 'UI' and details:
        if 'buttonName' in details:
            print(f"  Button: {details['buttonName']}")
        if 'fieldName' in details:
            print(f"  Field: {details['fieldName']} = {details.get('newValue', '')}")
    elif category == 'Navigation' and details:
        print(f"  From: {details.get('from', 'Unknown')} → To: {details.get('to', 'Unknown')}")
    elif category == 'Network' and details:
        print(f"  {details.get('method', 'GET')} {details.get('url', '')} - Status: {details.get('statusCode', 'pending')}")

print("Monitoring iOS app logs...")
print("=" * 50)

while True:
    try:
        log_file = get_latest_log_file()
        if not log_file:
            time.sleep(1)
            continue
        
        if log_file != current_file:
            current_file = log_file
            last_position = 0
            print(f"\nMonitoring: {log_file}")
        
        with open(log_file, 'r') as f:
            f.seek(last_position)
            new_content = f.read()
            
            if new_content:
                # Try to parse as JSON array or individual entries
                try:
                    if new_content.strip().startswith('['):
                        entries = json.loads(new_content)
                    else:
                        # Handle comma-separated entries
                        entries = []
                        for line in new_content.strip().split('\n'):
                            if line.strip() and line.strip() != ',':
                                try:
                                    entries.append(json.loads(line.rstrip(',')))
                                except:
                                    pass
                    
                    for entry in entries:
                        parse_log_entry(entry)
                except Exception as e:
                    pass
            
            last_position = f.tell()
        
        time.sleep(0.5)
        
    except KeyboardInterrupt:
        print("\nStopping monitor...")
        break
    except Exception as e:
        print(f"Error: {e}")
        time.sleep(1)
EOF
    
    python3 /tmp/ios_log_monitor.py
    rm -f /tmp/ios_log_monitor.py
}

# Parse command line arguments
COMMAND=$1
shift

OUTPUT_ARG=""
DATE_FILTER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_ARG="--output $2"
            shift 2
            ;;
        --date)
            DATE_FILTER=$2
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Main logic
print_header

case $COMMAND in
    test-login)
        if [ -z "$1" ]; then
            echo -e "${RED}Error: Email required${NC}"
            print_usage
            exit 1
        fi
        test_login "$1"
        ;;
    test-navigation)
        test_navigation
        ;;
    test-performance)
        test_performance
        ;;
    test-view)
        if [ -z "$1" ]; then
            echo -e "${RED}Error: View name required${NC}"
            print_usage
            exit 1
        fi
        test_view "$1"
        ;;
    full-report)
        full_report
        ;;
    live-monitor)
        live_monitor
        ;;
    *)
        print_usage
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Test completed!${NC}" 