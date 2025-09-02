#!/usr/bin/swift

import Foundation

// Simple test for JSON serialization fix
struct TestLogger {
    static func sanitizeForJSON(_ value: Any) -> Any {
        if let date = value as? Date {
            return ISO8601DateFormatter().string(from: date)
        } else if let uuid = value as? UUID {
            return uuid.uuidString
        } else if let url = value as? URL {
            return url.absoluteString
        } else if let dict = value as? [String: Any] {
            return dict.mapValues { sanitizeForJSON($0) }
        } else if let array = value as? [Any] {
            return array.map { sanitizeForJSON($0) }
        } else if let data = value as? Data {
            return data.base64EncodedString()
        } else if value is NSNull {
            return NSNull()
        } else if JSONSerialization.isValidJSONObject([value]) {
            return value
        } else {
            // Convert any non-JSON-serializable object to string
            return String(describing: value)
        }
    }
    
    static func test() {
        print("🧪 Testing JSON serialization fix...")
        
        // Test with UUID
        let testUUID = UUID()
        let details: [String: Any] = [
            "userId": testUUID,
            "sessionId": UUID(),
            "postId": "test-post-123",
            "date": Date(),
            "url": URL(string: "https://example.com")!,
            "data": "test".data(using: .utf8)!,
            "null": NSNull(),
            "array": [UUID(), Date(), "string"],
            "dict": ["nested": UUID()],
            "number": 42,
            "bool": true
        ]
        
        print("📝 Original details:")
        print(details)
        
        // Sanitize details
        let sanitized = details.mapValues { sanitizeForJSON($0) }
        
        print("\n✨ Sanitized details:")
        print(sanitized)
        
        // Try to serialize
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sanitized, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print("\n✅ JSON serialization successful!")
            print("📄 JSON output:")
            print(jsonString)
        } catch {
            print("\n❌ JSON serialization failed: \(error)")
        }
    }
}

// Run the test
TestLogger.test() 