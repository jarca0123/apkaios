//
//  FlappyViewModel.swift
//  nejskutecnejsiprojekt
//
//  ViewModel for Flappy Square game with haptics and statistics
//

import SwiftUI
import Combine

@MainActor
final class FlappyViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var player: FlappyPlayer
    @Published private(set) var obstacles: [FlappyObstacle] = []
    @Published private(set) var gameState: FlappyGameState = .ready
    @Published private(set) var score: Int = 0
    @Published var gameSize: CGSize = .zero
    
    // Animation states
    @Published var showScorePopup = false
    @Published var scorePopupValue = 0
    
    // MARK: - Configuration
    
    private(set) var config: FlappyGameConfig
    
    // MARK: - Dependencies
    
    private let persistenceService: PersistenceService
    private let hapticsService: HapticsService
    
    // MARK: - Private Properties
    
    private var gameTimer: Timer?
    private var lastObstacleTime: Date = .distantPast
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        persistenceService: PersistenceService = .shared,
        hapticsService: HapticsService = .shared
    ) {
        self.persistenceService = persistenceService
        self.hapticsService = hapticsService
        self.config = .config(for: persistenceService.flappyDifficulty)
        
        // Initialize player at a temporary position
        self.player = FlappyPlayer(
            startPosition: CGPoint(x: 100, y: 200),
            size: config.playerSize
        )
        
        // Listen for difficulty changes
        persistenceService.$flappyDifficulty
            .sink { [weak self] difficulty in
                self?.updateConfig(for: difficulty)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        gameTimer?.invalidate()
    }
    
    // MARK: - Game Setup
    
    /// Sets up the game with the current game area size
    func setupGame(size: CGSize) {
        gameSize = size
        resetGame()
    }
    
    /// Updates configuration for difficulty
    private func updateConfig(for difficulty: GameDifficulty) {
        config = .config(for: difficulty)
    }
    
    // MARK: - Game Actions
    
    /// Handles tap/click input
    func handleTap() {
        switch gameState {
        case .ready:
            startGame()
        case .playing:
            jump()
        case .gameOver:
            resetGame()
            startGame()
        case .paused:
            resumeGame()
        }
    }
    
    /// Makes the player jump
    private func jump() {
        player.jump(strength: config.jumpStrength)
        hapticsService.playJump()
    }
    
    /// Starts the game
    private func startGame() {
        gameState = .playing
        startGameLoop()
    }
    
    /// Pauses the game
    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        gameTimer?.invalidate()
    }
    
    /// Resumes the game
    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        startGameLoop()
    }
    
    /// Resets the game to initial state
    func resetGame() {
        gameTimer?.invalidate()
        
        let startX = gameSize.width * config.playerStartXRatio
        let startY = gameSize.height / 2
        
        player.reset(to: CGPoint(x: startX, y: startY))
        obstacles = []
        score = 0
        gameState = .ready
        lastObstacleTime = .distantPast
    }
    
    // MARK: - Game Loop
    
    private func startGameLoop() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateGame()
            }
        }
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        // Update player physics
        player.applyGravity(config.gravity)
        
        // Update obstacles
        updateObstacles()
        
        // Check scoring
        checkScoring()
        
        // Check collisions
        checkCollisions()
        
        // Spawn new obstacles
        spawnObstacleIfNeeded()
    }
    
    // MARK: - Obstacle Management
    
    private func updateObstacles() {
        // Move obstacles
        for i in obstacles.indices {
            obstacles[i].positionX -= config.obstacleSpeed
        }
        
        // Remove off-screen obstacles
        obstacles.removeAll { $0.positionX < -$0.width }
    }
    
    private func spawnObstacleIfNeeded() {
        let now = Date()
        let timeSinceLastSpawn = now.timeIntervalSince(lastObstacleTime)
        
        let shouldSpawn = obstacles.isEmpty ||
            (timeSinceLastSpawn > config.obstacleSpawnInterval &&
             (obstacles.last?.positionX ?? 0) < gameSize.width * 0.6)
        
        if shouldSpawn {
            spawnObstacle()
            lastObstacleTime = now
        }
    }
    
    private func spawnObstacle() {
        let minGapY: CGFloat = 80
        let maxGapY = gameSize.height - config.gapHeight - 80
        let gapY = CGFloat.random(in: minGapY...max(minGapY, maxGapY))
        
        let obstacle = FlappyObstacle(
            positionX: gameSize.width + config.obstacleWidth / 2,
            gapYPosition: gapY,
            gapHeight: config.gapHeight,
            width: config.obstacleWidth
        )
        
        obstacles.append(obstacle)
    }
    
    // MARK: - Collision Detection
    
    private func checkCollisions() {
        // Check boundary collision
        if CollisionDetector.isOutOfBounds(player: player, gameHeight: gameSize.height) {
            endGame()
            return
        }
        
        // Check obstacle collisions
        for obstacle in obstacles {
            if CollisionDetector.checkCollision(
                player: player,
                obstacle: obstacle,
                gameHeight: gameSize.height
            ) {
                endGame()
                return
            }
        }
    }
    
    // MARK: - Scoring
    
    private func checkScoring() {
        let playerX = player.position.x
        
        for i in obstacles.indices {
            if !obstacles[i].scored && obstacles[i].positionX < playerX {
                obstacles[i].scored = true
                score += 1
                
                // Show score popup
                scorePopupValue = score
                showScorePopup = true
                
                // Hide popup after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.showScorePopup = false
                }
                
                hapticsService.playScore()
            }
        }
    }
    
    // MARK: - Game Over
    
    private func endGame() {
        gameTimer?.invalidate()
        
        let isHighScore = score > persistenceService.flappyBestScore
        
        if isHighScore {
            hapticsService.playNewHighScore()
        } else {
            hapticsService.playGameOver()
        }
        
        // Record stats
        persistenceService.recordFlappyGame(score: score)
        
        gameState = .gameOver(score: score, isHighScore: isHighScore)
    }
    
    // MARK: - Computed Properties
    
    var statusMessage: String {
        switch gameState {
        case .ready:
            return "Klepni pro start"
        case .playing:
            return "Skóre: \(score)"
        case .paused:
            return "Pauza"
        case .gameOver(let finalScore, let isHighScore):
            if isHighScore {
                return "Nové maximum! Skóre: \(finalScore)"
            }
            return "Konec hry! Skóre: \(finalScore)"
        }
    }
    
    var statusColor: Color {
        switch gameState {
        case .ready: return .blue
        case .playing: return .green
        case .paused: return .orange
        case .gameOver(_, let isHighScore):
            return isHighScore ? .yellow : .red
        }
    }
    
    var isPlaying: Bool {
        gameState == .playing
    }
    
    var stats: FlappyStats {
        FlappyStats(
            bestScore: persistenceService.flappyBestScore,
            gamesPlayed: persistenceService.flappyGamesPlayed,
            totalScore: persistenceService.flappyTotalScore,
            averageScore: persistenceService.flappyAverageScore
        )
    }
}

