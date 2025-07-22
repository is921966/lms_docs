import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                Text("Иван Иванов")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("ivan@tsum.ru")
                    .foregroundColor(.secondary)
                
                Button(action: {
                    coordinator.logout()
                }) {
                    Text("Выйти")
                        .foregroundColor(.red)
                }
                .padding(.top, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Профиль")
        }
    }
}
