#!/bin/bash

echo "🔧 Final type fixes..."

cd "$(dirname "$0")"

# 1. Fix ReportGenerator references in struct definitions
echo "📝 Fixing ReportGenerator type references..."
sed -i '' 's/ReportGenerator\.ReportType/Cmi5ReportGenerator.ReportType/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift

# 2. Fix double Cmi5 prefix
echo "📝 Fixing double Cmi5 prefixes..."
sed -i '' 's/Cmi5Cmi5ChartData/Cmi5ChartData/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift

# 3. Fix ReportExportView references
echo "📝 Fixing ReportExportView..."
sed -i '' 's/ReportGenerator(/Cmi5ReportGenerator(/g' LMS/Features/Cmi5/Views/ReportExportView.swift
sed -i '' 's/: ReportGenerator/: Cmi5ReportGenerator/g' LMS/Features/Cmi5/Views/ReportExportView.swift
sed -i '' 's/= ReportGenerator/= Cmi5ReportGenerator/g' LMS/Features/Cmi5/Views/ReportExportView.swift

# 4. Fix AnalyticsDashboardView
echo "📝 Fixing AnalyticsDashboardView..."
sed -i '' 's/: ReportGenerator/: Cmi5ReportGenerator/g' LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift
sed -i '' 's/= ReportGenerator/= Cmi5ReportGenerator/g' LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift

# 5. Make SyncManager protocols public
echo "🔧 Making SyncManager types public..."
# Check if protocols are public in OfflineStatementStore.swift
if ! grep -q "public protocol OfflineStatementStoreProtocol" LMS/Features/Cmi5/Services/OfflineStatementStore.swift; then
    # Insert public before protocol
    sed -i '' '/^protocol OfflineStatementStoreProtocol/s/^/public /' LMS/Features/Cmi5/Services/OfflineStatementStore.swift
fi

# Make ConflictResolver public
sed -i '' 's/^protocol ConflictResolverProtocol/public protocol ConflictResolverProtocol/g' LMS/Features/Cmi5/Services/ConflictResolver.swift

echo "✅ Final fixes applied!"
echo ""
echo "🚀 Testing final build..." 