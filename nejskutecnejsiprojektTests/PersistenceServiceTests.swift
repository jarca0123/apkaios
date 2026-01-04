//
//  PersistenceServiceTests.swift
//  nejskutecnejsiprojektTests
//
//  Unit tests for PersistenceService
//

import XCTest
@testable import nejskutecnejsiprojekt

final class PersistenceServiceTests: XCTestCase {
    
    var sut: PersistenceService!
    
    override func setUp() {
        super.setUp()
        // Note: In production, you'd use a test-specific UserDefaults suite
        sut = PersistenceService.shared
        
        // Reset stats before each test
        sut.resetAllStats()
    }
    
    override func tearDown() {
        sut.resetAllStats()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Flappy Stats Tests
    
    func testRecordFlappyGameIncrementsGamesPlayed() {
        // Given
        let initialGames = sut.flappyGamesPlayed
        
        // When
        sut.recordFlappyGame(score: 10)
        
        // Then
        XCTAssertEqual(sut.flappyGamesPlayed, initialGames + 1)
    }
    
    func testRecordFlappyGameUpdatesBestScore() {
        // When
        sut.recordFlappyGame(score: 50)
        
        // Then
        XCTAssertEqual(sut.flappyBestScore, 50)
        
        // When - lower score
        sut.recordFlappyGame(score: 30)
        
        // Then - best score unchanged
        XCTAssertEqual(sut.flappyBestScore, 50)
        
        // When - higher score
        sut.recordFlappyGame(score: 100)
        
        // Then
        XCTAssertEqual(sut.flappyBestScore, 100)
    }
    
    func testRecordFlappyGameUpdatesTotalScore() {
        // When
        sut.recordFlappyGame(score: 10)
        sut.recordFlappyGame(score: 20)
        sut.recordFlappyGame(score: 30)
        
        // Then
        XCTAssertEqual(sut.flappyTotalScore, 60)
    }
    
    func testFlappyAverageScoreCalculation() {
        // When
        sut.recordFlappyGame(score: 10)
        sut.recordFlappyGame(score: 20)
        sut.recordFlappyGame(score: 30)
        
        // Then
        XCTAssertEqual(sut.flappyAverageScore, 20, accuracy: 0.01)
    }
    
    func testFlappyAverageScoreWithNoGames() {
        XCTAssertEqual(sut.flappyAverageScore, 0)
    }
    
    // MARK: - Gomoku Stats Tests
    
    func testRecordGomokuBlackWin() {
        // When
        sut.recordGomokuGame(winner: .black)
        
        // Then
        XCTAssertEqual(sut.gomokuBlackWins, 1)
        XCTAssertEqual(sut.gomokuGamesPlayed, 1)
    }
    
    func testRecordGomokuWhiteWin() {
        // When
        sut.recordGomokuGame(winner: .white)
        
        // Then
        XCTAssertEqual(sut.gomokuWhiteWins, 1)
        XCTAssertEqual(sut.gomokuGamesPlayed, 1)
    }
    
    func testRecordGomokuDraw() {
        // When
        sut.recordGomokuGame(winner: .draw)
        
        // Then
        XCTAssertEqual(sut.gomokuDraws, 1)
        XCTAssertEqual(sut.gomokuGamesPlayed, 1)
    }
    
    // MARK: - Reset Tests
    
    func testResetFlappyStats() {
        // Given
        sut.recordFlappyGame(score: 100)
        
        // When
        sut.resetFlappyStats()
        
        // Then
        XCTAssertEqual(sut.flappyBestScore, 0)
        XCTAssertEqual(sut.flappyGamesPlayed, 0)
        XCTAssertEqual(sut.flappyTotalScore, 0)
    }
    
    func testResetGomokuStats() {
        // Given
        sut.recordGomokuGame(winner: .black)
        sut.recordGomokuGame(winner: .white)
        
        // When
        sut.resetGomokuStats()
        
        // Then
        XCTAssertEqual(sut.gomokuBlackWins, 0)
        XCTAssertEqual(sut.gomokuWhiteWins, 0)
        XCTAssertEqual(sut.gomokuDraws, 0)
        XCTAssertEqual(sut.gomokuGamesPlayed, 0)
    }
    
    // MARK: - Cache Tests
    
    func testCacheAndRetrievePosts() {
        // Given
        let posts = [
            Post(id: 1, title: "Test 1", body: "Body 1"),
            Post(id: 2, title: "Test 2", body: "Body 2")
        ]
        
        // When
        sut.cachePosts(posts)
        let cachedPosts = sut.getCachedPosts()
        
        // Then
        XCTAssertNotNil(cachedPosts)
        XCTAssertEqual(cachedPosts?.count, 2)
        XCTAssertEqual(cachedPosts?.first?.title, "Test 1")
    }
    
    func testCacheAgeIsSet() {
        // Given
        let posts = [Post(id: 1, title: "Test", body: "Body")]
        
        // When
        sut.cachePosts(posts)
        
        // Then
        XCTAssertNotNil(sut.cacheAge)
        XCTAssertLessThan(sut.cacheAge ?? 999, 5) // Should be less than 5 seconds
    }
}

