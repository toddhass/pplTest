//
//  UserListView.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        // Your UI elements here
        Text("User List")
            .onAppear {
                print("UserListView appeared")
                Task {
                    do {
                        await viewModel.updateUserStatus(isLoggedIn: true)
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
    }
}

//class UserViewModel: ObservableObject {
//    func updateUserStatus(isLoggedIn: Bool) async {
//        // Simulate async work
//        print("User status updated: \(isLoggedIn)")
//    }
//}
