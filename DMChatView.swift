//
//  DMChatView.swift
//  PPL
//
//  Created by Todd Hassinger on 3/2/25.
//


import SwiftUI

struct DMChatView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var newMessage = ""
    let recipientId: UUID
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Messages List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.dmMessages) { message in
                        MessageBubbleView(
                            message: message,
                            isCurrentUser: viewModel.isCurrentUser(message.user_id),
                            username: message.users?.username ?? "Unknown"
                        )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            
            // Input Area
            HStack(spacing: 8) {
                TextField("Message", text: $newMessage, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .lineLimit(4)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.return)
                    .onSubmit { sendMessage() }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(newMessage.isEmpty ? .gray : .blue)
                }
                .disabled(newMessage.isEmpty)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
        .navigationTitle("Chat with \(viewModel.users.first(where: { $0.id == recipientId })?.username ?? "User")")
        .onAppear {
            Task { await viewModel.fetchDMMessages(with: recipientId) }
        }
    }
    
    private func sendMessage() {
        Task {
            print("Sending to recipient: \(recipientId)")
            await viewModel.sendMessage(content: newMessage, recipientId: recipientId)
            newMessage = ""
        }
    }
}
