//
//  AuthViewModel.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


// ViewModels/AuthViewModel.swift
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://cwinjyvcazkfqfbrbops.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3aW5qeXZjYXprZnFmYnJib3BzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxNjUwMTcsImV4cCI6MjA1NTc0MTAxN30.wijPjFD-aUZrLCr_hfFGjji_wblj8u0_usaN-R-pwB4"
    )
    
    func signIn() async {
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            isAuthenticated = true
            errorMessage = nil
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }
    
    func signUp() async {
        do {
            let username = String(email.split(separator: "@").first ?? "User")
            _ = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["username": AnyJSON.string(username)] // Explicitly use AnyJSON
            )
            isAuthenticated = true
            errorMessage = nil
        } catch {
            errorMessage = "Sign-up failed: \(error.localizedDescription)"
        }
    }
    
    func signOut() async {
        do {
                    // Update is_logged_in to false before signing out
            if let userId = try? await supabase.auth.session.user.id {
                        try await supabase
                            .from("users")
                            .update([
                                "is_logged_in": AnyEncodable(false),
                                "last_seen": AnyEncodable(Date().ISO8601Format())
                            ])
                            .eq("id", value: userId)
                            .execute()
                        print("Updated is_logged_in to false for user \(userId)")
                    }
                    
                    try await supabase.auth.signOut()
                    isAuthenticated = false
                    print("Signed out, isAuthenticated: \(isAuthenticated)")
                    email = ""
                    password = ""
        } catch {
            errorMessage = "Sign-out failed: \(error.localizedDescription)"
        }
    }
    
    
}
