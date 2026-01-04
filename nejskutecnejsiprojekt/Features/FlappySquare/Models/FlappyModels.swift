//
//  FlappyModels.swift
//  nejskutecnejsiprojekt
//
//  Models for the Flappy Square game
//

import SwiftUI
import Combine
// MARK: - Game State

/// Represents the current state of the Flappy Square game
enum FlappyGameState: Equatable {
    case ready
    case playing
    case paused
    case gameOver(score: Int, isHighScore: Bool)
    
    var isActive: Bool {
        self == .playing
    }
    
    var canStart: Bool {
        switch self {
        case .ready, .gameOver: return true
        default: return false
        }
    }
}

// MARK: - Obstacle

/// Represents an obstacle (pipe pair) in the game
struct FlappyObstacle: Identifiable, Equatable {
    let id: UUID
    var positionX: CGFloat
    let gapYPosition: CGFloat
    let gapHeight: CGFloat
    let width: CGFloat
    var scored: Bool
    
    init(
        id: UUID = UUID(),
        positionX: CGFloat,
        gapYPosition: CGFloat,
        gapHeight: CGFloat,
        width: CGFloat,
        scored: Bool = false
    ) {
        self.id = id
        self.positionX = positionX
        self.gapYPosition = gapYPosition
        self.gapHeight = gapHeight
        self.width = width
        self.scored = scored
    }
    
    /// Top obstacle height
    func topHeight(gameHeight: CGFloat) -> CGFloat {
        gapYPosition
    }
    
    /// Bottom obstacle height
    func bottomHeight(gameHeight: CGFloat) -> CGFloat {
        gameHeight - gapYPosition - gapHeight
    }
    
    /// Y position of bottom obstacle's top edge
    var bottomTopY: CGFloat {
        gapYPosition + gapHeight
    }
}

// MARK: - Player

/// Represents the player square
struct FlappyPlayer {
    var position: CGPoint
    var velocity: CGFloat
    let size: CGFloat
    
    init(startPosition: CGPoint, size: CGFloat) {
        self.position = startPosition
        self.velocity = 0
        self.size = size
    }
    
    var rect: CGRect {
        CGRect(
            x: position.x - size / 2,
            y: position.y - size / 2,
            width: size,
            height: size
        )
    }
    
    mutating func applyGravity(_ gravity: CGFloat) {
        velocity += gravity
        position.y += velocity
    }
    
    mutating func jump(strength: CGFloat) {
        velocity = strength
    }
    
    mutating func reset(to position: CGPoint) {
        self.position = position
        self.velocity = 0
    }
}

// MARK: - Game Configuration

/// Configuration for the Flappy Square game
struct FlappyGameConfig {
    let gravity: CGFloat
    let jumpStrength: CGFloat
    let obstacleWidth: CGFloat
    let gapHeight: CGFloat
    let obstacleSpeed: CGFloat
    let obstacleSpawnInterval: TimeInterval
    let playerSize: CGFloat
    let playerStartXRatio: CGFloat
    
    static func config(for difficulty: GameDifficulty) -> FlappyGameConfig {
        FlappyGameConfig(
            gravity: 0.35,
            jumpStrength: -7,
            obstacleWidth: 60,
            gapHeight: difficulty.flappyGapHeight,
            obstacleSpeed: difficulty.flappySpeed,
            obstacleSpawnInterval: 1.8,
            playerSize: 30,
            playerStartXRatio: 0.25
        )
    }
    
    static let standard = FlappyGameConfig(
        gravity: 0.35,
        jumpStrength: -7,
        obstacleWidth: 60,
        gapHeight: 150,
        obstacleSpeed: 3,
        obstacleSpawnInterval: 1.8,
        playerSize: 30,
        playerStartXRatio: 0.25
    )
}

// MARK: - Collision Detection

struct CollisionDetector {
    
    /// Checks if player collides with an obstacle
    static func checkCollision(
        player: FlappyPlayer,
        obstacle: FlappyObstacle,
        gameHeight: CGFloat
    ) -> Bool {
        let playerRect = player.rect
        
        // Check if player is horizontally aligned with obstacle
        let obstacleLeftEdge = obstacle.positionX - obstacle.width / 2
        let obstacleRightEdge = obstacle.positionX + obstacle.width / 2
        
        let playerLeftEdge = playerRect.minX
        let playerRightEdge = playerRect.maxX
        
        // Not horizontally overlapping
        if playerRightEdge < obstacleLeftEdge || playerLeftEdge > obstacleRightEdge {
            return false
        }
        
        // Check vertical collision
        let playerTopEdge = playerRect.minY
        let playerBottomEdge = playerRect.maxY
        
        // Collision with top obstacle
        if playerTopEdge < obstacle.gapYPosition {
            return true
        }
        
        // Collision with bottom obstacle
        if playerBottomEdge > obstacle.bottomTopY {
            return true
        }
        
        return false
    }
    
    /// Checks if player is out of bounds
    static func isOutOfBounds(player: FlappyPlayer, gameHeight: CGFloat) -> Bool {
        player.position.y - player.size / 2 < 0 ||
        player.position.y + player.size / 2 > gameHeight
    }
}

// MARK: - Flappy Stats

struct FlappyStats {
    let bestScore: Int
    let gamesPlayed: Int
    let totalScore: Int
    let averageScore: Double
}

