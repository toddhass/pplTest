//
//  AuthView.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


// Views/AuthView.swift
import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var isSignUp = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                Task {
                    if isSignUp {
                        await viewModel.signUp()
                    } else {
                        await viewModel.signIn()
                    }
                }
            }) {
                Text(isSignUp ? "Sign Up" : "Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            Button(action: {
                isSignUp.toggle()
                print("isSignUp toggled to: \(isSignUp)")
            }) {
                Text("Switch to \(isSignUp ? "Log In" : "Sign Up")")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
            UserListView()
        }
    }
}
