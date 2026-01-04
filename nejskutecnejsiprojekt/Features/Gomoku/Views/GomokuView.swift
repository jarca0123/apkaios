//
//  GomokuView.swift
//  nejskutecnejsiprojekt
//
//  Main view for the Gomoku game
//

import SwiftUI

struct GomokuView: View {
    @StateObject private var viewModel = GomokuViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var showStats = false
    
    var body: some View {
        GeometryReader { geometry in
            let dimensions = GameDimensions(screenSize: geometry.size)
            let cellSize = dimensions.gomokuCellSize
            let boardSize = dimensions.gomokuBoardSize
            
            VStack(spacing: 16) {
                // Header
                headerView
                
                Spacer()
                
                // Game Board
                ZStack {
                    GridLinesView(cellSize: cellSize, gridSize: viewModel.config.size)
                    GomokuBoardView(viewModel: viewModel, cellSize: cellSize)
                }
                .frame(width: boardSize, height: boardSize)
                .cornerRadius(4)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Spacer()
                
                // Controls
                controlsView
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.adaptiveBackground(for: colorScheme))
        }
        .sheet(isPresented: $showStats) {
            statsSheet
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Gomoku")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 8) {
                // Current player indicator
                if let currentPlayer = viewModel.currentPlayer {
                    Circle()
                        .fill(currentPlayer.color)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
                Text(viewModel.statusText)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.statusColor)
                    .animation(.easeInOut, value: viewModel.statusText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.adaptiveCardBackground(for: colorScheme))
            .cornerRadius(20)
        }
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        HStack(spacing: 16) {
            // Undo button
            Button {
                viewModel.undoLastMove()
            } label: {
                Label("Zpět", systemImage: "arrow.uturn.backward")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(viewModel.canUndo ? Color.orange : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.canUndo)
            
            // Reset button
            Button {
                withAnimation(.spring()) {
                    viewModel.resetGame()
                }
            } label: {
                Label("Nová hra", systemImage: "arrow.clockwise")
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
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.purple)
                    .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Stats Sheet
    
    private var statsSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                GomokuStatsView(stats: viewModel.stats)
                
                Spacer()
                
                Button(role: .destructive) {
                    PersistenceService.shared.resetGomokuStats()
                    showStats = false
                } label: {
                    Label("Resetovat statistiky", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .padding(.bottom, 32)
            }
            .padding()
            .navigationTitle("Statistiky Gomoku")
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

// MARK: - Preview

#Preview {
    GomokuView()
}

