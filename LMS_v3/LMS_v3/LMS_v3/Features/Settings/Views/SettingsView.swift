import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Общие") {
                    HStack {
                        Text("Уведомления")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Text("Темная тема")
                        Spacer()
                        Toggle("", isOn: .constant(false))
                    }
                }
                
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("3.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
