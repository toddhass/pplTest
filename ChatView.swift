//
//  ChatView.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//



import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var newMessage = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if viewModel.groupMessages.isEmpty {
                            Text("No messages yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.groupMessages) { message in
                                MessageBubbleView(message: message, isCurrentUser: viewModel.isCurrentUser(message.user_id))
                                    .id(message.id)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.groupMessages) {
                    withAnimation {
                        if let lastId = viewModel.groupMessages.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Type a message", text: $newMessage, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(4)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.return)
                Button(action: {
                    Task {
                        do {
                            await viewModel.sendMessage(content: newMessage)
                            newMessage = ""
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(newMessage.isEmpty ? .gray : .blue)
                }
                .disabled(newMessage.isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle("Group Chat")
        .alert(isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
    }
}
