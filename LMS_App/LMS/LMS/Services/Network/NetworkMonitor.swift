import Foundation
import Network
import Combine

// MARK: - NetworkMonitor

/// Мониторинг состояния сети
final class NetworkMonitor: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = NetworkMonitor()
    
    @Published private(set) var isConnected = true
    @Published private(set) var connectionType: ConnectionType = .unknown
    @Published private(set) var isExpensive = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.lms.networkmonitor")
    
    // MARK: - Types
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    // MARK: - Initialization
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Начать мониторинг сети
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    /// Остановить мониторинг сети
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // MARK: - Private Methods
    
    private func updateConnectionStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}

// MARK: - NetworkMonitor Extension for APIClient

extension NetworkMonitor {
    
    /// Проверить доступность сети перед запросом
    func checkConnectivity() throws {
        guard isConnected else {
            throw APIError.noInternet
        }
    }
    
    /// Получить читаемое описание типа соединения
    var connectionDescription: String {
        switch connectionType {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return isExpensive ? "Cellular (Roaming)" : "Cellular"
        case .ethernet:
            return "Ethernet"
        case .unknown:
            return isConnected ? "Connected" : "No Connection"
        }
    }
} 