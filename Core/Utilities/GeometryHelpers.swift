//
//  GeometryHelpers.swift
//  nejskutecnejsiprojekt
//
//  Utility functions for geometry calculations
//

import SwiftUI

/// Namespace for geometry helper functions
enum GeometryHelpers {
    
    /// Calculates cell size for a grid that fits within given dimensions
    /// - Parameters:
    ///   - availableSize: The available space
    ///   - gridSize: Number of cells in each dimension
    ///   - padding: Optional padding to subtract
    /// - Returns: The calculated cell size
    static func cellSize(
        for availableSize: CGSize,
        gridSize: Int,
        padding: CGFloat = 0
    ) -> CGFloat {
        let adjustedWidth = availableSize.width - (padding * 2)
        let adjustedHeight = availableSize.height - (padding * 2)
        let minDimension = min(adjustedWidth, adjustedHeight)
        return max(minDimension / CGFloat(gridSize), 1)
    }
    
    /// Calculates board size from cell size and grid dimensions
    static func boardSize(cellSize: CGFloat, gridSize: Int) -> CGFloat {
        cellSize * CGFloat(gridSize)
    }
    
    /// Calculates safe game area considering device notches and edges
    static func safeGameArea(
        geometry: GeometryProxy,
        verticalPadding: CGFloat = 200
    ) -> CGSize {
        CGSize(
            width: geometry.size.width - geometry.safeAreaInsets.leading - geometry.safeAreaInsets.trailing,
            height: geometry.size.height - verticalPadding
        )
    }
}

// MARK: - Size Preference Key

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - View Extension for Reading Size

extension View {
    /// Reads the view's size and calls the provided closure
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

// MARK: - Game Dimensions

/// Constants for game dimensions that adapt to screen size
struct GameDimensions {
    let screenSize: CGSize
    
    // MARK: - Flappy Square Dimensions
    
    var flappyGameHeight: CGFloat {
        min(screenSize.height * 0.5, 400)
    }
    
    var flappyGameWidth: CGFloat {
        screenSize.width
    }
    
    var flappyPlayerSize: CGFloat {
        min(screenSize.width * 0.08, 30)
    }
    
    var flappyObstacleWidth: CGFloat {
        min(screenSize.width * 0.15, 60)
    }
    
    // MARK: - Gomoku Dimensions
    
    var gomokuBoardSize: CGFloat {
        min(screenSize.width - 32, screenSize.height - 300)
    }
    
    var gomokuCellSize: CGFloat {
        gomokuBoardSize / 15
    }
}

