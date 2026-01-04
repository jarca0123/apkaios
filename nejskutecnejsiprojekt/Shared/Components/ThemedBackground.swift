//
//  ThemedBackground.swift
//  nejskutecnejsiprojekt
//
//  Reusable themed background components
//

import SwiftUI

// MARK: - Themed Background

struct ThemedBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var style: BackgroundStyle = .gradient
    
    var body: some View {
        switch style {
        case .solid:
            Color.adaptiveBackground(for: colorScheme)
                .ignoresSafeArea()
        case .gradient:
            gradientBackground
                .ignoresSafeArea()
        case .animated:
            animatedBackground
                .ignoresSafeArea()
        }
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(white: 0.08), Color(white: 0.12)]
                : [Color(white: 0.96), Color(white: 0.92)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var animatedBackground: some View {
        GeometryReader { geometry in
            ZStack {
                gradientBackground
                
                // Animated circles
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            colorScheme == .dark
                                ? Color.blue.opacity(0.1)
                                : Color.blue.opacity(0.05)
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .offset(
                            x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -200...200)
                        )
                        .blur(radius: 60)
                }
            }
        }
    }
    
    enum BackgroundStyle {
        case solid
        case gradient
        case animated
    }
}

// MARK: - Card Background

struct CardBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 12
    var shadow: Bool = true
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.adaptiveCardBackground(for: colorScheme))
            .shadow(
                color: shadow ? .black.opacity(colorScheme == .dark ? 0.3 : 0.1) : .clear,
                radius: shadow ? 8 : 0,
                x: 0,
                y: shadow ? 4 : 0
            )
    }
}

// MARK: - View Modifier

struct ThemedBackgroundModifier: ViewModifier {
    var style: ThemedBackground.BackgroundStyle = .gradient
    
    func body(content: Content) -> some View {
        content
            .background(ThemedBackground(style: style))
    }
}

extension View {
    func themedBackground(style: ThemedBackground.BackgroundStyle = .gradient) -> some View {
        modifier(ThemedBackgroundModifier(style: style))
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("Themed Background")
            .font(.largeTitle)
            .padding()
            .background(CardBackground())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .themedBackground(style: .animated)
}

