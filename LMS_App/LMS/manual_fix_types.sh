#!/bin/bash

echo "🔧 Manually fixing type issues..."

cd "$(dirname "$0")"

# 1. Fix ReportGenerator.swift - ensure proper class name
echo "📝 Fixing ReportGenerator class name..."
# First restore original if double-prefixed
sed -i '' 's/Cmi5Cmi5ReportGenerator/ReportGenerator/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
# Then add proper prefix to class
sed -i '' 's/public class ReportGenerator/public class Cmi5ReportGenerator/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift
sed -i '' 's/class ReportGenerator/class Cmi5ReportGenerator/g' LMS/Features/Cmi5/Reports/ReportGenerator.swift

# 2. Fix ReportTemplates.swift - keep ReportTemplate as is  
echo "📝 Fixing ReportTemplates..."
# Restore original names
sed -i '' 's/Cmi5ReportTemplate/ReportTemplate/g' LMS/Features/Cmi5/Reports/ReportTemplates.swift

# 3. Make OfflineStatementStoreProtocol public
echo "🔧 Making protocols public..."
# Find the protocol declaration and make it public
sed -i '' 's/^protocol OfflineStatementStoreProtocol/public protocol OfflineStatementStoreProtocol/g' LMS/Features/Cmi5/Services/OfflineStatementStore.swift

# Also make the concrete class public
sed -i '' 's/^class OfflineStatementStore/public class OfflineStatementStore/g' LMS/Features/Cmi5/Services/OfflineStatementStore.swift
sed -i '' 's/^final class OfflineStatementStore/public final class OfflineStatementStore/g' LMS/Features/Cmi5/Services/OfflineStatementStore.swift

# 4. Fix any remaining type visibility
echo "🔧 Fixing remaining visibility issues..."
# Make Statement and related types public if needed
sed -i '' 's/^struct Statement {/public struct Statement {/g' LMS/Features/Cmi5/Models/XAPIModels.swift
sed -i '' 's/^enum Verb/public enum Verb/g' LMS/Features/Cmi5/Models/XAPIModels.swift

# 5. Update references in views
echo "📝 Updating view references..."
# Fix AnalyticsDashboardView
sed -i '' 's/Cmi5ReportGenerator/ReportGenerator/g' LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift
sed -i '' 's/ReportGenerator(/Cmi5ReportGenerator(/g' LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift

echo "✅ Manual fixes applied!"
echo ""
echo "📋 Summary:"
echo "- ReportGenerator → Cmi5ReportGenerator (class only)"
echo "- ReportTemplate stays as ReportTemplate (no prefix)"
echo "- Made protocols and types public"
echo ""
echo "🧹 Cleaning and rebuilding..."
rm -rf DerivedData/ 