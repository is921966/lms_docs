#!/bin/bash

echo "🔧 Fixing remaining compilation issues..."

cd "$(dirname "$0")"

# 1. Fix ReportTemplates references
echo "📝 Fixing ReportTemplates..."
sed -i '' 's/ReportTemplate/Cmi5ReportTemplate/g' LMS/Features/Cmi5/Reports/ReportTemplates.swift
sed -i '' 's/public struct Cmi5ReportTemplate/public struct ReportTemplate/g' LMS/Features/Cmi5/Reports/ReportTemplates.swift

# Fix ReportGenerator references
sed -i '' 's/ReportGenerator\./Cmi5ReportGenerator./g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/Cmi5ReportTemplate/ReportTemplate/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift

# 2. Fix protocol visibility issues
echo "🔧 Fixing protocol visibility..."

# OfflineStatementStore already fixed in previous script, but let's ensure
grep -q "public protocol OfflineStatementStoreProtocol" LMS/Features/Cmi5/Services/OfflineStatementStore.swift || \
sed -i '' '1s/^/public /' LMS/Features/Cmi5/Services/OfflineStatementStore.swift

# Make LRSSession public
sed -i '' 's/struct LRSSession {/public struct LRSSession {/g' LMS/Features/Cmi5/Services/LRSService.swift

# Make other internal types public if needed
sed -i '' 's/struct LRSResponse {/public struct LRSResponse {/g' LMS/Features/Cmi5/Services/LRSService.swift

# 3. Fix additional type references in ReportExportView
echo "📝 Updating ReportExportView references..."
sed -i '' 's/let report: Report/let report: Cmi5Report/g' LMS/Features/Cmi5/Views/ReportExportView.swift
sed -i '' 's/func exportReport(_ report: Report/func exportReport(_ report: Cmi5Report/g' LMS/Features/Cmi5/Views/ReportExportView.swift
sed -i '' 's/@State private var report: Report/@ State private var report: Cmi5Report/g' LMS/Features/Cmi5/Views/ReportExportView.swift

# 4. Fix AnalyticsDashboardView references  
echo "📝 Updating AnalyticsDashboardView..."
sed -i '' 's/generator: ReportGenerator/generator: Cmi5ReportGenerator/g' LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift
sed -i '' 's/= ReportGenerator(/= Cmi5ReportGenerator(/g' LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift

# 5. Clean up build artifacts
echo "🧹 Cleaning build artifacts..."
rm -rf DerivedData/

echo "✅ Remaining issues fixed!"
echo ""
echo "🚀 Testing build again..." 