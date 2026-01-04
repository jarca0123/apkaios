//
//  FlappyViewModelTests.swift
//  nejskutecnejsiprojektTests
//
//  Unit tests for FlappyViewModel
//

import XCTest
@testable import nejskutecnejsiprojekt

@MainActor
final class FlappyViewModelTests: XCTestCase {
    
    var sut: FlappyViewModel!
    
    override func setUp() {
        super.setUp()
        sut = FlappyViewModel()
        sut.setupGame(size: CGSize(width: 300, height: 400))
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsReady() {
        XCTAssertEqual(sut.gameState, .ready)
        XCTAssertEqual(sut.score, 0)
        XCTAssertTrue(sut.obstacles.isEmpty)
    }
    
    func testPlayerStartsInCorrectPosition() {
        let expectedX = 300 * sut.config.playerStartXRatio
        let expectedY: CGFloat = 200
        
        XCTAssertEqual(sut.player.position.x, expectedX, accuracy: 1)
        XCTAssertEqual(sut.player.position.y, expectedY, accuracy: 1)
    }
    
    // MARK: - Game State Tests
    
    func testTapWhileReadyStartsGame() {
        // When
        sut.handleTap()
        
        // Then
        XCTAssertEqual(sut.gameState, .playing)
    }
    
    func testTapWhilePlayingMakesPlayerJump() {
        // Given
        sut.handleTap() // Start game (also jumps now, velocity = jumpStrength)
        
        // Velocity after first tap should be jumpStrength (negative = upward)
        XCTAssertEqual(sut.player.velocity, sut.config.jumpStrength)
        
        // When - tap again while playing
        sut.handleTap()
        
        // Then - velocity should still be jumpStrength (reset by jump)
        XCTAssertEqual(sut.player.velocity, sut.config.jumpStrength)
    }
    
    // MARK: - Reset Tests
    
    func testResetGameResetsAllState() {
        // Given
        sut.handleTap() // Start game
        
        // When
        sut.resetGame()
        
        // Then
        XCTAssertEqual(sut.gameState, .ready)
        XCTAssertEqual(sut.score, 0)
        XCTAssertTrue(sut.obstacles.isEmpty)
    }
    
    // MARK: - Collision Detection Tests
    
    func testCollisionDetectorDetectsTopCollision() {
        // Given
        let player = FlappyPlayer(
            startPosition: CGPoint(x: 100, y: 50),
            size: 30
        )
        let obstacle = FlappyObstacle(
            positionX: 100,
            gapYPosition: 100,
            gapHeight: 150,
            width: 60
        )
        
        // When
        let collision = CollisionDetector.checkCollision(
            player: player,
            obstacle: obstacle,
            gameHeight: 400
        )
        
        // Then
        XCTAssertTrue(collision)
    }
    
    func testCollisionDetectorDetectsBottomCollision() {
        // Given
        let player = FlappyPlayer(
            startPosition: CGPoint(x: 100, y: 350),
            size: 30
        )
        let obstacle = FlappyObstacle(
            positionX: 100,
            gapYPosition: 100,
            gapHeight: 150,
            width: 60
        )
        
        // When
        let collision = CollisionDetector.checkCollision(
            player: player,
            obstacle: obstacle,
            gameHeight: 400
        )
        
        // Then
        XCTAssertTrue(collision)
    }
    
    func testCollisionDetectorAllowsPassThroughGap() {
        // Given
        let player = FlappyPlayer(
            startPosition: CGPoint(x: 100, y: 175), // Middle of gap (100 + 150/2)
            size: 30
        )
        let obstacle = FlappyObstacle(
            positionX: 100,
            gapYPosition: 100,
            gapHeight: 150,
            width: 60
        )
        
        // When
        let collision = CollisionDetector.checkCollision(
            player: player,
            obstacle: obstacle,
            gameHeight: 400
        )
        
        // Then
        XCTAssertFalse(collision)
    }
    
    func testOutOfBoundsDetectsTopBoundary() {
        // Given
        let player = FlappyPlayer(
            startPosition: CGPoint(x: 100, y: 10),
            size: 30
        )
        
        // When
        let outOfBounds = CollisionDetector.isOutOfBounds(player: player, gameHeight: 400)
        
        // Then
        XCTAssertTrue(outOfBounds)
    }
    
    func testOutOfBoundsDetectsBottomBoundary() {
        // Given
        let player = FlappyPlayer(
            startPosition: CGPoint(x: 100, y: 390),
            size: 30
        )
        
        // When
        let outOfBounds = CollisionDetector.isOutOfBounds(player: player, gameHeight: 400)
        
        // Then
        XCTAssertTrue(outOfBounds)
    }
    
    // MARK: - Status Message Tests
    
    func testStatusMessageForReadyState() {
        XCTAssertEqual(sut.statusMessage, "Klepni pro start")
    }
    
    func testStatusMessageForPlayingState() {
        sut.handleTap()
        XCTAssertEqual(sut.statusMessage, "Skóre: 0")
    }
}

