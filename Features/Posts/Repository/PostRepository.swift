//
//  PostRepository.swift
//  nejskutecnejsiprojekt
//
//  Repository pattern for posts - handles data fetching and caching
//

import Foundation

/// Protocol for post repository - enables dependency injection
protocol PostRepositoryProtocol {
    func fetchPosts() async throws -> [Post]
    func getCachedPosts() -> [Post]?
    func cachePosts(_ posts: [Post])
}

/// Main post repository implementation
final class PostRepository: PostRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let persistenceService: PersistenceService
    
    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        persistenceService: PersistenceService = .shared
    ) {
        self.networkService = networkService
        self.persistenceService = persistenceService
    }
    
    /// Fetches posts from the API
    /// - Returns: Array of posts
    /// - Throws: NetworkError if fetch fails
    func fetchPosts() async throws -> [Post] {
        let posts = try await networkService.fetch(from: "posts", type: [Post].self)
        // Cache the posts for offline use
        cachePosts(posts)
        return posts
    }
    
    /// Gets cached posts from local storage
    func getCachedPosts() -> [Post]? {
        persistenceService.getCachedPosts()
    }
    
    /// Caches posts to local storage
    func cachePosts(_ posts: [Post]) {
        persistenceService.cachePosts(posts)
    }
    
    /// Checks if cache is valid
    var isCacheValid: Bool {
        persistenceService.isCacheValid
    }
}

/// Mock repository for testing
final class MockPostRepository: PostRepositoryProtocol {
    var mockPosts: [Post] = []
    var shouldFail = false
    var cachedPosts: [Post]?
    
    func fetchPosts() async throws -> [Post] {
        if shouldFail {
            throw NetworkError.noConnection
        }
        return mockPosts
    }
    
    func getCachedPosts() -> [Post]? {
        cachedPosts
    }
    
    func cachePosts(_ posts: [Post]) {
        cachedPosts = posts
    }
}

