//
//  CircularPulseView.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import SwiftUI

struct CircularPulseView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var continuousTime: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(0..<15) { index in
                OrganicCircleShape(
                    phase: audioRecorder.phase * 0.2 + Double(index) * 0.3,
                    index: index,
                    audioLevel: audioRecorder.audioLevel,
                    continuousTime: continuousTime
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.7, green: 0.9, blue: 0.2).opacity(0.8),
                            Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.8),
                            Color(red: 0.2, green: 0.8, blue: 0.6).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(
                    width: 120 + CGFloat(index) * 2 + audioRecorder.audioLevel * 100,
                    height: 120 + CGFloat(index) * 2 + audioRecorder.audioLevel * 100
                )
                .animation(.linear(duration: 0.016), value: audioRecorder.audioLevel)
            }
        }
        .onAppear {
            startContinuousTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startContinuousTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            continuousTime += 0.016
        }
    }
}

// MARK: - Organic Circle Shape
struct OrganicCircleShape: Shape {
    var phase: Double
    var index: Int
    var audioLevel: CGFloat
    var continuousTime: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        
        // Continuously evolving parameters based on time
        let timeScale = continuousTime * 0.1  // Slow evolution
        
        // Use fixed integer frequencies to ensure circles close properly
        // Only vary the phase offsets and amplitudes for smooth continuous evolution
        let freq1 = 2.0
        let freq2 = 4.0
        let freq3 = 6.0
        let freq4 = 3.0
        
        // Smoothly varying phase offsets - this creates the evolving chaos
        let phaseOffset1 = sin(timeScale * 0.5) * 2.0
        let phaseOffset2 = sin(timeScale * 0.6) * 2.5
        let phaseOffset3 = sin(timeScale * 0.4) * 1.8
        let phaseOffset4 = sin(timeScale * 0.55) * 2.2
        
        // Smoothly varying amplitude scales
        let ampScale1 = 1.0 + sin(timeScale * 0.65) * 0.3
        let ampScale2 = 1.0 + sin(timeScale * 0.75) * 0.35
        let ampScale3 = 1.0 + sin(timeScale * 0.85) * 0.25
        let ampScale4 = 1.0 + sin(timeScale * 0.7) * 0.4
        
        let points = 120
        for i in 0...points {
            let angle = (Double(i) / Double(points)) * 2 * .pi
            
            // Create flowing wave patterns with continuous time-based variation
            let wave1 = sin(angle * freq1 + phase + phaseOffset1) * 0.12 * ampScale1
            let wave2 = sin(angle * freq2 + phase * 1.5 + phaseOffset2) * 0.08 * ampScale2
            let wave3 = sin(angle * freq3 - phase * 0.8 + phaseOffset3) * 0.05 * ampScale3
            let wave4 = cos(angle * freq4 + phase * 1.2 + phaseOffset4) * 0.06 * ampScale4
            
            // Add audio reactivity
            let audioVariation = audioLevel * 0.15
            
            let variation = 1 + wave1 + wave2 + wave3 + wave4 + audioVariation
            let radius = baseRadius * variation
            
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}
