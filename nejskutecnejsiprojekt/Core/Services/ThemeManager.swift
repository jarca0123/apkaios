//
//  ThemeManager.swift
//  nejskutecnejsiprojekt
//
//  Manages app-wide theme (Light/Dark/System)
//

import SwiftUI
import Combine
/// Available app themes
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Systém"
    case light = "Světlý"
    case dark = "Tmavý"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

/// Observable theme manager
final class ThemeManager: ObservableObject {
    
    static let shared = ThemeManager()
    
    @AppStorage("selected_theme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    var selectedTheme: AppTheme {
        get { AppTheme(rawValue: selectedThemeRaw) ?? .system }
        set {
            selectedThemeRaw = newValue.rawValue
            objectWillChange.send()
        }
    }
    
    var colorScheme: ColorScheme? {
        selectedTheme.colorScheme
    }
}

// MARK: - Theme Colors Extension

extension Color {
    
    // MARK: - Game Colors
    
    static let gameBackground = Color("GameBackground", bundle: nil)
    static let cardBackground = Color("CardBackground", bundle: nil)
    
    // MARK: - Gomoku Colors
    
    static let gomokuBoard = Color.orange
    static let gomokuBlack = Color.black
    static let gomokuWhite = Color.white
    static let gomokuGrid = Color.black.opacity(0.8)
    
    // MARK: - Flappy Colors
    
    static let flappySky = Color.blue.opacity(0.3)
    static let flappyPlayer = Color.red
    static let flappyObstacle = Color.green
    
    // MARK: - Adaptive Colors
    
    static func adaptiveBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.95)
    }
    
    static func adaptiveCardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(white: 0.15) : Color.white
    }
    
    static func adaptiveText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    static func adaptiveSecondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.gray : Color.secondary
    }
}

// MARK: - View Modifier for Theme

struct ThemeModifier: ViewModifier {
    @ObservedObject var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
    }
}

extension View {
    func withTheme() -> some View {
        modifier(ThemeModifier())
    }
}

