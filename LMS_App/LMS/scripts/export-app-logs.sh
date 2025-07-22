#!/bin/bash

# Export logs from iOS Simulator
# Экспортирует логи из симулятора iOS для анализа

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
DEVICE_ID=""
APP_BUNDLE_ID="com.tsum.lms"
OUTPUT_DIR="exported_logs"
DATE=$(date +%Y%m%d_%H%M%S)

# Functions
print_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -d <device_id>    Simulator device ID (optional, uses booted device if not specified)"
    echo "  -o <output_dir>   Output directory (default: exported_logs)"
    echo "  -b <bundle_id>    App bundle ID (default: com.tsum.lms)"
    echo "  -h                Show this help"
}

find_booted_device() {
    xcrun simctl list devices | grep "Booted" | head -1 | grep -o "([A-F0-9-]*)" | tr -d "()"
}

# Parse arguments
while getopts "d:o:b:h" opt; do
    case $opt in
        d)
            DEVICE_ID="$OPTARG"
            ;;
        o)
            OUTPUT_DIR="$OPTARG"
            ;;
        b)
            APP_BUNDLE_ID="$OPTARG"
            ;;
        h)
            print_usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            print_usage
            exit 1
            ;;
    esac
done

# Find device if not specified
if [ -z "$DEVICE_ID" ]; then
    echo -e "${YELLOW}No device ID specified, looking for booted device...${NC}"
    DEVICE_ID=$(find_booted_device)
    
    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}No booted simulator found!${NC}"
        echo "Please boot a simulator or specify device ID with -d option"
        exit 1
    fi
    
    echo -e "${GREEN}Found booted device: $DEVICE_ID${NC}"
fi

# Get app container
echo -e "${YELLOW}Getting app container path...${NC}"
APP_CONTAINER=$(xcrun simctl get_app_container "$DEVICE_ID" "$APP_BUNDLE_ID" data 2>/dev/null || echo "")

if [ -z "$APP_CONTAINER" ]; then
    echo -e "${RED}Could not find app container for $APP_BUNDLE_ID${NC}"
    echo "Make sure the app is installed on the simulator"
    exit 1
fi

echo -e "${GREEN}App container: $APP_CONTAINER${NC}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Export logs
LOGS_DIR="$APP_CONTAINER/Documents/Logs"
if [ -d "$LOGS_DIR" ]; then
    echo -e "${YELLOW}Exporting logs from $LOGS_DIR...${NC}"
    
    # Count log files
    LOG_COUNT=$(find "$LOGS_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$LOG_COUNT" -gt 0 ]; then
        # Copy all log files
        cp -r "$LOGS_DIR" "$OUTPUT_DIR/logs_$DATE"
        echo -e "${GREEN}Exported $LOG_COUNT log files to $OUTPUT_DIR/logs_$DATE${NC}"
        
        # Find today's log
        TODAY=$(date +%Y-%m-%d)
        TODAY_LOG="$LOGS_DIR/log_$TODAY.json"
        
        if [ -f "$TODAY_LOG" ]; then
            echo -e "${YELLOW}Today's log found: log_$TODAY.json${NC}"
            cp "$TODAY_LOG" "$OUTPUT_DIR/log_today_$DATE.json"
            
            # Analyze today's log
            echo -e "${YELLOW}Analyzing today's log...${NC}"
            python3 scripts/analyze_app_logs.py "$OUTPUT_DIR/log_today_$DATE.json" --output "$OUTPUT_DIR/analysis_$DATE.md"
            echo -e "${GREEN}Analysis saved to $OUTPUT_DIR/analysis_$DATE.md${NC}"
        fi
    else
        echo -e "${YELLOW}No log files found in $LOGS_DIR${NC}"
    fi
else
    echo -e "${YELLOW}Logs directory not found at $LOGS_DIR${NC}"
fi

# Export UserDefaults (for debugging feed design settings)
echo -e "${YELLOW}Exporting UserDefaults...${NC}"
PLIST_FILE="$APP_CONTAINER/Library/Preferences/$APP_BUNDLE_ID.plist"
if [ -f "$PLIST_FILE" ]; then
    cp "$PLIST_FILE" "$OUTPUT_DIR/UserDefaults_$DATE.plist"
    
    # Convert to readable format
    plutil -convert xml1 "$OUTPUT_DIR/UserDefaults_$DATE.plist" -o "$OUTPUT_DIR/UserDefaults_$DATE.xml"
    
    # Check feed design setting
    FEED_DESIGN=$(defaults read "$PLIST_FILE" useNewFeedDesign 2>/dev/null || echo "not set")
    echo -e "${GREEN}UserDefaults exported${NC}"
    echo -e "  useNewFeedDesign: $FEED_DESIGN"
else
    echo -e "${YELLOW}UserDefaults file not found${NC}"
fi

# Export console logs
echo -e "${YELLOW}Exporting console logs...${NC}"
log show --predicate "processID == \$(pgrep -f $APP_BUNDLE_ID)" --last 1h > "$OUTPUT_DIR/console_logs_$DATE.txt" 2>/dev/null || true

# Summary
echo ""
echo -e "${GREEN}=== Export Complete ===${NC}"
echo -e "Output directory: ${YELLOW}$OUTPUT_DIR${NC}"
echo ""
echo "Files exported:"
ls -la "$OUTPUT_DIR" | grep -E "(log|analysis|UserDefaults)" | awk '{print "  - " $9}'
echo ""
echo -e "${YELLOW}To analyze logs manually:${NC}"
echo "  python3 scripts/analyze_app_logs.py $OUTPUT_DIR/log_today_$DATE.json"
echo ""
echo -e "${YELLOW}To monitor logs in real-time:${NC}"
echo "  ./scripts/ios-test-runner.sh live-monitor" 