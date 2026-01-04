//
//  HapticsService.swift
//  nejskutecnejsiprojekt
//
//  Provides haptic feedback for game events
//

import UIKit
import Combine
/// Service for haptic feedback
final class HapticsService {
    
    static let shared = HapticsService()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private var isEnabled: Bool {
        PersistenceService.shared.hapticsEnabled
    }
    
    private init() {
        // Prepare generators for faster response
        prepareGenerators()
    }
    
    /// Prepares all haptic generators
    func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Game Events
    
    /// Light tap - for UI interactions, placing stones
    func playTap() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
    }
    
    /// Medium impact - for jumps in Flappy
    func playJump() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
    }
    
    /// Success notification - for winning
    func playSuccess() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Error notification - for game over
    func playGameOver() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
    
    /// Warning notification - for near misses or alerts
    func playWarning() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }
    
    /// Selection changed - for scrolling through options
    func playSelection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    /// Heavy impact - for collisions
    func playCollision() {
        guard isEnabled else { return }
        heavyGenerator.impactOccurred()
    }
    
    /// Score point feedback
    func playScore() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.7)
    }
    
    /// New high score celebration
    func playNewHighScore() {
        guard isEnabled else { return }
        
        // Pattern: success + delay + success
        notificationGenerator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.notificationGenerator.notificationOccurred(.success)
        }
    }
}

