import SwiftUI

struct LogTestView: View {
    @State private var counter = 0
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Log Testing Dashboard")
                    .font(.largeTitle)
                    .padding()
                
                // Счетчик для UI событий
                VStack {
                    Text("Counter: \(counter)")
                        .font(.title2)
                    
                    HStack(spacing: 20) {
                        Button(action: incrementCounter) {
                            Label("Increment", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: decrementCounter) {
                            Label("Decrement", systemImage: "minus.circle.fill")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Тестирование разных категорий логов
                VStack(spacing: 10) {
                    Button("Test Navigation Log") {
                        testNavigationLog()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test Network Log") {
                        testNetworkLog()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test Error Log") {
                        testErrorLog()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button("Test Data Change") {
                        testDataChange()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test Performance") {
                        testPerformance()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                if isLoading {
                    ProgressView("Simulating network request...")
                        .padding()
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Log Test")
        .onAppear {
            ComprehensiveLogger.shared.log(.ui, .info, "LogTestView appeared", details: [
                "timestamp": Date().timeIntervalSince1970
            ])
        }
        .onDisappear {
            ComprehensiveLogger.shared.log(.ui, .info, "LogTestView disappeared")
        }
    }
    
    private func incrementCounter() {
        counter += 1
        ComprehensiveLogger.shared.logUIEvent(
            "Counter incremented",
            view: "LogTestView",
            action: "increment",
            details: ["newValue": counter]
        )
    }
    
    private func decrementCounter() {
        counter -= 1
        ComprehensiveLogger.shared.logUIEvent(
            "Counter decremented",
            view: "LogTestView",
            action: "decrement",
            details: ["newValue": counter]
        )
    }
    
    private func testNavigationLog() {
        ComprehensiveLogger.shared.logNavigation(
            from: "LogTestView",
            to: "SimulatedDestination",
            method: "button_tap",
            details: ["reason": "testing"]
        )
    }
    
    private func testNetworkLog() {
        isLoading = true
        
        // Симулируем сетевой запрос
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let request = URLRequest(url: URL(string: "https://api.example.com/test")!)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )
            
            ComprehensiveLogger.shared.logNetworkRequest(
                request,
                response: response,
                data: "{\"status\": \"success\"}".data(using: .utf8),
                error: nil
            )
            
            isLoading = false
        }
    }
    
    private func testErrorLog() {
        errorMessage = "Simulated error for testing"
        
        ComprehensiveLogger.shared.log(.error, .error, "Test error occurred", details: [
            "errorCode": "TEST_001",
            "errorMessage": errorMessage,
            "recoverable": true
        ])
        
        // Очищаем через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            errorMessage = ""
        }
    }
    
    private func testDataChange() {
        ComprehensiveLogger.shared.log(.data, .info, "User preferences updated", details: [
            "preference": "theme",
            "oldValue": "light",
            "newValue": "dark",
            "userId": "test_user_123"
        ])
    }
    
    private func testPerformance() {
        let startTime = Date()
        
        // Симулируем тяжелую операцию
        var sum = 0
        for i in 0..<1000000 {
            sum += i
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        ComprehensiveLogger.shared.logPerformance(
            "heavy_calculation",
            value: duration * 1000,
            unit: "ms"
        )
        
        // Логируем результат отдельно
        ComprehensiveLogger.shared.log(.performance, .info, "Calculation completed", details: [
            "result": sum,
            "duration_ms": duration * 1000
        ])
    }
}

struct LogTestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LogTestView()
        }
    }
} 