//
//  Color+Theme.swift
//  nejskutecnejsiprojekt
//
//  Color extensions for theming
//

import SwiftUI

extension Color {
    
    // MARK: - Gradient Helpers
    
    static func gameGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color(white: 0.1), Color(white: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    static var flappySkyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.4),
                Color.cyan.opacity(0.3),
                Color.blue.opacity(0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Status Colors
    
    static let successGreen = Color.green
    static let errorRed = Color.red
    static let warningOrange = Color.orange
    static let infoBlue = Color.blue
    
    // MARK: - Player Colors
    
    enum PlayerColor {
        case black
        case white
        
        var color: Color {
            switch self {
            case .black: return .black
            case .white: return .white
            }
        }
        
        var shadow: Color {
            switch self {
            case .black: return .gray.opacity(0.5)
            case .white: return .gray.opacity(0.3)
            }
        }
    }
}

// MARK: - Semantic Colors

extension Color {
    
    /// Primary action color
    static var primaryAction: Color {
        .blue
    }
    
    /// Secondary action color
    static var secondaryAction: Color {
        .gray
    }
    
    /// Destructive action color
    static var destructiveAction: Color {
        .red
    }
    
    /// Success state color
    static var success: Color {
        .green
    }
    
    /// Warning state color  
    static var warning: Color {
        .orange
    }
}

