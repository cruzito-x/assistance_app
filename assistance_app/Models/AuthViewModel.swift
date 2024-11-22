import SwiftUI
import Firebase

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        // Escucha los cambios en el estado de autenticación
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.isAuthenticated = (user != nil)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}
