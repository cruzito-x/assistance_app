//
//  assistance_appApp.swift
//  assistance_app
//
//  Created by Cruz on 18/11/24.
//

import SwiftUI
import Firebase

@main
struct assistance_appApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
            _ = FirebaseManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
