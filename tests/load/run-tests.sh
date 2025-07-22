#!/bin/bash

# Load test runner script
set -e

API_URL=${API_URL:-"http://localhost:8080/api/v1"}
REPORT_DIR="reports"

echo "🚀 Starting Load Tests for LMS API"
echo "Target: $API_URL"
echo "=================================="

# Create reports directory
mkdir -p $REPORT_DIR

# Run main load test
echo ""
echo "📊 Running main load test (8 minutes)..."
k6 run \
  --out json=$REPORT_DIR/load-test-results.json \
  --summary-export=$REPORT_DIR/load-test-summary.json \
  -e API_URL=$API_URL \
  load-test.js

# Run stress test
echo ""
echo "💪 Running stress test (2 minutes)..."
k6 run \
  --vus 500 \
  --duration 2m \
  --out json=$REPORT_DIR/stress-test-results.json \
  --summary-export=$REPORT_DIR/stress-test-summary.json \
  -e API_URL=$API_URL \
  --scenarios stressTest \
  load-test.js

# Run spike test
echo ""
echo "⚡ Running spike test (1 minute)..."
k6 run \
  --vus 1000 \
  --duration 1m \
  --out json=$REPORT_DIR/spike-test-results.json \
  --summary-export=$REPORT_DIR/spike-test-summary.json \
  -e API_URL=$API_URL \
  --scenarios spikeTest \
  load-test.js

# Generate HTML report
echo ""
echo "📈 Generating HTML report..."
if command -v k6-reporter &> /dev/null; then
  k6-reporter $REPORT_DIR/load-test-results.json --output $REPORT_DIR/load-test-report.html
else
  echo "k6-reporter not found. Install with: npm install -g k6-reporter"
fi

echo ""
echo "✅ Load tests completed!"
echo "Reports available in: $REPORT_DIR/"
echo ""
echo "Summary:"
echo "--------"
cat $REPORT_DIR/load-test-summary.json | jq '.metrics.http_req_duration.avg'

# Check if tests passed
if cat $REPORT_DIR/load-test-summary.json | jq -e '.thresholds | to_entries | map(select(.value.passes == false)) | length == 0' > /dev/null; then
  echo ""
  echo "✅ All thresholds passed!"
  exit 0
else
  echo ""
  echo "❌ Some thresholds failed!"
  exit 1
fi 