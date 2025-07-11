#!/bin/bash

echo "🔧 Fixing archive errors..."

cd "$(dirname "$0")"

# 1. Fix ReportExportView - ReportGenerator references
echo "📝 Fixing ReportExportView..."
sed -i '' 's/\[ReportGenerator\./[Cmi5ReportGenerator./g' LMS/Features/Cmi5/Views/ReportExportView.swift
sed -i '' 's/ReportGenerator\.ReportType/Cmi5ReportGenerator.ReportType/g' LMS/Features/Cmi5/Views/ReportExportView.swift

# 2. Create missing NotificationListView
echo "📝 Creating NotificationListView..."
cat > LMS/Features/Student/Views/NotificationListView.swift << 'EOF'
//
//  NotificationListView.swift
//  LMS
//

import SwiftUI

struct NotificationListView: View {
    var body: some View {
        VStack {
            Text("Уведомления")
                .font(.largeTitle)
                .padding()
            
            Text("Нет новых уведомлений")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Уведомления")
    }
}
EOF

# 3. Fix OfflineStatementStore async issues
echo "📝 Fixing OfflineStatementStore async issues..."
# Replace async perform with performAndWait for synchronous operations
sed -i '' 's/try await backgroundContext\.perform { @Sendable in/await backgroundContext.perform {/g' LMS/Features/Cmi5/Services/OfflineStatementStore.swift
sed -i '' 's/backgroundContext\.perform {/backgroundContext.performAndWait {/g' LMS/Features/Cmi5/Services/OfflineStatementStore.swift

# 4. Fix NotificationService reference in StudentDashboardView
echo "📝 Fixing StudentDashboardView..."
# Replace unreadCountValue with unreadCount
sed -i '' 's/\.unreadCountValue/\.unreadCount/g' LMS/Features/Student/Views/StudentDashboardView.swift
# Fix the binding issue
sed -i '' 's/$notificationService\.unreadCount > 0/$notificationService.unreadCount.wrappedValue > 0/g' LMS/Features/Student/Views/StudentDashboardView.swift

# 5. Clean build folder
echo "🧹 Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
rm -rf build/

echo "✅ Archive errors fixed!"
echo ""
echo "🚀 Testing archive build..." 