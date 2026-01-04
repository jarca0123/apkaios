//
//  AnimationModifiers.swift
//  nejskutecnejsiprojekt
//
//  Reusable animation modifiers and effects
//

import SwiftUI

// MARK: - Bounce Animation

struct BounceEffect: ViewModifier {
    @State private var isAnimating = false
    var amount: CGFloat = 1.1
    var duration: Double = 0.5
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? amount : 1.0)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Pulse Animation

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    var minOpacity: Double = 0.5
    var duration: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 1.0 : minOpacity)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Shake Animation

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

// MARK: - Fade In Animation

struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    var delay: Double = 0
    var duration: Double = 0.5
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Slide In Animation

struct SlideInModifier: ViewModifier {
    @State private var offset: CGFloat = 50
    @State private var opacity: Double = 0
    var direction: SlideDirection
    var delay: Double = 0
    var duration: Double = 0.5
    
    enum SlideDirection {
        case left, right, top, bottom
        
        var initialOffset: CGSize {
            switch self {
            case .left: return CGSize(width: -50, height: 0)
            case .right: return CGSize(width: 50, height: 0)
            case .top: return CGSize(width: 0, height: -50)
            case .bottom: return CGSize(width: 0, height: 50)
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(opacity == 0 ? direction.initialOffset : .zero)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: duration, dampingFraction: 0.8).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Scale Transition

struct ScaleTransitionModifier: ViewModifier {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay)) {
                    scale = 1
                    opacity = 1
                }
            }
    }
}

// MARK: - Glow Effect

struct GlowEffect: ViewModifier {
    @State private var isGlowing = false
    var color: Color
    var radius: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isGlowing ? 0.8 : 0.3), radius: isGlowing ? radius : radius / 2)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isGlowing)
            .onAppear {
                isGlowing = true
            }
    }
}

// MARK: - View Extensions

extension View {
    func bounceEffect(amount: CGFloat = 1.1, duration: Double = 0.5) -> some View {
        modifier(BounceEffect(amount: amount, duration: duration))
    }
    
    func pulseEffect(minOpacity: Double = 0.5, duration: Double = 1.0) -> some View {
        modifier(PulseEffect(minOpacity: minOpacity, duration: duration))
    }
    
    func shake(amount: CGFloat, animatableData: CGFloat) -> some View {
        modifier(ShakeEffect(amount: amount, animatableData: animatableData))
    }
    
    func fadeIn(delay: Double = 0, duration: Double = 0.5) -> some View {
        modifier(FadeInModifier(delay: delay, duration: duration))
    }
    
    func slideIn(from direction: SlideInModifier.SlideDirection, delay: Double = 0, duration: Double = 0.5) -> some View {
        modifier(SlideInModifier(direction: direction, delay: delay, duration: duration))
    }
    
    func scaleTransition(delay: Double = 0) -> some View {
        modifier(ScaleTransitionModifier(delay: delay))
    }
    
    func glowEffect(color: Color, radius: CGFloat = 10) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Custom Transitions

extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    static var scaleAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.2).combined(with: .opacity)
        )
    }
    
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("Bounce")
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
            .bounceEffect()
        
        Text("Pulse")
            .padding()
            .background(Color.green)
            .cornerRadius(8)
            .pulseEffect()
        
        Text("Glow")
            .padding()
            .background(Color.purple)
            .cornerRadius(8)
            .glowEffect(color: .purple)
        
        Text("Fade In")
            .padding()
            .background(Color.orange)
            .cornerRadius(8)
            .fadeIn(delay: 0.5)
    }
    .padding()
}

