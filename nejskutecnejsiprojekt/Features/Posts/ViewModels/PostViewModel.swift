//
//  PostViewModel.swift
//  nejskutecnejsiprojekt
//
//  ViewModel for posts list with async/await and offline support
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PostViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var state: PostListState = .idle
    @Published private(set) var isRefreshing = false
    
    // MARK: - Dependencies
    
    private let repository: PostRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: PostRepositoryProtocol? = nil) {
        self.repository = repository ?? PostRepository.makeDefault()
    }
    
    // MARK: - Public Methods
    
    /// Fetches posts - tries network first, falls back to cache
    func fetchPosts() async {
        // Don't fetch if already loading
        guard !state.isLoading else { return }
        
        // Show loading state only if we have no posts
        if state.posts.isEmpty {
            state = .loading
        }
        
        do {
            let posts = try await repository.fetchPosts()
            state = .loaded(posts)
        } catch {
            // Try to load from cache on error
            if let cachedPosts = repository.getCachedPosts(), !cachedPosts.isEmpty {
                state = .offline(cachedPosts)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    /// Refreshes posts (pull-to-refresh)
    func refreshPosts() async {
        isRefreshing = true
        
        do {
            let posts = try await repository.fetchPosts()
            state = .loaded(posts)
        } catch {
            // Keep current posts on refresh failure, just show a brief error
            if state.posts.isEmpty {
                if let cachedPosts = repository.getCachedPosts(), !cachedPosts.isEmpty {
                    state = .offline(cachedPosts)
                } else {
                    state = .error(error.localizedDescription)
                }
            }
            // If we have posts, keep them and don't change state
        }
        
        isRefreshing = false
    }
    
    /// Loads cached posts if available (for initial load)
    func loadCachedPostsIfAvailable() {
        if case .idle = state,
           let cachedPosts = repository.getCachedPosts(),
           !cachedPosts.isEmpty {
            state = .offline(cachedPosts)
        }
    }
    
    // MARK: - Computed Properties
    
    var posts: [Post] {
        state.posts
    }
    
    var isLoading: Bool {
        state.isLoading
    }
    
    var isOffline: Bool {
        state.isOffline
    }
    
    var errorMessage: String? {
        state.errorMessage
    }
    
    var showEmptyState: Bool {
        !isLoading && posts.isEmpty && errorMessage == nil
    }
}

