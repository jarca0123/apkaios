//  ContentView.swift
import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        TabView {
            PostListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Posts")
                }
            
            GomokuView()
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("Gomoku")
                }
            
            FlappySquareView()
                .tabItem {
                    Image(systemName: "bird.fill")
                    Text("Flappy Square")
                }
        }
    }
}

// MARK: - API Example with Pull-to-Refresh
struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    
    func fetchPosts() {
        isLoading = true
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        self.posts = try JSONDecoder().decode([Post].self, from: data)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
        }.resume()
    }
}

struct PostListView: View {
    @StateObject private var viewModel = PostViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView("Loading...")
                } else {
                    List(viewModel.posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            VStack(alignment: .leading) {
                                Text(post.title)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Text(post.body)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .refreshable {
                        viewModel.fetchPosts()
                    }
                }
            }
            .navigationTitle("Posts")
            .onAppear {
                if viewModel.posts.isEmpty {
                    viewModel.fetchPosts()
                }
            }
        }
    }
}

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(post.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(post.body)
                    .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detail")
    }
}

// MARK: - Gomoku Game
struct GomokuView: View {
    @StateObject private var gameModel = GomokuGameModel()
    
    var body: some View {
        VStack {
            Text("Gomoku Game")
                .font(.largeTitle)
                .padding()
            
            Text(gameModel.gameStatus)
                .font(.title2)
                .foregroundColor(gameModel.statusColor)
                .padding()
            
            GeometryReader { geometry in
                let cellSize = min(
                    geometry.size.width,
                    geometry.size.height - 200
                ) / 15
                
                let boardSize = cellSize * 15
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        ZStack {
                            GridLines(cellSize: cellSize)
                            GomokuBoard(gameModel: gameModel, cellSize: cellSize)
                        }
                        .frame(width: boardSize, height: boardSize)
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            Button(action: gameModel.resetGame) {
                Text("Reset Game")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

class GomokuGameModel: ObservableObject {
    @Published var board: [[Player?]] = Array(repeating: Array(repeating: nil, count: 15), count: 15)
    @Published var currentPlayer: Player = .black
    @Published var gameStatus: String = "Black's Turn"
    @Published var statusColor: Color = .black
    @Published var gameOver: Bool = false
    
    func placeStone(row: Int, col: Int) {
        guard !gameOver && board[row][col] == nil else { return }
        
        board[row][col] = currentPlayer
        
        if checkWin(row: row, col: col) {
            gameStatus = "\(currentPlayer) Wins!"
            statusColor = currentPlayer == .black ? .black : .red
            gameOver = true
        } else if isBoardFull() {
            gameStatus = "Draw!"
            statusColor = .orange
            gameOver = true
        } else {
            currentPlayer = currentPlayer == .black ? .white : .black
            gameStatus = "\(currentPlayer)'s Turn"
            statusColor = currentPlayer == .black ? .black : .red
        }
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: 15), count: 15)
        currentPlayer = .black
        gameStatus = "Black's Turn"
        statusColor = .black
        gameOver = false
    }
    
    private func checkWin(row: Int, col: Int) -> Bool {
        let player = board[row][col]!
        let directions: [(Int, Int)] = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dx, dy) in directions {
            var count = 1
            
            var r = row + dx
            var c = col + dy
            while r >= 0 && r < 15 && c >= 0 && c < 15 && board[r][c] == player {
                count += 1
                r += dx
                c += dy
            }
            
            r = row - dx
            c = col - dy
            while r >= 0 && r < 15 && c >= 0 && c < 15 && board[r][c] == player {
                count += 1
                r -= dx
                c -= dy
            }
            
            if count >= 5 {
                return true
            }
        }
        return false
    }
    
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
}

struct GridLines: View {
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.orange)
            
            ForEach(0..<16) { index in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: CGFloat(index) * cellSize))
                    path.addLine(to: CGPoint(x: cellSize * 15, y: CGFloat(index) * cellSize))
                }
                .stroke(Color.black, lineWidth: 1)
                
                Path { path in
                    path.move(to: CGPoint(x: CGFloat(index) * cellSize, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(index) * cellSize, y: cellSize * 15))
                }
                .stroke(Color.black, lineWidth: 1)
            }
        }
    }
}

struct GomokuBoard: View {
    @ObservedObject var gameModel: GomokuGameModel
    let cellSize: CGFloat
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 0), count: 15), spacing: 0) {
            ForEach(0..<15*15, id: \.self) { index in
                let row = index / 15
                let col = index % 15
                CellView(
                    player: gameModel.board[row][col],
                    cellSize: cellSize
                ) {
                    gameModel.placeStone(row: row, col: col)
                }
            }
        }
    }
}

struct CellView: View {
    let player: Player?
    let cellSize: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Circle()
            .fill(player == .black ? Color.black : player == .white ? Color.white : Color.clear)
            .frame(width: cellSize * 0.8, height: cellSize * 0.8)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .padding(cellSize * 0.1)
    }
}

enum Player {
    case black, white
}

// MARK: - Flappy Square Game
struct FlappySquareView: View {
    @StateObject private var gameModel = FlappySquareModel()
    
