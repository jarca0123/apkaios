//
//  NetworkServiceTests.swift
//  nejskutecnejsiprojektTests
//
//  Unit tests for NetworkService
//

import XCTest
@testable import nejskutecnejsiprojekt

@MainActor
final class NetworkServiceTests: XCTestCase {
    
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
    }
    
    override func tearDown() {
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testFetchPostsReturnsDecodedData() async throws {
        // Given
        let expectedPosts = [
            Post(id: 1, title: "Test", body: "Body")
        ]
        await mockNetworkService.setMockData(expectedPosts)
        
        // When
        let posts = try await mockNetworkService.fetch(from: "posts", type: [Post].self)
        
        // Then
        XCTAssertEqual(posts.count, 1)
        XCTAssertEqual(posts.first?.title, "Test")
    }
    
    // MARK: - Error Tests
    
    func testFetchPostsThrowsOnFailure() async {
        // Given
        await mockNetworkService.setShouldFail(true, error: NetworkError.noConnection)
        
        // When/Then
        do {
            _ = try await mockNetworkService.fetch(from: "posts", type: [Post].self)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - NetworkError Tests
    
    func testNetworkErrorDescriptions() {
        XCTAssertNotNil(NetworkError.invalidURL.errorDescription)
        XCTAssertNotNil(NetworkError.invalidResponse.errorDescription)
        XCTAssertNotNil(NetworkError.httpError(statusCode: 404).errorDescription)
        XCTAssertNotNil(NetworkError.noConnection.errorDescription)
    }
    
    func testHTTPErrorContainsStatusCode() {
        let error = NetworkError.httpError(statusCode: 404)
        XCTAssertTrue(error.errorDescription?.contains("404") ?? false)
    }
}

// MARK: - Post Repository Tests

@MainActor
final class PostRepositoryTests: XCTestCase {
    
    var mockNetworkService: MockNetworkService!
    var sut: PostRepository!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = PostRepository(
            networkService: mockNetworkService,
            persistenceService: PersistenceService.shared
        )
    }
    
    override func tearDown() {
        mockNetworkService = nil
        sut = nil
        super.tearDown()
    }
    
    func testFetchPostsCallsNetworkService() async throws {
        // Given
        let expectedPosts = [Post(id: 1, title: "Test", body: "Body")]
        await mockNetworkService.setMockData(expectedPosts)
        
        // When
        let posts = try await sut.fetchPosts()
        
        // Then
        XCTAssertEqual(posts.count, 1)
    }
    
    func testFetchPostsCachesResult() async throws {
        // Given
        let expectedPosts = [Post(id: 1, title: "Test", body: "Body")]
        await mockNetworkService.setMockData(expectedPosts)
        
        // When
        _ = try await sut.fetchPosts()
        let cachedPosts = sut.getCachedPosts()
        
        // Then
        XCTAssertNotNil(cachedPosts)
        XCTAssertEqual(cachedPosts?.count, 1)
    }
}

