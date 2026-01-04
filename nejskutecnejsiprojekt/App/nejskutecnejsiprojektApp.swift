//
//  nejskutecnejsiprojektApp.swift
//  nejskutecnejsiprojekt
//
//  Created by Jaroslav Bělák on 19.10.2025.
//

import SwiftUI

@main
struct nejskutecnejsiprojektApp: App {
    
    // Initialize services at app launch
    init() {
        // Pre-warm services
        _ = PersistenceService.shared
        _ = ThemeManager.shared
        _ = HapticsService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

