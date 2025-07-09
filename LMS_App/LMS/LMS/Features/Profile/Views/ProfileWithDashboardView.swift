import SwiftUI

struct ProfileWithDashboardView: View {
    @EnvironmentObject var authService: MockAuthService
    @State private var selectedSegment = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Сегментированный контроль для переключения
            Picker("Режим просмотра", selection: $selectedSegment) {
                Text("Профиль").tag(0)
                Text("Дашборд").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(.systemBackground))
            
            // Контент в зависимости от выбора
            if selectedSegment == 0 {
                ProfileView()
            } else {
                // Дашборд в зависимости от роли
                if authService.currentUser?.role == .admin {
                    AdminDashboardView()
                } else {
                    StudentDashboardView()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Alternative Tabbed Version
struct ProfileWithDashboardTabView: View {
    @EnvironmentObject var authService: MockAuthService
    
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
            
            Group {
                if authService.currentUser?.role == .admin {
                    AdminDashboardView()
                } else {
                    StudentDashboardView()
                }
            }
            .tabItem {
                Label("Дашборд", systemImage: "chart.bar.fill")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

#Preview {
    NavigationStack {
        ProfileWithDashboardView()
            .environmentObject(MockAuthService.shared)
    }
} 