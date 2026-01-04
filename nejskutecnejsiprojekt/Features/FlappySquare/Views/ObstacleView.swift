//
//  ObstacleView.swift
//  nejskutecnejsiprojekt
//
//  View for obstacles with proper GeometryReader-based dimensions
//

import SwiftUI

/// Individual obstacle view that properly uses game dimensions
struct ObstacleView: View {
    let obstacle: FlappyObstacle
    let gameHeight: CGFloat // Passed from parent GeometryReader
    
    var body: some View {
        ZStack {
            // Top obstacle (pipe)
            topObstacle
            
            // Bottom obstacle (pipe)
            bottomObstacle
        }
    }
    
    // MARK: - Top Obstacle
    
    private var topObstacle: some View {
        let height = obstacle.topHeight(gameHeight: gameHeight)
        
        return VStack(spacing: 0) {
            // Pipe body
            Rectangle()
                .fill(obstacleGradient)
                .frame(width: obstacle.width, height: max(0, height - 20))
            
            // Pipe cap
            RoundedRectangle(cornerRadius: 4)
                .fill(obstacleCapGradient)
                .frame(width: obstacle.width + 8, height: 20)
        }
        .position(
            x: obstacle.positionX,
            y: height / 2
        )
    }
    
    // MARK: - Bottom Obstacle
    
    private var bottomObstacle: some View {
        let height = obstacle.bottomHeight(gameHeight: gameHeight)
        let topY = obstacle.bottomTopY
        
        return VStack(spacing: 0) {
            // Pipe cap
            RoundedRectangle(cornerRadius: 4)
                .fill(obstacleCapGradient)
                .frame(width: obstacle.width + 8, height: 20)
            
            // Pipe body
            Rectangle()
                .fill(obstacleGradient)
                .frame(width: obstacle.width, height: max(0, height - 20))
        }
        .position(
            x: obstacle.positionX,
            y: topY + height / 2
        )
    }
    
    // MARK: - Gradients
    
    private var obstacleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.green.opacity(0.9),
                Color.green,
                Color(red: 0.1, green: 0.5, blue: 0.1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var obstacleCapGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.green,
                Color(red: 0.1, green: 0.6, blue: 0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Obstacles Container

/// Container view that renders all obstacles
struct ObstaclesContainerView: View {
    let obstacles: [FlappyObstacle]
    let gameHeight: CGFloat
    
    var body: some View {
        ForEach(obstacles) { obstacle in
            ObstacleView(obstacle: obstacle, gameHeight: gameHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.blue.opacity(0.3)
        
        ObstacleView(
            obstacle: FlappyObstacle(
                positionX: 150,
                gapYPosition: 150,
                gapHeight: 150,
                width: 60
            ),
            gameHeight: 400
        )
    }
    .frame(width: 300, height: 400)
}

