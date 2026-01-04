//
//  GomokuViewModel.swift
//  nejskutecnejsiprojekt
//
//  ViewModel for Gomoku game with haptics and statistics
//

import SwiftUI
import Combine

@MainActor
final class GomokuViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var board: [[Player?]]
    @Published private(set) var gameState: GomokuGameState
    @Published private(set) var moveHistory: [GomokuMove] = []
    @Published private(set) var lastMove: BoardPosition?
    
    // Animation state
    @Published var showWinAnimation = false
    @Published var winningPositions: [BoardPosition] = []
    
    // MARK: - Configuration
    
    let config: GomokuBoardConfig
    
    // MARK: - Dependencies
    
    private let persistenceService: PersistenceService
    private let hapticsService: HapticsService
    
    // MARK: - Initialization
    
    init(
        config: GomokuBoardConfig = .standard,
        persistenceService: PersistenceService = .shared,
        hapticsService: HapticsService = .shared
    ) {
        self.config = config
        self.persistenceService = persistenceService
        self.hapticsService = hapticsService
        
        // Initialize empty board
        self.board = Array(repeating: Array(repeating: nil, count: config.size), count: config.size)
        self.gameState = .playing(currentPlayer: .black)
    }
    
    // MARK: - Game Actions
    
    /// Places a stone at the given position
    func placeStone(at position: BoardPosition) {
        guard case .playing(let currentPlayer) = gameState else { return }
        guard position.isValid(boardSize: config.size) else { return }
        guard board[position.row][position.col] == nil else { return }
        
        // Place the stone
        board[position.row][position.col] = currentPlayer
        lastMove = position
        
        // Record move
        let move = GomokuMove(
            position: position,
            player: currentPlayer,
            moveNumber: moveHistory.count + 1
        )
        moveHistory.append(move)
        
        // Haptic feedback
        hapticsService.playTap()
        
        // Check for win
        if let winPositions = checkWin(at: position, player: currentPlayer) {
            winningPositions = winPositions
            gameState = .won(winner: currentPlayer)
            showWinAnimation = true
            hapticsService.playSuccess()
            
            // Record stats
            let winner: GomokuWinner = currentPlayer == .black ? .black : .white
            persistenceService.recordGomokuGame(winner: winner)
            
        } else if isBoardFull() {
            gameState = .draw
            hapticsService.playWarning()
            persistenceService.recordGomokuGame(winner: .draw)
            
        } else {
            // Switch player
            gameState = .playing(currentPlayer: currentPlayer.opponent)
        }
    }
    
    /// Places a stone using row/col indices
    func placeStone(row: Int, col: Int) {
        placeStone(at: BoardPosition(row: row, col: col))
    }
    
    /// Resets the game
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: config.size), count: config.size)
        gameState = .playing(currentPlayer: .black)
        moveHistory = []
        lastMove = nil
        winningPositions = []
        showWinAnimation = false
        hapticsService.playTap()
    }
    
    /// Undoes the last move (if available)
    func undoLastMove() {
        guard let lastMove = moveHistory.popLast() else { return }
        
        board[lastMove.position.row][lastMove.position.col] = nil
        self.lastMove = moveHistory.last?.position
        
        // Reset game state to playing with the player who made the undone move
        gameState = .playing(currentPlayer: lastMove.player)
        winningPositions = []
        showWinAnimation = false
        
        hapticsService.playTap()
    }
    
    // MARK: - Win Detection
    
    /// Checks if placing a stone at the given position results in a win
    /// Returns the winning positions if there's a win, nil otherwise
    private func checkWin(at position: BoardPosition, player: Player) -> [BoardPosition]? {
        for direction in Direction.allCases {
            let positions = getLinePositions(from: position, direction: direction, player: player)
            if positions.count >= config.winCondition {
                return positions
            }
        }
        return nil
    }
    
    /// Gets all positions in a line from the given position
    private func getLinePositions(from position: BoardPosition, direction: Direction, player: Player) -> [BoardPosition] {
        var positions = [position]
        let (dRow, dCol) = direction.delta
        
        // Check in positive direction
        var r = position.row + dRow
        var c = position.col + dCol
        while r >= 0 && r < config.size && c >= 0 && c < config.size && board[r][c] == player {
            positions.append(BoardPosition(row: r, col: c))
            r += dRow
            c += dCol
        }
        
        // Check in negative direction
        r = position.row - dRow
        c = position.col - dCol
        while r >= 0 && r < config.size && c >= 0 && c < config.size && board[r][c] == player {
            positions.append(BoardPosition(row: r, col: c))
            r -= dRow
            c -= dCol
        }
        
        return positions
    }
    
    /// Checks if the board is full
    private func isBoardFull() -> Bool {
        for row in board {
            for cell in row {
                if cell == nil {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Computed Properties
    
    var currentPlayer: Player? {
        if case .playing(let player) = gameState {
            return player
        }
        return nil
    }
    
    var isGameOver: Bool {
        gameState.isGameOver
    }
    
    var canUndo: Bool {
        !moveHistory.isEmpty && !isGameOver
    }
    
    var statusText: String {
        gameState.statusText
    }
    
    var statusColor: Color {
        gameState.statusColor
    }
    
    // MARK: - Statistics
    
    var stats: GomokuStats {
        GomokuStats(
            blackWins: persistenceService.gomokuBlackWins,
            whiteWins: persistenceService.gomokuWhiteWins,
            draws: persistenceService.gomokuDraws,
            totalGames: persistenceService.gomokuGamesPlayed
        )
    }
}

// MARK: - Statistics Model

struct GomokuStats {
    let blackWins: Int
    let whiteWins: Int
    let draws: Int
    let totalGames: Int
    
    var blackWinRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(blackWins) / Double(totalGames) * 100
    }
    
    var whiteWinRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(whiteWins) / Double(totalGames) * 100
    }
}

