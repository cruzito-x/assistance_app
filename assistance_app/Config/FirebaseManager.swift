import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {
        FirebaseApp.configure()
        connectionStatus()
    }
    
    private func connectionStatus() {
        if(FirebaseApp.app() != nil) {
            print("Connection Successfully!")
        }
        else {
            print("Failed to connect to Firebase")
        }
    }
}
