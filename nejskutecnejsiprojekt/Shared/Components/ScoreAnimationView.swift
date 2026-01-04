//
//  ScoreAnimationView.swift
//  nejskutecnejsiprojekt
//
//  Animated score display components
//

import SwiftUI

// MARK: - Animated Score Counter

struct AnimatedScoreCounter: View {
    let score: Int
    var prefix: String = ""
    var font: Font = .title
    var color: Color = .primary
    
    @State private var displayedScore: Int = 0
    
    var body: some View {
        Text("\(prefix)\(displayedScore)")
            .font(font)
            .fontWeight(.bold)
            .foregroundColor(color)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: displayedScore)
            .onChange(of: score) { _, newValue in
                displayedScore = newValue
            }
            .onAppear {
                displayedScore = score
            }
    }
}

// MARK: - Score Popup

struct ScorePopup: View {
    let value: Int
    var color: Color = .yellow
    @Binding var isVisible: Bool
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Text("+\(value)")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            .scaleEffect(scale)
            .offset(y: offset)
            .opacity(opacity)
            .onChange(of: isVisible) { _, newValue in
                if newValue {
                    animateIn()
                }
            }
            .onAppear {
                if isVisible {
                    animateIn()
                }
            }
    }
    
    private func animateIn() {
        // Reset
        offset = 0
        opacity = 1
        scale = 0.5
        
        // Animate in
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            scale = 1.2
        }
        
        // Float up and fade out
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            offset = -40
            opacity = 0
            scale = 1
        }
    }
}

// MARK: - High Score Celebration

struct HighScoreCelebration: View {
    @Binding var isShowing: Bool
    let score: Int
    
    @State private var particleSystem = ParticleSystem()
    
    var body: some View {
        ZStack {
            if isShowing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    // Trophy icon
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .scaleTransition(delay: 0.1)
                    
                    // Title
                    Text("Nový rekord!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .scaleTransition(delay: 0.2)
                    
                    // Score
                    Text("\(score)")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundColor(.yellow)
                        .scaleTransition(delay: 0.3)
                    
                    // Dismiss button
                    Button {
                        withAnimation(.spring()) {
                            isShowing = false
                        }
                    } label: {
                        Text("Výborně!")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Color.yellow)
                            .cornerRadius(25)
                    }
                    .scaleTransition(delay: 0.4)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.7))
                )
                .transition(.scaleAndFade)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isShowing)
    }
}

// MARK: - Particle System (Simplified)

struct ParticleSystem {
    var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var color: Color
        var scale: CGFloat
        var opacity: Double
    }
}

// MARK: - Game Over Overlay

struct GameOverOverlay: View {
    let score: Int
    let isHighScore: Bool
    var onRestart: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if isHighScore {
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .glowEffect(color: .yellow, radius: 15)
                }
                
                Text(isHighScore ? "Nový rekord!" : "Konec hry")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Skóre: \(score)")
                    .font(.title)
                    .foregroundColor(isHighScore ? .yellow : .white)
                
                Button {
                    onRestart()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Hrát znovu")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(.top, 10)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        AnimatedScoreCounter(score: 42, prefix: "Score: ", color: .blue)
        
        ScorePopup(value: 10, isVisible: .constant(true))
    }
    .padding()
}

