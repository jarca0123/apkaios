//
//  FlappySquareView.swift
//  nejskutecnejsiprojekt
//
//  Main view for the Flappy Square game with GeometryReader
//

import SwiftUI

struct FlappySquareView: View {
    @StateObject private var viewModel = FlappyViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var showStats = false
    
    var body: some View {
        GeometryReader { geometry in
            let gameHeight = min(geometry.size.height * 0.55, 450)
            let gameWidth = geometry.size.width - 32
            
            VStack(spacing: 16) {
                // Header
                headerView
                
                // Game Area
                gameArea(width: gameWidth, height: gameHeight)
                
                // Controls & Info
                controlsView
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.adaptiveBackground(for: colorScheme))
            .onAppear {
                viewModel.setupGame(size: CGSize(width: gameWidth, height: gameHeight))
            }
            .onChange(of: geometry.size) { _, newSize in
                let newGameHeight = min(newSize.height * 0.55, 450)
                let newGameWidth = newSize.width - 32
                viewModel.setupGame(size: CGSize(width: newGameWidth, height: newGameHeight))
            }
        }
        .sheet(isPresented: $showStats) {
            statsSheet
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Flappy Square")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Best score badge
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.stats.bestScore)")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.adaptiveCardBackground(for: colorScheme))
                .cornerRadius(16)
            }
            
            // Status message
            Text(viewModel.statusMessage)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(viewModel.statusColor)
                .animation(.easeInOut, value: viewModel.statusMessage)
        }
    }
    
    // MARK: - Game Area
    
    private func gameArea(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Sky background
            skyBackground
            
            // Ground
            groundView(width: width, height: height)
            
            // Obstacles
            ObstaclesContainerView(
                obstacles: viewModel.obstacles,
                gameHeight: height
            )
            
            // Player
            playerView
            
            // Score popup
            if viewModel.showScorePopup {
                scorePopup
            }
            
            // Game over overlay
            if case .gameOver = viewModel.gameState {
                gameOverOverlay
            }
            
            // Ready overlay
            if viewModel.gameState == .ready {
                readyOverlay
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.handleTap()
        }
    }
    
    // MARK: - Background Elements
    
    private var skyBackground: some View {
        LinearGradient(
            colors: [
                Color.cyan.opacity(0.6),
                Color.blue.opacity(0.4),
                Color.blue.opacity(0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func groundView(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.brown, Color.brown.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 2)
        }
    }
    
    // MARK: - Player
    
    private var playerView: some View {
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.3))
                .frame(width: viewModel.player.size, height: viewModel.player.size)
                .offset(x: 2, y: 2)
            
            // Player square
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color.red, Color.red.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: viewModel.player.size, height: viewModel.player.size)
            
            // Eye
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .offset(x: 5, y: -3)
            
            Circle()
                .fill(Color.black)
                .frame(width: 5, height: 5)
                .offset(x: 6, y: -3)
        }
        .position(viewModel.player.position)
        .rotationEffect(.degrees(Double(viewModel.player.velocity) * 2))
        .animation(.easeOut(duration: 0.1), value: viewModel.player.velocity)
    }
    
    // MARK: - Overlays
    
    private var scorePopup: some View {
        Text("+1")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.yellow)
            .shadow(color: .black, radius: 2, x: 1, y: 1)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.showScorePopup)
    }
    
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
            
            VStack(spacing: 16) {
                if case .gameOver(_, let isHighScore) = viewModel.gameState, isHighScore {
                    Text("🎉 Nový rekord! 🎉")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                
                Text("Klepni pro novou hru")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(Color.black.opacity(0.6))
            .cornerRadius(16)
        }
        .transition(.opacity)
    }
    
    private var readyOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 48))
                .foregroundColor(.white)
            
            Text("Klepni pro start")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(24)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        HStack(spacing: 16) {
            // Reset button
            Button {
                viewModel.resetGame()
            } label: {
                Label("Reset", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            // Stats button
            Button {
                showStats = true
            } label: {
                Label("Statistiky", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Stats Sheet
    
    private var statsSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                FlappyStatsView(stats: viewModel.stats)
                
                Spacer()
                
                Button(role: .destructive) {
                    PersistenceService.shared.resetFlappyStats()
                    showStats = false
                } label: {
                    Label("Resetovat statistiky", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .padding(.bottom, 32)
            }
            .padding()
            .navigationTitle("Statistiky Flappy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hotovo") {
                        showStats = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Stats View

struct FlappyStatsView: View {
    let stats: FlappyStats
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Statistiky")
                .font(.headline)
            
            HStack(spacing: 24) {
                statItem(title: "Nejlepší", value: "\(stats.bestScore)", icon: "trophy.fill", color: .yellow)
                statItem(title: "Průměr", value: String(format: "%.1f", stats.averageScore), icon: "chart.line.uptrend.xyaxis", color: .blue)
                statItem(title: "Her", value: "\(stats.gamesPlayed)", icon: "gamecontroller.fill", color: .green)
            }
        }
        .padding()
        .background(Color.adaptiveCardBackground(for: colorScheme))
        .cornerRadius(12)
    }
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    FlappySquareView()
}

