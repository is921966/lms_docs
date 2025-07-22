import SwiftUI

struct FeedDesignDiagnosticView: View {
    @AppStorage("useNewFeedDesign") private var useNewFeedDesign = false
    @State private var logs: [String] = []
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Заголовок
            Text("🔍 Диагностика переключения ленты")
                .font(.title2)
                .bold()
            
            // Текущее состояние
            VStack(alignment: .leading, spacing: 10) {
                Text("Текущее состояние:")
                    .font(.headline)
                
                HStack {
                    Text("useNewFeedDesign:")
                    Text(useNewFeedDesign ? "✅ true" : "❌ false")
                        .foregroundColor(useNewFeedDesign ? .green : .red)
                        .bold()
                }
                
                HStack {
                    Text("UserDefaults value:")
                    Text(UserDefaults.standard.bool(forKey: "useNewFeedDesign") ? "✅ true" : "❌ false")
                        .foregroundColor(UserDefaults.standard.bool(forKey: "useNewFeedDesign") ? .green : .red)
                        .bold()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Тестовые кнопки
            VStack(spacing: 10) {
                Text("Тестовые действия:")
                    .font(.headline)
                
                Button(action: {
                    useNewFeedDesign.toggle()
                    addLog("Toggle pressed. New value: \(useNewFeedDesign)")
                }) {
                    Text("Toggle Feed Design")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "useNewFeedDesign"), forKey: "useNewFeedDesign")
                    UserDefaults.standard.synchronize()
                    addLog("Direct UserDefaults update. New value: \(UserDefaults.standard.bool(forKey: "useNewFeedDesign"))")
                }) {
                    Text("Direct UserDefaults Update")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
                    addLog("Posted UserDefaults.didChangeNotification")
                }) {
                    Text("Force Notification")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Принудительная перезагрузка AppStorage
                    let currentValue = UserDefaults.standard.bool(forKey: "useNewFeedDesign")
                    UserDefaults.standard.set(!currentValue, forKey: "useNewFeedDesign")
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UserDefaults.standard.set(currentValue, forKey: "useNewFeedDesign")
                        UserDefaults.standard.synchronize()
                        
                        // Принудительно обновляем AppStorage
                        self.useNewFeedDesign = currentValue
                        
                        addLog("Force sync: toggled and restored to \(currentValue)")
                    }
                }) {
                    Text("Force AppStorage Sync")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            // Логи
            VStack(alignment: .leading, spacing: 5) {
                Text("Логи:")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(logs, id: \.self) { log in
                            Text(log)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 200)
                .padding()
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Feed Design Diagnostic")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
        }
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logs.append("[\(timestamp)] \(message)")
        
        // Ограничиваем количество логов
        if logs.count > 50 {
            logs.removeFirst()
        }
    }
    
    private func startMonitoring() {
        addLog("Started monitoring")
        
        // Мониторинг изменений каждую секунду
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let currentValue = UserDefaults.standard.bool(forKey: "useNewFeedDesign")
            let appStorageValue = useNewFeedDesign
            
            if currentValue != appStorageValue {
                addLog("⚠️ Mismatch detected! UserDefaults: \(currentValue), AppStorage: \(appStorageValue)")
            }
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        addLog("Stopped monitoring")
    }
} 