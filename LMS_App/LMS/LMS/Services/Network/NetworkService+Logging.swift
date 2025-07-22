import Foundation
import Combine

// MARK: - Network Service Logging Extension
extension NetworkService {
    
    func performRequestWithLogging<T: Decodable>(_ endpoint: NetworkEndpoint, 
                                                  responseType: T.Type) async throws -> T {
        let requestId = UUID().uuidString
        
        // Log request start
        ComprehensiveLogger.shared.log(.network, .debug, "Network Request Started", details: [
            "requestId": requestId,
            "endpoint": endpoint.path,
            "method": endpoint.method.rawValue,
            "headers": endpoint.headers ?? [:],
            "requiresAuth": endpoint.requiresAuth,
            "body": endpoint.body != nil ? String(data: endpoint.body!, encoding: .utf8) ?? "Binary" : "none"
        ])
        
        do {
            // Use the existing request method with logging
            let startTime = Date()
            let result = try await request(endpoint, as: responseType)
            let duration = Date().timeIntervalSince(startTime)
            
            // Log success
            ComprehensiveLogger.shared.log(.network, .info, "Network Request Succeeded", details: [
                "requestId": requestId,
                "endpoint": endpoint.path,
                "method": endpoint.method.rawValue,
                "duration": duration * 1000, // Convert to milliseconds
                "responseType": String(describing: T.self)
            ])
            
            // Log performance
            ComprehensiveLogger.shared.logPerformance("network_request_duration", value: duration * 1000, unit: "ms")
            
            return result
        } catch {
            // Log error
            ComprehensiveLogger.shared.log(.network, .error, "Network Request Failed", details: [
                "requestId": requestId,
                "endpoint": endpoint.path,
                "method": endpoint.method.rawValue,
                "error": error.localizedDescription,
                "errorType": String(describing: type(of: error))
            ])
            
            throw error
        }
    }
}

// MARK: - URLSession Extension for Global Logging
extension URLSession {
    static let logged: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [LoggingURLProtocol.self] + (configuration.protocolClasses ?? [])
        return URLSession(configuration: configuration)
    }()
}

// MARK: - Logging URL Protocol
class LoggingURLProtocol: URLProtocol {
    
    private var dataTask: URLSessionDataTask?
    private var requestStartTime: Date?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Only handle requests that haven't been logged yet
        return URLProtocol.property(forKey: "LoggingURLProtocolHandled", in: request) == nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let newRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }
        
        // Mark this request as handled
        URLProtocol.setProperty(true, forKey: "LoggingURLProtocolHandled", in: newRequest)
        
        requestStartTime = Date()
        
        // Create the data task
        let session = URLSession(configuration: .default)
        dataTask = session.dataTask(with: newRequest as URLRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Calculate duration
            let duration = Date().timeIntervalSince(self.requestStartTime ?? Date())
            
            // Log the request/response
            ComprehensiveLogger.shared.logNetworkRequest(
                self.request,
                response: response,
                data: data,
                error: error
            )
            
            // Log performance metrics
            ComprehensiveLogger.shared.logPerformance(
                "network_request_duration",
                value: duration * 1000,
                unit: "ms"
            )
            
            // Pass the response back
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
    }
}

// MARK: - Mock Network Response Logger
class MockNetworkLogger {
    static func logMockResponse<T: Encodable>(_ endpoint: String, 
                                               response: T, 
                                               statusCode: Int = 200,
                                               delay: TimeInterval = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            do {
                let data = try JSONEncoder().encode(response)
                
                ComprehensiveLogger.shared.log(.network, .info, "Mock Response", details: [
                    "endpoint": endpoint,
                    "statusCode": statusCode,
                    "responseData": String(data: data, encoding: .utf8) ?? "encoding error",
                    "delay": delay,
                    "isMock": true
                ])
            } catch {
                ComprehensiveLogger.shared.log(.network, .error, "Mock Response Encoding Error", details: [
                    "endpoint": endpoint,
                    "error": error.localizedDescription
                ])
            }
        }
    }
} 