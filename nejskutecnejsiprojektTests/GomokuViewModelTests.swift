//
//  GomokuViewModelTests.swift
//  nejskutecnejsiprojektTests
//
//  Unit tests for GomokuViewModel
//

import XCTest
@testable import nejskutecnejsiprojekt

@MainActor
final class GomokuViewModelTests: XCTestCase {
    
    var sut: GomokuViewModel!
    
    override func setUp() {
        super.setUp()
        sut = GomokuViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsPlayingWithBlack() {
        XCTAssertEqual(sut.currentPlayer, .black)
        XCTAssertFalse(sut.isGameOver)
        XCTAssertTrue(sut.moveHistory.isEmpty)
    }
    
    func testBoardIsEmptyInitially() {
        for row in sut.board {
            for cell in row {
                XCTAssertNil(cell)
            }
        }
    }
    
    // MARK: - Stone Placement Tests
    
    func testPlaceStonePlacesStoneOnEmptyCell() {
        // When
        sut.placeStone(row: 7, col: 7)
        
        // Then
        XCTAssertEqual(sut.board[7][7], .black)
        XCTAssertEqual(sut.moveHistory.count, 1)
    }
    
    func testPlaceStoneAlternatesPlayers() {
        // When
        sut.placeStone(row: 7, col: 7)
        
        // Then
        XCTAssertEqual(sut.currentPlayer, .white)
        
        // When
        sut.placeStone(row: 7, col: 8)
        
        // Then
        XCTAssertEqual(sut.currentPlayer, .black)
    }
    
    func testPlaceStoneDoesNotOverwriteExistingStone() {
        // Given
        sut.placeStone(row: 7, col: 7)
        let initialPlayer = sut.board[7][7]
        
        // When
        sut.placeStone(row: 7, col: 7)
        
        // Then
        XCTAssertEqual(sut.board[7][7], initialPlayer)
        XCTAssertEqual(sut.moveHistory.count, 1)
    }
    
    // MARK: - Win Detection Tests
    
    func testHorizontalWinIsDetected() {
        // Place 5 black stones horizontally
        for col in 0..<5 {
            sut.placeStone(row: 7, col: col)
            if col < 4 {
                sut.placeStone(row: 8, col: col) // White moves
            }
        }
        
        // Then
        XCTAssertTrue(sut.isGameOver)
        if case .won(let winner) = sut.gameState {
            XCTAssertEqual(winner, .black)
        } else {
            XCTFail("Expected won state")
        }
    }
    
    func testVerticalWinIsDetected() {
        // Place 5 black stones vertically
        for row in 0..<5 {
            sut.placeStone(row: row, col: 7)
            if row < 4 {
                sut.placeStone(row: row, col: 8) // White moves
            }
        }
        
        // Then
        XCTAssertTrue(sut.isGameOver)
        if case .won(let winner) = sut.gameState {
            XCTAssertEqual(winner, .black)
        } else {
            XCTFail("Expected won state")
        }
    }
    
    func testDiagonalWinIsDetected() {
        // Place 5 black stones diagonally
        for i in 0..<5 {
            sut.placeStone(row: i, col: i)
            if i < 4 {
                sut.placeStone(row: i, col: i + 6) // White moves elsewhere
            }
        }
        
        // Then
        XCTAssertTrue(sut.isGameOver)
        if case .won(let winner) = sut.gameState {
            XCTAssertEqual(winner, .black)
        } else {
            XCTFail("Expected won state")
        }
    }
    
    func testFourInARowDoesNotWin() {
        // Place only 4 black stones horizontally
        for col in 0..<4 {
            sut.placeStone(row: 7, col: col)
            sut.placeStone(row: 8, col: col) // White moves
        }
        
        // Then
        XCTAssertFalse(sut.isGameOver)
    }
    
    // MARK: - Reset Tests
    
    func testResetGameClearsBoard() {
        // Given
        sut.placeStone(row: 7, col: 7)
        sut.placeStone(row: 7, col: 8)
        
        // When
        sut.resetGame()
        
        // Then
        XCTAssertEqual(sut.currentPlayer, .black)
        XCTAssertTrue(sut.moveHistory.isEmpty)
        XCTAssertNil(sut.board[7][7])
        XCTAssertNil(sut.board[7][8])
    }
    
    // MARK: - Undo Tests
    
    func testUndoRemovesLastMove() {
        // Given
        sut.placeStone(row: 7, col: 7)
        sut.placeStone(row: 7, col: 8)
        
        // When
        sut.undoLastMove()
        
        // Then
        XCTAssertNil(sut.board[7][8])
        XCTAssertEqual(sut.board[7][7], .black)
        XCTAssertEqual(sut.moveHistory.count, 1)
        XCTAssertEqual(sut.currentPlayer, .white)
    }
    
    func testCannotUndoAfterGameOver() {
        // Create a winning position
        for col in 0..<5 {
            sut.placeStone(row: 7, col: col)
            if col < 4 {
                sut.placeStone(row: 8, col: col)
            }
        }
        
        // Then
        XCTAssertFalse(sut.canUndo)
    }
}

