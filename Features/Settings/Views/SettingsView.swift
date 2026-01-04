//
//  SettingsView.swift
//  nejskutecnejsiprojekt
//
//  Settings screen with theme, difficulty, and statistics
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                // Appearance Section
                appearanceSection
                
                // Game Settings Section
                gameSettingsSection
                
                // Statistics Section
                statisticsSection
                
                // Data Management Section
                dataManagementSection
                
                // About Section
                aboutSection
            }
            .navigationTitle("Nastavení")
            .alert("Resetovat statistiky?", isPresented: $viewModel.showResetConfirmation) {
                Button("Zrušit", role: .cancel) { }
                Button("Resetovat", role: .destructive) {
                    viewModel.performReset()
                }
            } message: {
                Text(viewModel.resetType.message)
            }
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        Section {
            // Theme picker
            Picker("Vzhled", selection: $viewModel.selectedTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Label(theme.rawValue, systemImage: theme.icon)
                        .tag(theme)
                }
            }
            
            // Haptics toggle
            Toggle(isOn: $viewModel.hapticsEnabled) {
                Label("Haptická odezva", systemImage: "iphone.radiowaves.left.and.right")
            }
        } header: {
            Text("Vzhled a chování")
        } footer: {
            Text("Haptická odezva poskytuje vibrační zpětnou vazbu při hraní.")
        }
    }
    
    // MARK: - Game Settings Section
    
    private var gameSettingsSection: some View {
        Section {
            // Flappy difficulty
            Picker("Obtížnost Flappy", selection: $viewModel.flappyDifficulty) {
                ForEach(GameDifficulty.allCases) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            
            // Difficulty description
            VStack(alignment: .leading, spacing: 4) {
                Text(difficultyDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        } header: {
            Text("Nastavení her")
        }
    }
    
    private var difficultyDescription: String {
        switch viewModel.flappyDifficulty {
        case .easy:
            return "Větší mezera mezi překážkami, pomalejší rychlost"
        case .medium:
            return "Vyvážená obtížnost pro běžné hraní"
        case .hard:
            return "Menší mezera, vyšší rychlost - pro zkušené hráče"
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        Section {
            // Flappy Stats
            NavigationLink {
                FlappyStatsDetailView(stats: viewModel.flappyStats)
            } label: {
                HStack {
                    Label("Flappy Square", systemImage: "bird.fill")
                    Spacer()
                    Text("Nejlepší: \(viewModel.flappyStats.bestScore)")
                        .foregroundColor(.secondary)
                }
            }
            
            // Gomoku Stats
            NavigationLink {
                GomokuStatsDetailView(stats: viewModel.gomokuStats)
            } label: {
                HStack {
                    Label("Gomoku", systemImage: "circle.grid.3x3.fill")
                    Spacer()
                    Text("\(viewModel.gomokuStats.totalGames) her")
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Statistiky")
        }
    }
    
    // MARK: - Data Management Section
    
    private var dataManagementSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.confirmReset(type: .flappy)
            } label: {
                Label("Resetovat Flappy Square", systemImage: "trash")
            }
            
            Button(role: .destructive) {
                viewModel.confirmReset(type: .gomoku)
            } label: {
                Label("Resetovat Gomoku", systemImage: "trash")
            }
            
            Button(role: .destructive) {
                viewModel.confirmReset(type: .all)
            } label: {
                Label("Resetovat vše", systemImage: "trash.fill")
            }
        } header: {
            Text("Správa dat")
        } footer: {
            Text("Resetování smaže herní statistiky. Nastavení zůstanou zachována.")
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Verze")
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Vytvořeno")
                Spacer()
                Text("SwiftUI + MVVM")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("O aplikaci")
        }
    }
}

// MARK: - Flappy Stats Detail View

struct FlappyStatsDetailView: View {
    let stats: FlappyStats
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            Section {
                StatRow(title: "Nejlepší skóre", value: "\(stats.bestScore)", icon: "trophy.fill", color: .yellow)
                StatRow(title: "Celkem her", value: "\(stats.gamesPlayed)", icon: "gamecontroller.fill", color: .blue)
                StatRow(title: "Průměrné skóre", value: String(format: "%.1f", stats.averageScore), icon: "chart.line.uptrend.xyaxis", color: .green)
                StatRow(title: "Celkové skóre", value: "\(stats.totalScore)", icon: "sum", color: .purple)
            }
        }
        .navigationTitle("Flappy Square")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Gomoku Stats Detail View

struct GomokuStatsDetailView: View {
    let stats: GomokuStats
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            Section("Výsledky") {
                StatRow(title: "Výhry černého", value: "\(stats.blackWins)", icon: "circle.fill", color: .primary)
                StatRow(title: "Výhry bílého", value: "\(stats.whiteWins)", icon: "circle", color: .gray)
                StatRow(title: "Remízy", value: "\(stats.draws)", icon: "equal.circle.fill", color: .orange)
            }
            
            Section("Celkově") {
                StatRow(title: "Celkem her", value: "\(stats.totalGames)", icon: "gamecontroller.fill", color: .blue)
                
                if stats.totalGames > 0 {
                    StatRow(
                        title: "Úspěšnost černého",
                        value: String(format: "%.1f%%", stats.blackWinRate),
                        icon: "percent",
                        color: .green
                    )
                    StatRow(
                        title: "Úspěšnost bílého",
                        value: String(format: "%.1f%%", stats.whiteWinRate),
                        icon: "percent",
                        color: .red
                    )
                }
            }
        }
        .navigationTitle("Gomoku")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stat Row Component

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(color)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

