//
//  PersistenceService.swift
//  nejskutecnejsiprojekt
//
//  Handles data persistence using UserDefaults and file caching
//

import Foundation
import SwiftUI

/// Keys for UserDefaults storage
enum PersistenceKey: String {
    // Flappy Square
    case flappyBestScore = "flappy_best_score"
    case flappyGamesPlayed = "flappy_games_played"
    case flappyTotalScore = "flappy_total_score"
    
    // Gomoku
    case gomokuBlackWins = "gomoku_black_wins"
    case gomokuWhiteWins = "gomoku_white_wins"
    case gomokuDraws = "gomoku_draws"
    case gomokuGamesPlayed = "gomoku_games_played"
    
    // Settings
    case selectedTheme = "selected_theme"
    case hapticsEnabled = "haptics_enabled"
    case flappyDifficulty = "flappy_difficulty"
    case gomokuBoardSize = "gomoku_board_size"
    
    // Cache
    case cachedPosts = "cached_posts"
    case cacheTimestamp = "cache_timestamp"
}

/// Game difficulty levels
enum GameDifficulty: String, CaseIterable, Identifiable {
    case easy = "Lehká"
    case medium = "Střední"
    case hard = "Těžká"
    
    var id: String { rawValue }
    
    var flappyGapHeight: CGFloat {
        switch self {
        case .easy: return 180
        case .medium: return 150
        case .hard: return 120
        }
    }
    
    var flappySpeed: CGFloat {
        switch self {
        case .easy: return 2
        case .medium: return 3
        case .hard: return 4
        }
    }
}

/// Main persistence service
final class PersistenceService: ObservableObject {
    
    static let shared = PersistenceService()
    
    private let defaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // MARK: - Flappy Square Stats
    
    @Published var flappyBestScore: Int {
        didSet { defaults.set(flappyBestScore, forKey: PersistenceKey.flappyBestScore.rawValue) }
    }
    
    @Published var flappyGamesPlayed: Int {
        didSet { defaults.set(flappyGamesPlayed, forKey: PersistenceKey.flappyGamesPlayed.rawValue) }
    }
    
    @Published var flappyTotalScore: Int {
        didSet { defaults.set(flappyTotalScore, forKey: PersistenceKey.flappyTotalScore.rawValue) }
    }
    
    var flappyAverageScore: Double {
        guard flappyGamesPlayed > 0 else { return 0 }
        return Double(flappyTotalScore) / Double(flappyGamesPlayed)
    }
    
    // MARK: - Gomoku Stats
    
    @Published var gomokuBlackWins: Int {
        didSet { defaults.set(gomokuBlackWins, forKey: PersistenceKey.gomokuBlackWins.rawValue) }
    }
    
    @Published var gomokuWhiteWins: Int {
        didSet { defaults.set(gomokuWhiteWins, forKey: PersistenceKey.gomokuWhiteWins.rawValue) }
    }
    
    @Published var gomokuDraws: Int {
        didSet { defaults.set(gomokuDraws, forKey: PersistenceKey.gomokuDraws.rawValue) }
    }
    
    @Published var gomokuGamesPlayed: Int {
        didSet { defaults.set(gomokuGamesPlayed, forKey: PersistenceKey.gomokuGamesPlayed.rawValue) }
    }
    
    // MARK: - Settings
    
    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: PersistenceKey.hapticsEnabled.rawValue) }
    }
    
    @Published var flappyDifficulty: GameDifficulty {
        didSet { defaults.set(flappyDifficulty.rawValue, forKey: PersistenceKey.flappyDifficulty.rawValue) }
    }
    
    // MARK: - Initialization
    
    init() {
        // Load Flappy stats
        self.flappyBestScore = defaults.integer(forKey: PersistenceKey.flappyBestScore.rawValue)
        self.flappyGamesPlayed = defaults.integer(forKey: PersistenceKey.flappyGamesPlayed.rawValue)
        self.flappyTotalScore = defaults.integer(forKey: PersistenceKey.flappyTotalScore.rawValue)
        
        // Load Gomoku stats
        self.gomokuBlackWins = defaults.integer(forKey: PersistenceKey.gomokuBlackWins.rawValue)
        self.gomokuWhiteWins = defaults.integer(forKey: PersistenceKey.gomokuWhiteWins.rawValue)
        self.gomokuDraws = defaults.integer(forKey: PersistenceKey.gomokuDraws.rawValue)
        self.gomokuGamesPlayed = defaults.integer(forKey: PersistenceKey.gomokuGamesPlayed.rawValue)
        
        // Load settings
        self.hapticsEnabled = defaults.object(forKey: PersistenceKey.hapticsEnabled.rawValue) as? Bool ?? true
        
        if let difficultyRaw = defaults.string(forKey: PersistenceKey.flappyDifficulty.rawValue),
           let difficulty = GameDifficulty(rawValue: difficultyRaw) {
            self.flappyDifficulty = difficulty
        } else {
            self.flappyDifficulty = .medium
        }
    }
    
    // MARK: - Flappy Square Methods
    
    func recordFlappyGame(score: Int) {
        flappyGamesPlayed += 1
        flappyTotalScore += score
        if score > flappyBestScore {
            flappyBestScore = score
        }
    }
    
    // MARK: - Gomoku Methods
    
    func recordGomokuGame(winner: GomokuWinner) {
        gomokuGamesPlayed += 1
        switch winner {
        case .black:
            gomokuBlackWins += 1
        case .white:
            gomokuWhiteWins += 1
        case .draw:
            gomokuDraws += 1
        }
    }
    
    // MARK: - Posts Cache
    
    private var cacheURL: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("posts_cache.json")
    }
    
    func cachePosts(_ posts: [Post]) {
        guard let url = cacheURL else { return }
        
        do {
            let data = try JSONEncoder().encode(posts)
            try data.write(to: url)
            defaults.set(Date().timeIntervalSince1970, forKey: PersistenceKey.cacheTimestamp.rawValue)
        } catch {
            print("Failed to cache posts: \(error)")
        }
    }
    
    func getCachedPosts() -> [Post]? {
        guard let url = cacheURL,
              fileManager.fileExists(atPath: url.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Post].self, from: data)
        } catch {
            print("Failed to load cached posts: \(error)")
            return nil
        }
    }
    
    var cacheAge: TimeInterval? {
        let timestamp = defaults.double(forKey: PersistenceKey.cacheTimestamp.rawValue)
        guard timestamp > 0 else { return nil }
        return Date().timeIntervalSince1970 - timestamp
    }
    
    var isCacheValid: Bool {
        guard let age = cacheAge else { return false }
        return age < 3600 // Cache valid for 1 hour
    }
    
    // MARK: - Reset
    
    func resetFlappyStats() {
        flappyBestScore = 0
        flappyGamesPlayed = 0
        flappyTotalScore = 0
    }
    
    func resetGomokuStats() {
        gomokuBlackWins = 0
        gomokuWhiteWins = 0
        gomokuDraws = 0
        gomokuGamesPlayed = 0
    }
    
    func resetAllStats() {
        resetFlappyStats()
        resetGomokuStats()
    }
}

/// Enum for Gomoku game results
enum GomokuWinner {
    case black, white, draw
}

// Forward declaration for Post model (defined in Features/Posts/Models)
struct Post: Codable, Identifiable, Equatable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
    
    init(id: Int, userId: Int = 1, title: String, body: String) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
}

