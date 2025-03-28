//
//  PostgresChange.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


struct PostgresChange: Codable {
    let schema: String
    let table: String
    let event: String
    let new: User?
    let old: User?
    
    enum CodingKeys: String, CodingKey {
        case schema, table, event
        case new, old
    }
}