    var body: some View {
        VStack {
            Text("Flappy Square")
                .font(.largeTitle)
                .padding()
            
            Text(gameModel.gameState_message)
                .font(.title2)
                .foregroundColor(gameModel.gameState_color)
                .padding()
            
            ZStack {
                // Background
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(height: 400)
                
                // Obstacles
                ForEach(gameModel.obstacles, id: \.id) { obstacle in
                    ObstacleView(obstacle: obstacle)
                }
                
                // Player
                Rectangle()
                    .fill(Color.red)
                    .frame(width: gameModel.playerSize, height: gameModel.playerSize)
                    .position(gameModel.playerPosition)
            }
            .frame(height: 400)
            .onTapGesture {
                gameModel.flap()
            }
        }
        .onAppear {
            gameModel.setupGame()
        }
    }
}

class FlappySquareModel: ObservableObject {
    // Game state
    @Published var playerPosition: CGPoint = CGPoint(x: 100, y: 200)
    @Published var playerVelocity: CGFloat = 0
    @Published var obstacles: [Obstacle] = []
    @Published var gameState: GameState = .ready
    @Published var score: Int = 0
    
    // Game constants
    let playerSize: CGFloat = 30
    let gravity: CGFloat = 0.6
    let jumpStrength: CGFloat = -8
    let obstacleWidth: CGFloat = 60
    let gapHeight: CGFloat = 150
    let obstacleSpeed: CGFloat = 3
    let gameHeight: CGFloat = 400
    
    private var timer: Timer?
    private var lastObstacleTime: TimeInterval = 0
    
    func setupGame() {
        playerPosition = CGPoint(x: 100, y: 200)
        playerVelocity = 0
        obstacles = []
        score = 0
        gameState = .ready
    }
    
    func flap() {
        if gameState == .playing {
            playerVelocity = jumpStrength
        } else if gameState == .ready {
            startGame()
        } else if gameState == .gameOver {
            resetGame()
            startGame()
        }
    }
    
    private func startGame() {
        if gameState == .ready || gameState == .gameOver {
            if gameState == .gameOver {
                resetGame()
            }
            gameState = .playing
            startTimer()
        }
    }
    
    func resetGame() {
        playerPosition = CGPoint(x: 100, y: 200)
        playerVelocity = 0
        obstacles = []
        score = 0
        gameState = .ready
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.updateGame()
        }
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        // Update player position
        playerVelocity += gravity
        playerPosition.y += playerVelocity
        
        // Update obstacles
        for i in obstacles.indices {
            obstacles[i].position.x -= obstacleSpeed
        }
        
        // Remove off-screen obstacles
        obstacles.removeAll { $0.position.x < -obstacleWidth }
        
        // Add new obstacles
        let currentTime = Date().timeIntervalSince1970
        if obstacles.isEmpty ||
           (obstacles.last?.position.x ?? 0 < 200 &&
            currentTime - lastObstacleTime > 1.5) {
            addObstacle()
            lastObstacleTime = currentTime
        }
        
        // Update score
        for i in obstacles.indices {
            if !obstacles[i].scored && obstacles[i].position.x < 100 {
                obstacles[i].scored = true
                score += 1
            }
        }
        
        // Check collisions
        checkCollisions()
        
        // Check boundaries
        if playerPosition.y < playerSize/2 || playerPosition.y > gameHeight - playerSize/2 {
            endGame()
        }
    }
    
    private func addObstacle() {
        let gapPosition = CGFloat.random(in: 80...(gameHeight - gapHeight - 80))
        obstacles.append(Obstacle(
            id: UUID(),
            position: CGPoint(x: 400, y: 0),
            gapPosition: gapPosition,
            gapHeight: gapHeight,
            width: obstacleWidth
        ))
    }
    
    private func checkCollisions() {
        for obstacle in obstacles {
            // Check if we're at the obstacle's x position
            if obstacle.position.x > 70 && obstacle.position.x < 130 {
                // Check collision with top obstacle
                if playerPosition.y - playerSize/2 < obstacle.gapPosition {
                    endGame()
                    return
                }
                
                // Check collision with bottom obstacle
                if playerPosition.y + playerSize/2 > obstacle.gapPosition + obstacle.gapHeight {
                    endGame()
                    return
                }
            }
        }
    }
    
    private func endGame() {
        gameState = .gameOver
        timer?.invalidate()
    }
    
    var gameState_message: String {
        switch gameState {
        case .ready: return "Tap to Start"
        case .playing: return "Score: \(score)"
        case .gameOver: return "Game Over! Score: \(score) - Tap to Play Again"
        }
    }
    
    var gameState_color: Color {
        switch gameState {
        case .ready: return .blue
        case .playing: return .green
        case .gameOver: return .red
        }
    }
}

struct Obstacle: Identifiable {
    let id: UUID
    var position: CGPoint
    let gapPosition: CGFloat
    let gapHeight: CGFloat
    let width: CGFloat
    var scored: Bool = false
}

struct ObstacleView: View {
    let obstacle: Obstacle
    
    var body: some View {
        ZStack {
            // Top obstacle (green square)
            Rectangle()
                .fill(Color.green)
                .frame(width: obstacle.width, height: obstacle.gapPosition)
                .position(
                    x: obstacle.position.x,
                    y: obstacle.gapPosition / 2
                )
            
            // Bottom obstacle (green square)
            Rectangle()
                .fill(Color.green)
                .frame(width: obstacle.width, height: 400 - (obstacle.gapPosition + obstacle.gapHeight))
                .position(
                    x: obstacle.position.x,
                    y: obstacle.gapPosition + obstacle.gapHeight +
                       (400 - (obstacle.gapPosition + obstacle.gapHeight)) / 2
                )
        }
    }
}

enum GameState {
    case ready, playing, gameOver
}
