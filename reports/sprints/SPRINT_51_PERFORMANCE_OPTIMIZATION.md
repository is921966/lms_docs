# Performance Optimization Plan - Sprint 51

**Sprint**: 51  
**День**: 167 (День 4/5)  
**Дата**: 19 июля 2025

## 🚀 iOS App Performance Optimization

### 1. App Launch Optimization

#### Current State
```
Total launch time: 2.3s
- main(): 0.1s
- UIApplication init: 0.3s
- AppDelegate setup: 1.2s
- First screen render: 0.7s
```

#### Optimization Steps

```swift
// 1. Lazy initialization
class AppDelegate: UIResponder, UIApplicationDelegate {
    private lazy var coreDataStack = CoreDataStack()
    private lazy var networkService = NetworkService()
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Defer non-critical initialization
        DispatchQueue.main.async { [weak self] in
            self?.initializeNonCriticalServices()
        }
        
        // Only critical setup
        setupWindow()
        return true
    }
}

// 2. Precompiled frameworks
// Move to static libraries where possible

// 3. Remove unused dependencies
// Audit Podfile/Package.swift
```

### 2. Memory Optimization

```swift
// Image caching with size limits
class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB
    }
}

// Proper image sizing
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
```

### 3. Network Performance

```swift
// Implement request coalescing
class CourseService {
    private var pendingRequests: [String: Task<[Course], Error>] = [:]
    
    func fetchCourses() async throws -> [Course] {
        let key = "fetchCourses"
        
        if let pending = pendingRequests[key] {
            return try await pending.value
        }
        
        let task = Task<[Course], Error> {
            defer { pendingRequests[key] = nil }
            return try await networkService.request(.courses)
        }
        
        pendingRequests[key] = task
        return try await task.value
    }
}
```

## 🎯 Backend Performance Optimization

### 1. Database Query Optimization

```sql
-- Add missing indexes
CREATE INDEX idx_enrollments_user_id ON enrollments(user_id);
CREATE INDEX idx_completions_user_id ON completions(user_id);
CREATE INDEX idx_progress_user_id ON progress(user_id);

-- Optimize slow query
CREATE MATERIALIZED VIEW user_statistics AS
SELECT 
    u.id,
    u.email,
    COUNT(DISTINCT e.id) as enrollment_count,
    COUNT(DISTINCT c.id) as completion_count,
    AVG(p.progress) as avg_progress
FROM users u
LEFT JOIN enrollments e ON u.id = e.user_id
LEFT JOIN completions c ON u.id = c.user_id
LEFT JOIN progress p ON u.id = p.user_id
GROUP BY u.id, u.email;

-- Refresh periodically
CREATE OR REPLACE FUNCTION refresh_user_statistics()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY user_statistics;
END;
$$ LANGUAGE plpgsql;
```

### 2. Redis Caching Implementation

```php
class CachedCourseRepository implements CourseRepositoryInterface {
    private $repository;
    private $redis;
    
    public function findAll(): array {
        $key = 'courses:all';
        
        // Try cache first
        $cached = $this->redis->get($key);
        if ($cached !== null) {
            return unserialize($cached);
        }
        
        // Fetch from DB
        $courses = $this->repository->findAll();
        
        // Cache with TTL
        $this->redis->setex($key, 3600, serialize($courses));
        
        return $courses;
    }
}
```

### 3. API Response Optimization

```php
// Implement field filtering
class CourseController {
    public function index(Request $request) {
        $fields = $request->query('fields', 'id,title,description');
        $courses = $this->courseService->getAll();
        
        return response()->json([
            'data' => $this->filterFields($courses, $fields)
        ]);
    }
    
    private function filterFields($data, $fields) {
        $allowedFields = explode(',', $fields);
        return array_map(function($item) use ($allowedFields) {
            return array_intersect_key(
                $item->toArray(),
                array_flip($allowedFields)
            );
        }, $data);
    }
}
```

## 📊 Performance Monitoring

### iOS Metrics Collection

```swift
class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    func trackAppLaunch() {
        let launchTime = CFAbsoluteTimeGetCurrent() - AppDelegate.launchStartTime
        Analytics.track("app_launch", properties: [
            "duration": launchTime,
            "cold_start": AppDelegate.isColdStart
        ])
    }
    
    func trackAPICall(endpoint: String, duration: TimeInterval) {
        Analytics.track("api_call", properties: [
            "endpoint": endpoint,
            "duration": duration,
            "success": true
        ])
    }
}
```

### Backend Metrics

```php
// Middleware for API performance tracking
class PerformanceMiddleware {
    public function handle($request, Closure $next) {
        $start = microtime(true);
        
        $response = $next($request);
        
        $duration = microtime(true) - $start;
        
        Log::info('API Performance', [
            'endpoint' => $request->path(),
            'method' => $request->method(),
            'duration' => $duration,
            'memory' => memory_get_peak_usage(true)
        ]);
        
        return $response;
    }
}
```

## 🎯 Performance Targets

| Metric | Current | Target | Method |
|--------|---------|--------|---------|
| App Launch | 2.3s | 0.8s | Lazy loading, defer initialization |
| Memory Baseline | 120MB | 60MB | Image optimization, proper caching |
| API Response | 450ms | 150ms | Caching, query optimization |
| DB Query Time | 3.2s | 0.1s | Indexes, materialized views |
| Network Payload | 2.5MB | 200KB | Field filtering, pagination |

## 🔧 Performance Testing

### Automated Performance Tests

```swift
// XCTest Performance
func testCourseListLoadPerformance() {
    measure {
        let expectation = expectation(description: "Load courses")
        viewModel.loadCourses {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
```

### Load Testing

```bash
# Apache Bench for API testing
ab -n 1000 -c 100 https://api.lms.com/courses

# Expected results:
# Requests per second: 500+
# Time per request: < 200ms
# Failed requests: 0
``` 