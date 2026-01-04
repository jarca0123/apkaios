//
//  Post.swift
//  nejskutecnejsiprojekt
//
//  Model for API posts
//

import Foundation

// Note: Post struct is defined in PersistenceService.swift to avoid circular dependencies
// This file serves as documentation and could hold additional post-related models

/// Extended post model with additional metadata
struct PostWithMetadata: Identifiable {
    let post: Post
    let isFromCache: Bool
    let fetchedAt: Date
    
    var id: Int { post.id }
}

/// Post list state
enum PostListState: Equatable {
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

