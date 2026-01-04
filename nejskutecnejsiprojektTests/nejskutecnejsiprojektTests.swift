//
//  nejskutecnejsiprojektTests.swift
//  nejskutecnejsiprojektTests
//
//  Main test file - imports all test suites
//

import XCTest
@testable import nejskutecnejsiprojekt

@MainActor
final class nejskutecnejsiprojektTests: XCTestCase {
    
    // MARK: - App Launch Test
    
    func testAppLaunches() throws {
        // Basic sanity check that the app module is accessible
        XCTAssertNotNil(PersistenceService.shared)
        XCTAssertNotNil(ThemeManager.shared)
        XCTAssertNotNil(HapticsService.shared)
    }
    
    // MARK: - Model Tests
    
    func testPostModelDecodable() throws {
        let json = """
        {
            "id": 1,
            "userId": 1,
            "title": "Test Title",
            "body": "Test Body"
        }
        """
        
        let data = json.data(using: .utf8)!
        let post = try JSONDecoder().decode(Post.self, from: data)
        
        XCTAssertEqual(post.id, 1)
        XCTAssertEqual(post.title, "Test Title")
        XCTAssertEqual(post.body, "Test Body")
    }
    
    func testGomokuPlayerEnum() {
        XCTAssertEqual(Player.black.opponent, .white)
        XCTAssertEqual(Player.white.opponent, .black)
    }
    
    func testGameDifficultyValues() {
        XCTAssertGreaterThan(GameDifficulty.easy.flappyGapHeight, GameDifficulty.hard.flappyGapHeight)
        XCTAssertLessThan(GameDifficulty.easy.flappySpeed, GameDifficulty.hard.flappySpeed)
    }
    
    func testBoardPositionConversion() {
        let position = BoardPosition(row: 3, col: 5)
        let index = position.toIndex(boardSize: 15)
        let convertedBack = BoardPosition.fromIndex(index, boardSize: 15)
        
        XCTAssertEqual(position, convertedBack)
    }
}
