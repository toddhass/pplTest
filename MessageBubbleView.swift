//
//  MessageBubbleView.swift
//  PPL
//
//  Created by Todd Hassinger on 3/2/25.
//


import SwiftUI

/// A view that displays a single message in a chat bubble format.
import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isCurrentUser: Bool
    let username: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                HStack(spacing: 8) {
                    if !isCurrentUser {
                        Text(username)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    Text(message.created_at, style: .time)
                        .font(.caption2)
                        .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .gray)
                    
                    if isCurrentUser {
                        Spacer()
                        Text(username)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Text(message.content ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    )
            }
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .transition(.move(edge: .bottom))
    }
}
