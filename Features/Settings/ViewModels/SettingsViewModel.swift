//
//  SettingsViewModel.swift
//  nejskutecnejsiprojekt
//
//  ViewModel for Settings screen
//

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    private let themeManager: ThemeManager
    private let persistenceService: PersistenceService
    private let hapticsService: HapticsService
    
    // MARK: - Published Properties
    
    @Published var selectedTheme: AppTheme {
        didSet {
            themeManager.selectedTheme = selectedTheme
            hapticsService.playSelection()
        }
    }
    
    @Published var hapticsEnabled: Bool {
        didSet {
            persistenceService.hapticsEnabled = hapticsEnabled
            if hapticsEnabled {
                hapticsService.playTap()
            }
        }
    }
    
    @Published var flappyDifficulty: GameDifficulty {
        didSet {
            persistenceService.flappyDifficulty = flappyDifficulty
            hapticsService.playSelection()
        }
    }
    
    @Published var showResetConfirmation = false
    @Published var resetType: ResetType = .all
    
    // MARK: - Initialization
    
    init(
        themeManager: ThemeManager = .shared,
        persistenceService: PersistenceService = .shared,
        hapticsService: HapticsService = .shared
    ) {
        self.themeManager = themeManager
        self.persistenceService = persistenceService
        self.hapticsService = hapticsService
        
        // Load initial values
        self.selectedTheme = themeManager.selectedTheme
        self.hapticsEnabled = persistenceService.hapticsEnabled
        self.flappyDifficulty = persistenceService.flappyDifficulty
    }
    
    // MARK: - Statistics
    
    var flappyStats: FlappyStats {
        FlappyStats(
            bestScore: persistenceService.flappyBestScore,
            gamesPlayed: persistenceService.flappyGamesPlayed,
            totalScore: persistenceService.flappyTotalScore,
            averageScore: persistenceService.flappyAverageScore
        )
    }
    
    var gomokuStats: GomokuStats {
        GomokuStats(
            blackWins: persistenceService.gomokuBlackWins,
            whiteWins: persistenceService.gomokuWhiteWins,
            draws: persistenceService.gomokuDraws,
            totalGames: persistenceService.gomokuGamesPlayed
        )
    }
    
    // MARK: - Actions
    
    func confirmReset(type: ResetType) {
        resetType = type
        showResetConfirmation = true
    }
    
    func performReset() {
        switch resetType {
        case .flappy:
            persistenceService.resetFlappyStats()
        case .gomoku:
            persistenceService.resetGomokuStats()
        case .all:
            persistenceService.resetAllStats()
        }
        hapticsService.playWarning()
        objectWillChange.send()
    }
    
    // MARK: - App Info
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Reset Type

enum ResetType: String, Identifiable {
    case flappy = "Flappy Square"
    case gomoku = "Gomoku"
    case all = "Všechny"
    
    var id: String { rawValue }
    
    var message: String {
        switch self {
        case .flappy:
            return "Toto smaže všechny statistiky Flappy Square včetně nejlepšího skóre."
        case .gomoku:
            return "Toto smaže všechny statistiky Gomoku včetně historie výher."
        case .all:
            return "Toto smaže všechny herní statistiky. Tuto akci nelze vrátit zpět."
        }
    }
}

