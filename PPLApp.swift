//
//  PPLApp.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//

import SwiftUI

@main
struct UsersApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authViewModel)
        }
    }
}
