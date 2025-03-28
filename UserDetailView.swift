//
//  UserDetailView.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


// Views/UserDetailView.swift
import SwiftUI

struct UserDetailView: View {
    let selectedUser: User?
    
    var body: some View {
        if let user = selectedUser {
            VStack {
                Text("Details for \(user.username)")
                    .font(.headline)
                Text("Email: \(user.email)")
                if let lastSeen = user.lastSeen {
                    Text("Last Seen: \(lastSeen, style: .relative)")
                }
            }
            .padding()
        } else {
            Text("Select a user")
        }
    }
}