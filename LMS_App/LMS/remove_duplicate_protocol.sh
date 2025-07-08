#!/bin/bash

echo "🔧 Removing duplicate protocol definitions..."

cd "$(dirname "$0")"

# Remove duplicate OfflineStatementStoreProtocol from SyncManager.swift
echo "📝 Removing duplicate OfflineStatementStoreProtocol from SyncManager..."

# Create a temporary file without the duplicate protocol
sed '/^protocol OfflineStatementStoreProtocol {/,/^}/d' LMS/Features/Cmi5/Services/SyncManager.swift > LMS/Features/Cmi5/Services/SyncManager.swift.tmp
mv LMS/Features/Cmi5/Services/SyncManager.swift.tmp LMS/Features/Cmi5/Services/SyncManager.swift

# Also remove duplicate ConflictResolverProtocol if exists
echo "📝 Checking for duplicate ConflictResolverProtocol..."
if grep -q "^protocol ConflictResolverProtocol" LMS/Features/Cmi5/Services/ConflictResolver.swift && grep -q "^public protocol ConflictResolverProtocol" LMS/Features/Cmi5/Services/ConflictResolver.swift; then
    echo "Found duplicate, removing internal version..."
    sed -i '' '/^protocol ConflictResolverProtocol {/,/^}/d' LMS/Features/Cmi5/Services/ConflictResolver.swift
fi

echo "✅ Duplicate protocols removed!"
echo ""
echo "🚀 Final build test..." 