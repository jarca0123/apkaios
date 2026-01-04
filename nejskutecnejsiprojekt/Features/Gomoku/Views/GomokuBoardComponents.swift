//
//  GomokuBoardComponents.swift
//  nejskutecnejsiprojekt
//
//  Reusable components for the Gomoku board
//

import SwiftUI

// MARK: - Grid Lines

struct GridLinesView: View {
    let cellSize: CGFloat
    let gridSize: Int
    
    var body: some View {
        ZStack {
            // Board background
            Rectangle()
                .fill(Color.gomokuBoard)
            
            // Horizontal lines
            ForEach(0..<gridSize + 1, id: \.self) { index in
                Path { path in
                    let y = CGFloat(index) * cellSize
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: cellSize * CGFloat(gridSize), y: y))
                }
                .stroke(Color.gomokuGrid, lineWidth: 1)
            }
            
            // Vertical lines
            ForEach(0..<gridSize + 1, id: \.self) { index in
                Path { path in
                    let x = CGFloat(index) * cellSize
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: cellSize * CGFloat(gridSize)))
                }
                .stroke(Color.gomokuGrid, lineWidth: 1)
            }
            
        }
    }
}

// MARK: - Stone View

struct StoneView: View {
    let player: Player?
    let cellSize: CGFloat
    let isLastMove: Bool
    let isWinningPosition: Bool
    let onTap: () -> Void
    
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            if let player = player {
                // Stone with shadow
                Circle()
                    .fill(player == .black ? Color.black : Color.white)
                    .frame(width: cellSize * 0.85, height: cellSize * 0.85)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                    .overlay(
                        // 3D effect highlight
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: player == .black
                                        ? [Color.gray.opacity(0.4), Color.clear]
                                        : [Color.white.opacity(0.8), Color.clear],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: cellSize * 0.4
                                )
                            )
                            .frame(width: cellSize * 0.85, height: cellSize * 0.85)
                    )
                    .overlay(
                        // Border for white stones
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: player == .white ? 1 : 0)
                            .frame(width: cellSize * 0.85, height: cellSize * 0.85)
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .overlay(
                        // Last move indicator
                        Circle()
                            .fill(isLastMove ? Color.red : Color.clear)
                            .frame(width: cellSize * 0.2, height: cellSize * 0.2)
                    )
                    .overlay(
                        // Winning position highlight
                        Circle()
                            .stroke(Color.yellow, lineWidth: isWinningPosition ? 3 : 0)
                            .frame(width: cellSize * 0.9, height: cellSize * 0.9)
                            .opacity(isWinningPosition ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isWinningPosition)
                    )
                    .onAppear {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale = 1
                            opacity = 1
                        }
                    }
            }
        }
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Board View

struct GomokuBoardView: View {
    @ObservedObject var viewModel: GomokuViewModel
    let cellSize: CGFloat
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 0), count: viewModel.config.size),
            spacing: 0
        ) {
            ForEach(0..<viewModel.config.totalCells, id: \.self) { index in
                let position = BoardPosition.fromIndex(index, boardSize: viewModel.config.size)
                
                StoneView(
                    player: viewModel.board[position.row][position.col],
                    cellSize: cellSize,
                    isLastMove: viewModel.lastMove == position,
                    isWinningPosition: viewModel.winningPositions.contains(position),
                    onTap: {
                        viewModel.placeStone(at: position)
                    }
                )
            }
        }
    }
}

// MARK: - Stats Display

struct GomokuStatsView: View {
    let stats: GomokuStats
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Statistiky")
                .font(.headline)
            
            HStack(spacing: 20) {
                statItem(title: "Černý", value: "\(stats.blackWins)", color: .primary)
                statItem(title: "Bílý", value: "\(stats.whiteWins)", color: .red)
                statItem(title: "Remízy", value: "\(stats.draws)", color: .orange)
            }
            
            Text("Celkem her: \(stats.totalGames)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.adaptiveCardBackground(for: colorScheme))
        .cornerRadius(12)
    }
    
    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        GridLinesView(cellSize: 25, gridSize: 15)
            .frame(width: 375, height: 375)
    }
}

