//
//  PostViewModelTests.swift
//  nejskutecnejsiprojektTests
//
//  Unit tests for PostViewModel
//

import XCTest
@testable import nejskutecnejsiprojekt

@MainActor
final class PostViewModelTests: XCTestCase {
    
    var sut: PostViewModel!
    var mockRepository: MockPostRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPostRepository()
        sut = PostViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsIdle() {
        XCTAssertEqual(sut.state, .idle)
        XCTAssertTrue(sut.posts.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Fetch Posts Tests
    
    func testFetchPostsSuccessUpdatesState() async {
        // Given
        let expectedPosts = [
            Post(id: 1, title: "Test 1", body: "Body 1"),
            Post(id: 2, title: "Test 2", body: "Body 2")
        ]
        mockRepository.mockPosts = expectedPosts
        
        // When
        await sut.fetchPosts()
        
        // Then
        XCTAssertEqual(sut.posts.count, 2)
        XCTAssertEqual(sut.posts.first?.title, "Test 1")
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isOffline)
    }
    
    func testFetchPostsFailureWithCacheFallsBackToCache() async {
        // Given
        let cachedPosts = [Post(id: 1, title: "Cached", body: "Cached body")]
        mockRepository.cachedPosts = cachedPosts
        mockRepository.shouldFail = true
        
        // When
        await sut.fetchPosts()
        
        // Then
        XCTAssertEqual(sut.posts.count, 1)
        XCTAssertEqual(sut.posts.first?.title, "Cached")
        XCTAssertTrue(sut.isOffline)
    }
    
    func testFetchPostsFailureWithoutCacheShowsError() async {
        // Given
        mockRepository.shouldFail = true
        mockRepository.cachedPosts = nil
        
        // When
        await sut.fetchPosts()
        
        // Then
        XCTAssertTrue(sut.posts.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshPostsUpdatesExistingPosts() async {
        // Given
        let initialPosts = [Post(id: 1, title: "Initial", body: "Body")]
        mockRepository.mockPosts = initialPosts
        await sut.fetchPosts()
        
        let updatedPosts = [
            Post(id: 1, title: "Updated", body: "Updated body"),
            Post(id: 2, title: "New", body: "New body")
        ]
        mockRepository.mockPosts = updatedPosts
        
        // When
        await sut.refreshPosts()
        
        // Then
        XCTAssertEqual(sut.posts.count, 2)
        XCTAssertEqual(sut.posts.first?.title, "Updated")
    }
    
    // MARK: - Cache Tests
    
    func testLoadCachedPostsIfAvailableLoadsCachedPosts() {
        // Given
        let cachedPosts = [Post(id: 1, title: "Cached", body: "Body")]
        mockRepository.cachedPosts = cachedPosts
        
        // When
        sut.loadCachedPostsIfAvailable()
        
        // Then
        XCTAssertEqual(sut.posts.count, 1)
        XCTAssertTrue(sut.isOffline)
    }
}

