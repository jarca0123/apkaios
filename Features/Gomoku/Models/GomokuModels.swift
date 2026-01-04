//
//  GomokuModels.swift
//  nejskutecnejsiprojekt
//
//  Models for the Gomoku game
//

import SwiftUI

// MARK: - Player

/// Represents a player in Gomoku
enum Player: String, CaseIterable {
    case black = "Černý"
    case white = "Bílý"
    
    var color: Color {
        switch self {
        case .black: return .black
        case .white: return .white
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .black: return .gray.opacity(0.5)
        case .white: return .gray.opacity(0.3)
        }
    }
    
    var opponent: Player {
        self == .black ? .white : .black
    }
    
    var displayName: String {
        rawValue
    }
}

// MARK: - Game State

/// Represents the current state of the Gomoku game
enum GomokuGameState: Equatable {
    case playing(currentPlayer: Player)
    case won(winner: Player)
    case draw
    
    var isGameOver: Bool {
        switch self {
        case .playing: return false
        case .won, .draw: return true
        }
    }
    
    var statusText: String {
        switch self {
        case .playing(let player):
            return "Hraje: \(player.displayName)"
        case .won(let winner):
            return "\(winner.displayName) vyhrál!"
        case .draw:
            return "Remíza!"
        }
    }
    
    var statusColor: Color {
        switch self {
        case .playing(let player):
            return player == .black ? .primary : .red
        case .won(let winner):
            return winner == .black ? .primary : .red
        case .draw:
            return .orange
        }
    }
}

// MARK: - Board Position

/// Represents a position on the board
struct BoardPosition: Hashable {
    let row: Int
    let col: Int
    
    static func fromIndex(_ index: Int, boardSize: Int) -> BoardPosition {
        BoardPosition(row: index / boardSize, col: index % boardSize)
    }
    
    func toIndex(boardSize: Int) -> Int {
        row * boardSize + col
    }
    
    func isValid(boardSize: Int) -> Bool {
        row >= 0 && row < boardSize && col >= 0 && col < boardSize
    }
}

// MARK: - Move

/// Represents a move made in the game
struct GomokuMove: Identifiable, Equatable {
    let id = UUID()
    let position: BoardPosition
    let player: Player
    let moveNumber: Int
}

// MARK: - Board Configuration

/// Configuration for the Gomoku board
struct GomokuBoardConfig {
    let size: Int
    let winCondition: Int
    
    static let standard = GomokuBoardConfig(size: 15, winCondition: 5)
    
    var totalCells: Int { size * size }
}

// MARK: - Direction

/// Directions for checking win conditions
enum Direction: CaseIterable {
    case horizontal
    case vertical
    case diagonalDown
    case diagonalUp
    
    var delta: (row: Int, col: Int) {
        switch self {
        case .horizontal: return (0, 1)
        case .vertical: return (1, 0)
        case .diagonalDown: return (1, 1)
        case .diagonalUp: return (1, -1)
        }
    }
}

