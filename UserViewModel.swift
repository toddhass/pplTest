//
//  UserViewModel.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


  
//    private let supabase = SupabaseClient(
//        supabaseURL: URL(string: "https://cwinjyvcazkfqfbrbops.supabase.co")!,
//        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3aW5qeXZjYXprZnFmYnJib3BzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxNjUwMTcsImV4cCI6MjA1NTc0MTAxN30.wijPjFD-aUZrLCr_hfFGjji_wblj8u0_usaN-R-pwB4"
//    )
   
import SwiftUI
import Supabase

@MainActor
class UserViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var users: [User] = []
    @Published var recentlyLoggedInUserIDs: Set<UUID> = []
    @Published var groupMessages: [Message] = [] // Unified to [Message]
    @Published var dmMessages: [Message] = []   // Consistent with [Message]
    @Published var currentDMRecipientId: UUID?
    
    // MARK: - Private Properties
    private var currentUserId: UUID?
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://cwinjyvcazkfqfbrbops.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3aW5qeXZjYXprZnFmYnJib3BzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxNjUwMTcsImV4cCI6MjA1NTc0MTAxN30.wijPjFD-aUZrLCr_hfFGjji_wblj8u0_usaN-R-pwB4"
    )
    private var usersChannel: RealtimeChannelV2?
    private var messagesChannel: RealtimeChannelV2?
    private var usersSubscription: RealtimeSubscription?
    private var messagesSubscription: RealtimeSubscription?
    
    // MARK: - Initialization
    init() {
        usersChannel = supabase.channel("users")
        messagesChannel = supabase.channel("messages")
        Task { await setupRealtime() }
    }
    
    // MARK: - Deinitialization
    deinit {
        usersSubscription?.cancel()
        messagesSubscription?.cancel()
Task { [weak self] in
            await self?.usersChannel?.unsubscribe()
            await self?.messagesChannel?.unsubscribe()
        }
    }
    
    // MARK: - Setup Real-Time Subscriptions
    private func setupRealtime() async {
        if let session = try? await supabase.auth.session {
            currentUserId = session.user.id
        }
        
        usersSubscription = usersChannel!.onPostgresChange(AnyAction.self, schema: "public", table: "users") { [weak self] _ in
            Task { @MainActor in
                await self?.fetchUsers()
            }
        }
        
        messagesSubscription = messagesChannel!.onPostgresChange(AnyAction.self, schema: "public", table: "messages") { [weak self] _ in
            Task { @MainActor in
                await self?.fetchGroupMessages()
                if let recipientId = self?.currentDMRecipientId {
                    await self?.fetchDMMessages(with: recipientId)
                }
            }
        }
        
        await usersChannel!.subscribe()
        await messagesChannel!.subscribe()
        await fetchUsers()
        await fetchGroupMessages()
    }
    
    // MARK: - Fetch Methods
    func fetchUsers() async {
        do {
            let fetchedUsers: [User] = try await supabase.from("users")
                .select()
                .eq("is_logged_in", value: true)
                .execute()
                .value
            await MainActor.run {
                self.users = fetchedUsers
                print("Fetched users: \(fetchedUsers.count)")
            }
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
        }
    }
    
    func fetchGroupMessages() async {
        do {
            let fetchedMessages: [Message] = try await supabase.from("messages")
                .select("*, users!user_id(username)")
                .is("recipient_id", value: nil)
                .order("created_at", ascending: true)
                .execute()
                .value
            await MainActor.run {
                self.groupMessages = fetchedMessages
                print("Fetched group messages: \(fetchedMessages.count)")
            }
        } catch {
            print("Error fetching group messages: \(error.localizedDescription)")
        }
    }
    
    func fetchDMMessages(with recipientId: UUID) async {
        guard let currentUserId = currentUserId, !currentUserId.uuidString.isEmpty else {
            print("Error: Current user ID is missing or invalid.")
            return
        }
        do {
            let currentUserIdStr = currentUserId.uuidString
            let recipientIdStr = recipientId.uuidString
            let fetchedMessages: [Message] = try await supabase.from("messages")
                .select("*, users!user_id(username)")
                .or("and(user_id.eq.\(currentUserIdStr),recipient_id.eq.\(recipientIdStr)),and(user_id.eq.\(recipientIdStr),recipient_id.eq.\(currentUserIdStr))")
                .order("created_at", ascending: true)
                .execute()
                .value
            await MainActor.run {
                self.dmMessages = fetchedMessages
                print("Fetched DM messages: \(fetchedMessages.count)")
            }
        } catch {
            print("Error fetching DM messages: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Send Message
    func sendMessage(content: String, recipientId: UUID? = nil) async {
        guard let session = try? await supabase.auth.session else {
            print("No active session available")
            return
        }
        let userId = session.user.id
        do {
            let existingUsers: [User] = try await supabase.from("users")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            if existingUsers.isEmpty {
                try await supabase.from("users")
                    .insert([
                        "id": AnyEncodable(userId),
                        "email": AnyEncodable(session.user.email ?? "unknown"),
                        "username": AnyEncodable(session.user.userMetadata["username"] as? String ?? "User"),
                        "is_logged_in": AnyEncodable(true)
                    ])
                    .execute()
            }
            
            // Prepare message data
            var messageData: [String: AnyEncodable] = [
                "user_id": AnyEncodable(userId.uuidString),
                "content": AnyEncodable(content)
            ]
            if let recipientId {
                messageData["recipient_id"] = AnyEncodable(recipientId.uuidString)
            }
            
            // Insert message
            try await supabase.from("messages")
                .insert(messageData)
                .execute()
            print("Sent message: \(content) by user \(userId) to \(recipientId?.uuidString ?? "group")")
            
            // Refresh messages
            if let recipientId {
                await fetchDMMessages(with: recipientId)
            } else {
                await fetchGroupMessages()
            }
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Utility Methods
    func isRecentlyLoggedIn(_ user: User) -> Bool {
        recentlyLoggedInUserIDs.contains(user.id)
    }
    
    func isCurrentUser(_ userId: UUID) -> Bool {
        userId == currentUserId
    }
}
