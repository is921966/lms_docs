#!/bin/bash
xcodebuild test \
  -scheme LMS \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath testResultsCoverage.xcresult \
  2>&1 | tee test_output_viewinspector_$(date +%Y%m%d_%H%M%S).log

# Показать краткую статистику
echo ""
echo "📊 Результаты тестов:"
tail -20 test_output_viewinspector_*.log | grep -E "Test Suite.*passed|failed|Executed"
