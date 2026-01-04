//
//  Post.swift
//  nejskutecnejsiprojekt
//
//  Model for API posts
//

import Foundation

/// Post model from JSONPlaceholder API
struct Post: Codable, Identifiable, Equatable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
    
    init(id: Int, userId: Int = 1, title: String, body: String) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
}

/// Extended post model with additional metadata
struct PostWithMetadata: Identifiable, Sendable {
    let post: Post
    let isFromCache: Bool
    let fetchedAt: Date
    
    var id: Int { post.id }
}

/// Post list state
enum PostListState: Equatable, Sendable {
    case idle
    case loading
    case loaded([Post])
    case offline([Post])
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var posts: [Post] {
        switch self {
        case .loaded(let posts), .offline(let posts):
            return posts
        default:
            return []
        }
    }
    
    var isOffline: Bool {
        if case .offline = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
