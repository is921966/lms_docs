#!/bin/bash

echo "🔧 Fixing naming conflicts in Swift code..."

cd "$(dirname "$0")"

# 1. Rename Cmi5 Report types to avoid conflicts
echo "📝 Renaming Cmi5 report types..."

# ReportGenerator.swift - Rename Report to Cmi5Report
sed -i '' 's/public struct Report {/public struct Cmi5Report {/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/-> Report/-> Cmi5Report/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/: Report/: Cmi5Report/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/Report(/Cmi5Report(/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift

# ReportGenerator.swift - Rename ReportSection to Cmi5ReportSection
sed -i '' 's/public struct ReportSection {/public struct Cmi5ReportSection {/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/\[ReportSection\]/[Cmi5ReportSection]/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/: ReportSection/: Cmi5ReportSection/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/ReportSection(/Cmi5ReportSection(/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift

# ReportGenerator.swift - Rename ChartData to Cmi5ChartData
sed -i '' 's/public struct ChartData {/public struct Cmi5ChartData {/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/: ChartData/: Cmi5ChartData/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/ChartData(/Cmi5ChartData(/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift

# Update ReportTemplates.swift
sed -i '' 's/ReportSection\./Cmi5ReportSection./g' LMS/Features/Cmi5/Reports/ReportTemplates.swift

# Update ReportExportView.swift
sed -i '' 's/struct ShareSheet/struct ReportShareSheet/g' LMS/Features/Cmi5/Views/ReportExportView.swift
sed -i '' 's/ShareSheet(/ReportShareSheet(/g' LMS/Features/Cmi5/Views/ReportExportView.swift

# 2. Fix other issues
echo "🔧 Fixing other compilation issues..."

# Fix MockLRSService duplicate properties
sed -i '' '/var shouldFailNextCalls: Int = 0/d' LMS/Features/Cmi5/Services/LRSService.swift
sed -i '' '/var sendAttempts: Int = 0/d' LMS/Features/Cmi5/Services/LRSService.swift

# Fix internal/public visibility
sed -i '' 's/protocol LRSServiceProtocol {/public protocol LRSServiceProtocol {/g' LMS/Features/Cmi5/Services/LRSService.swift
sed -i '' 's/protocol OfflineStatementStoreProtocol {/public protocol OfflineStatementStoreProtocol {/g' LMS/Features/Cmi5/Services/OfflineStatementStore.swift

echo "✅ Naming conflicts fixed!"
echo ""
echo "📝 Summary of changes:"
echo "- Report → Cmi5Report (in Cmi5 module)"
echo "- ReportSection → Cmi5ReportSection (in Cmi5 module)"
echo "- ChartData → Cmi5ChartData (in Cmi5 module)"
echo "- ShareSheet → ReportShareSheet (in ReportExportView)"
echo "- Fixed duplicate properties in MockLRSService"
echo "- Fixed protocol visibility issues" 