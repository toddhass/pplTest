//
//  User.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    let email: String
    let username: String
    let isLoggedIn: Bool
    let lastSeen: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, username
        case isLoggedIn = "is_logged_in"
        case lastSeen = "last_seen"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
