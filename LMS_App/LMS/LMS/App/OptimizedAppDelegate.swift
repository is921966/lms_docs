import UIKit

class OptimizedAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private let profiler = LaunchProfiler.shared
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Start profiling
        profiler.startMeasuring()
        
        // Minimal setup - defer heavy operations
        setupWindow()
        profiler.checkpoint("Window setup")
        
        // Async initialization of non-critical components
        Task {
            await initializeNonCriticalServices()
        }
        
        // Start app flow
        startAppFlow()
        profiler.checkpoint("App flow started")
        
        // Finish profiling
        let report = profiler.finish()
        
        #if DEBUG
        if !report.isOptimal {
            print("⚠️ Launch time optimization needed!")
            report.recommendations.forEach { print("  - \($0)") }
        }
        #endif
        
        return true
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
    }
    
    private func startAppFlow() {
        guard let window = window else { return }
        
        // Lazy container initialization
        let container = DIContainer.createOptimized()
        
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()
    }
    
    private func initializeNonCriticalServices() async {
        // Initialize analytics, crash reporting, etc. asynchronously
        await profiler.measureAsyncBlock("Analytics setup") {
            // Simulate analytics setup
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
        }
        
        await profiler.measureAsyncBlock("Remote config") {
            // Simulate remote config fetch
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
    }
}

// MARK: - Optimized DI Container

extension DIContainer {
    static func createOptimized() -> DIContainer {
        let container = DIContainer.shared
        
        // Services are already registered in DIContainer
        
        return container
    }
} 