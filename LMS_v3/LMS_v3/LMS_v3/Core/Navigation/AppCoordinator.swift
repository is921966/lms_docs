import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    
    func login() {
        isAuthenticated = true
    }
    
    func logout() {
        isAuthenticated = false
    }
}
