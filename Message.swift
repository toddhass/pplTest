//
//  Message.swift
//  PPL
//
//  Created by Todd Hassinger on 3/2/25.
//


import Foundation

struct Message: Identifiable, Codable {
    let id: Int
    let user_id: UUID
    let content: String?
    let created_at: Date
    let recipient_id: UUID?
    let users: User?
}