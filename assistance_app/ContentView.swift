//
//  ContentView.swift
//  assistance_app
//
//  Created by Cruz on 18/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainMenuView()
            } else {
                LoginView()
            }
        }
    }
}
