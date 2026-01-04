//
//  ContentView.swift
//  nejskutecnejsiprojekt
//
//  Main content view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PostListView()
                .tabItem {
                    Label("Posts", systemImage: "list.bullet")
                }
                .tag(0)
            
            GomokuView()
                .tabItem {
                    Label("Gomoku", systemImage: "circle.grid.3x3")
                }
                .tag(1)
            
            FlappySquareView()
                .tabItem {
                    Label("Flappy", systemImage: "bird.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Nastavení", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .withTheme()
        .onAppear {
            // Prepare haptics on app launch
            HapticsService.shared.prepareGenerators()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

